package com.sirolf2009.mbti

import com.sirolf2009.mbti.model.Profile
import com.sirolf2009.mbti.model.Type
import com.sirolf2009.mbti.model.User
import com.sirolf2009.util.TimeUtil
import io.opentracing.Tracer
import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import java.util.Optional
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
				renderProfile(req, user)
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
				return renderLogin(req, null)
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
					return db.getUser(username).map [ user |
						if(hashPassword(password, user.getSalt()).equals(user.getPassword())) {
							req.session().attribute("currentUser", user.getID().toString())
							if(req.session().attribute("loginRedirect") !== null) {
								response.redirect(req.session().attribute("loginRedirect"))
							} else {
								response.redirect('''/profile/«user.getID()»''')
							}
							return ""
						} else {
							return renderLogin(req, "Incorrect username/password")
						}
					].orElse(renderLogin(req, "Incorrect username/password"))
				]
			} catch(Exception e) {
				return ExceptionUtils.getStackTrace(e)
			}
		]
	}

	def Route handleRegisterGet() {
		[ Request req, Response res |
			return renderRegister(req, null)
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
						return renderRegister(req, "Passwords don't match")
					}
					if(db.getUser(username).isPresent()) {
						return renderRegister(req, "This username is already in use")
					}
					val email = req.queryParams("email")
					if(email.isNullOrEmpty()) {
						return renderRegister(req, "You need to fill in an email address")
					}
					val type = if(req.queryParams("type").isNullOrEmpty()) {
							null
						} else {
							Type.valueOf(req.queryParams("type"))
						}
					val salt = UUID.randomUUID()
					val hashedPassword = hashPassword(password, salt)
					val user = new User(UUID.randomUUID(), new Profile(username, email, type), salt, hashedPassword)
					db.saveUser(user)
					req.session().attribute("currentUser", user.getID().toString())
					return renderProfile(req, user)
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
		return req.getUserID().isPresent()
	}

	def static getUserID(Request req) {
		return Optional.ofNullable(req.session().attribute("currentUser") as String).map[UUID.fromString(it)]
	}

	def renderProfile(Request req, User user) {
		val profile = user.getProfile()
		val page = PageRenderer.getPage(req, "profile.html")
		val attempts = db.getAttempts(user.getID()).sortBy[getTimestamp()].reverse().map [
			val question = db.getQuestion(getQuestionID().toString())
			'''
			<div class="item">
			    <i class="large «if(getChosenAnswer() == question.getCorrectAnswer()) "check" else "x"» middle aligned icon"></i>
			    <div class="content">
			      <a class="header">«question.getTitle()»</a>
			      <div class="description">You answered this at «TimeUtil.format(getTimestamp())»</div>
			    </div>
			</div>'''
		].join("\n")
		page.replace("%USERNAME%", profile.getUsername()).replace("%TYPE%", profile.getType().map[toString()].orElse("")).replace("%GRAVATAR%", profile.getGravatar()).replace("%ATTEMPTS%", attempts)
	}

	def renderLogin(Request req, String errorMessage) {
		val page = PageRenderer.getPage(req, "login.html")
		if(!errorMessage.isNullOrEmpty()) {
			return page.replace("%ERRORMESSAGE%", errorMessage)
		} else {
			return page.replace("%ERRORMESSAGE%", "")
		}
	}

	def renderRegister(Request req, String errorMessage) {
		val page = PageRenderer.getPage(req, "register.html")
		if(!errorMessage.isNullOrEmpty()) {
			return page.replace("%ERRORMESSAGE%", errorMessage)
		} else {
			return page.replace("%ERRORMESSAGE%", "")
		}
	}
}
