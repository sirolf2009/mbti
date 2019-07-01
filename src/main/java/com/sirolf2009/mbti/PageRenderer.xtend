package com.sirolf2009.mbti

import java.nio.file.Files
import java.nio.file.Paths
import spark.Request

class PageRenderer {

	def static String getPage(Request req, String filename) {
		return '''
		«header(req)»
		«getResource(filename)»
		«footer()»'''
	}

	def static header(Request req) {
		LoginController.getUserID(req).map [
			getResource("headerLoggedIn.html").replace("%USERID%", toString())
		].orElseGet [
			getResource("header.html")
		]
	}

	def static footer() {
		getResource("footer.html")
	}

	def static getResource(String filename) {
		Files.readAllLines(Paths.get("src/main/resources/" + filename)).join("\n")
	}
}
