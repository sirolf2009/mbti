package com.sirolf2009.mbti

import io.opentracing.Tracer
import java.nio.file.Files
import java.nio.file.Paths
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import spark.Request
import spark.Response
import spark.Route

import static extension com.sirolf2009.util.SpanUtil.*
import org.apache.commons.lang3.exception.ExceptionUtils

@FinalFieldsConstructor class LoginController {

	val Tracer tracer
	val Database db

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
				return render(null)
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
					if(!db.authenticate(username, password)) {
						return render("Incorrect username/password")
					}
					req.session().attribute("currentUser", username)
					if(req.session().attribute("loginRedirect") !== null) {
						response.redirect(req.session().attribute("loginRedirect"))
					} else {
						response.redirect("/profile")
					}
					return ""
				]
			} catch(Exception e) {
				return ExceptionUtils.getStackTrace(e)
			}
		]
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

	def render(String errorMessage) {
		val page = Files.readAllLines(Paths.get("src/main/resources/login.html")).join("\n")
		if(!errorMessage.isNullOrEmpty()) {
			return page.replace("%ERRORMESSAGE%", errorMessage)
		} else {
			return page.replace("%ERRORMESSAGE%", "")
		}
	}
}
