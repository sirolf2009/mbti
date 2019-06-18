package com.sirolf2009.mbti

import java.util.HashMap
import java.util.Map
import spark.Request
import spark.Response
import spark.Route

class LoginController {
	public static Route serveLoginPage=[Request request, Response response | {
//		var Map<String, Object> model=new HashMap() 
//		model.put("loggedOut", removeSessionAttrLoggedOut(request)) 
//		model.put("loginRedirect", removeSessionAttrLoginRedirect(request)) 
//		return ViewUtil.render(request, model, Path.Template.LOGIN) 
		return "login page"
	}]
	public static Route handleLoginPost=[Request request, Response response | {
		val Map<String, Object> model=new HashMap() 
		val username = request.queryParams("username")
		if (!UserController.authenticate(username, request.queryParams("password"))) {
			model.put("authenticationFailed", true)
			return "login" 
//			return ViewUtil.render(request, model, Path.Template.LOGIN) 
		}
		model.put("authenticationSucceeded", true) 
		request.session().attribute("currentUser", username) 
		if (request.queryParams("loginRedirect") !== null) {
			response.redirect(request.queryParams("loginRedirect")) 
		}
		return "home page"
//		return ViewUtil.render(request, model, Path.Template.LOGIN) 
	}]
	public static Route handleLogoutPost=[Request request, Response response | {
		request.session().removeAttribute("currentUser") 
		request.session().attribute("loggedOut", true) 
//		response.redirect(Path.Web.LOGIN) 
		return "login page"
	}]
	// The origin of the request (request.pathInfo()) is saved in the session so
	// the user can be redirected back after login
	def static void ensureUserIsLoggedIn(Request request, Response response) {
		if (request.session().attribute("currentUser") === null) {
			request.session().attribute("loginRedirect", request.pathInfo()) 
//			response.redirect(Path.Web.LOGIN) 
		}
	}
}