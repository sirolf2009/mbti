package com.sirolf2009.mbti

import com.sirolf2009.mbti.model.Profile
import com.sirolf2009.mbti.model.Type
import com.sirolf2009.mbti.model.User
import io.opentracing.Tracer
import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import java.util.UUID
import org.apache.commons.lang3.exception.ExceptionUtils
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import spark.Request
import spark.Response
import spark.Route

import static extension com.sirolf2009.util.SpanUtil.*

@FinalFieldsConstructor class LoginController {

	val Tracer tracer
	val Database db

	def Route handleProfileGet() {
		[ Request req, Response res |
			tracer.span("profileGet") [
				val ID = req.params("ID")
				val user = db.getUserByID(ID)
				println(user)
				val profile = user.getProfile()
				renderProfile(profile)
			]
		]
	}

	def Route handleLoginGet() {
		[ Request req, Response res |
			tracer.span("loginGet") [
				if(req.isLoggedIn()) {
					if(req.session().attribute("loginRedirect") !== null) {
						res.redirect(req.session().attribute("loginRedirect"))
					} else {
						res.redirect("/profile")
					}
					return ""
				}
				return renderLogin(null)
			]
		]
	}

	def Route handleLoginPost() {
		[ Request req, Response response |
			try {
				tracer.span("loginPost") [
					val username = req.queryParams("username")
					val password = req.queryParams("password")
					setTag("username", username)
					setTag("password", password)
					val user = db.getUser(username)
					if(hashPassword(password, user.getSalt()).equals(user.getPassword())) {
						req.session().attribute("currentUser", username)
						if(req.session().attribute("loginRedirect") !== null) {
							response.redirect(req.session().attribute("loginRedirect"))
						} else {
							response.redirect('''/profile/«user.getID()»''')
						}
						return ""
					} else {
						return renderLogin("Incorrect username/password")
					}
				]
			} catch(Exception e) {
				return ExceptionUtils.getStackTrace(e)
			}
		]
	}

	def Route handleRegisterGet() {
		[ Request req, Response res |
			return renderRegister(null)
		]
	}

	def Route handleRegisterPost() {
		[ Request req, Response res |
			tracer.span("registerPost") [
				try {
					val username = req.queryParams("username")
					val password = req.queryParams("password")
					val passwordRepeat = req.queryParams("password-repeat")
					if(! password.equals(passwordRepeat)) {
						return renderRegister("Passwords don't match")
					}
					if(db.getUser(username) !== null) {
						return renderRegister("This username is already in use")
					}
					
					val email = req.queryParams("email")
					val type = if(req.queryParams("type").isNullOrEmpty()) {
						null
					} else {
						Type.valueOf(req.queryParams("type"))
					}
					val salt = UUID.randomUUID()
					val hashedPassword = hashPassword(password, salt)
					val user = new User(UUID.randomUUID(), new Profile(username, email, type), salt, hashedPassword)
					db.saveUser(user)
					return renderProfile(user.getProfile())
				} catch(Exception e) {
					e.printStackTrace()
					return e.getMessage()
				}

			]
		]
	}

	def static hashPassword(String password, UUID salt) {
		val md = MessageDigest.getInstance("SHA-512")
		md.update(salt.toString().getBytes(StandardCharsets.UTF_8))
		val bytes = md.digest(password.getBytes(StandardCharsets.UTF_8))
		bytes.map [
			Integer.toString(it.bitwiseAnd(0xff) + 0x100, 16).substring(1)
		].join()
	}

	public static Route handleLogoutPost = [ Request request, Response response |
		request.session().removeAttribute("currentUser")
		request.session().attribute("loggedOut", true)
//		response.redirect(Path.Web.LOGIN) 
		return "login page"
	]

	// The origin of the request (request.pathInfo()) is saved in the session so
	// the user can be redirected back after login
	def static void ensureUserIsLoggedIn(Request request, Response response) {
		if(!request.isLoggedIn()) {
			request.session().attribute("loginRedirect", request.pathInfo())
			response.redirect("/login")
		}
	}

	def static isLoggedIn(Request req) {
		return req.session().attribute("currentUser") !== null
	}
	
	def renderProfile(Profile profile) {
		println(profile.getType().get().getClass())
		val page = PageRenderer.getPage("profile.html")
		page.replace("%USERNAME%", profile.getUsername()).replace("%TYPE%", profile.getType().map[toString()].orElse(""))
	}

	def renderLogin(String errorMessage) {
		val page = PageRenderer.getPage("login.html")
		if(!errorMessage.isNullOrEmpty()) {
			return page.replace("%ERRORMESSAGE%", errorMessage)
		} else {
			return page.replace("%ERRORMESSAGE%", "")
		}
	}

	def renderRegister(String errorMessage) {
		val page = PageRenderer.getPage("register.html")
		if(!errorMessage.isNullOrEmpty()) {
			return page.replace("%ERRORMESSAGE%", errorMessage)
		} else {
			return page.replace("%ERRORMESSAGE%", "")
		}
	}
}
