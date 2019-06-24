package com.sirolf2009.mbti

import java.nio.file.Files
import java.nio.file.Paths

class PageRenderer {
	
	def static getPage(String filename) {
		return '''
		«header()»
		«getResource(filename)»
		«footer()»'''
	}
	
	def static header() {
		getResource("header.html")
	}
	
	def static footer() {
		getResource("footer.html")
	}
	
	def static getResource(String filename) {
		Files.readAllLines(Paths.get("src/main/resources/"+filename)).join("\n")
	}
}