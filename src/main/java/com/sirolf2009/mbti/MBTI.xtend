package com.sirolf2009.mbti

import com.sirolf2009.mbti.model.FunctionType
import com.sirolf2009.mbti.model.Question
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Date

import static spark.Spark.*
import com.sirolf2009.mbti.model.Function

class MBTI {

	def static void main(String[] args) {
		val db = new Database()

		staticFileLocation("/resources")
		get("/") [
			return Files.readAllLines(Paths.get("src/main/resources/Sticky_Example.html")).join("\n")
		]
		get("/question") [
			return Files.readAllLines(Paths.get("src/main/resources/question.html")).join("\n")
		]
		get("/profile") [req, res|
			LoginController.ensureUserIsLoggedIn(req, res)
			return Files.readAllLines(Paths.get("src/main/resources/question.html")).join("\n")
		]
		
//		val question = new Question(new Date(), "Anne eats shit because it feels good, what is Anne?", FunctionType.SENSING.getFunctions(), Function.SE, 666, 0)
//		println(question)
//		val response = db.saveQuestion(question)
//		println(response)
//		println(response.getId())
//		Thread.sleep(2000)
//		println(db.getQuestion(response.getId()))
		
	}

}
