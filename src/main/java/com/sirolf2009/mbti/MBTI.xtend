package com.sirolf2009.mbti

import com.sirolf2009.util.SpanUtil

import static spark.Spark.*

class MBTI {

	def static void main(String[] args) {
		val tracer = SpanUtil.getTracer("localhost", "mbti")
		val db = new Database(tracer)
		val loginController = new LoginController(tracer, db)
		val questionController = new QuestionController(tracer, db)

		staticFileLocation("/resources")
		get("/", questionController.handleGetQuestions())
		get("/question/:ID", questionController.handleGetQuestion())
		post("/question/:ID", questionController.handlePostQuestion())
		get("/questions", questionController.handleGetQuestions())
		path("/submit") [
			get("/question", questionController.handleSubmitQuestionGet())
			post("/question", questionController.handleSubmitQuestionPost())
		]
		get("/profile/:ID", loginController.handleProfileGet())
		get("/register", loginController.handleRegisterGet())
		post("/register", loginController.handleRegisterPost())
		get("/login", loginController.handleLoginGet())
		post("/login", loginController.handleLoginPost())
	}

}
