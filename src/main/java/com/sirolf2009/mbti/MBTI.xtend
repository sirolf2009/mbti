package com.sirolf2009.mbti

import java.nio.file.Files
import java.nio.file.Paths

import static spark.Spark.*
import com.sirolf2009.util.SpanUtil
import com.sirolf2009.mbti.model.User
import java.util.Optional
import java.util.UUID
import com.sirolf2009.mbti.model.Profile
import com.sirolf2009.mbti.model.Type

class MBTI {

	def static void main(String[] args) {
		val tracer = SpanUtil.getTracer("localhost", "mbti")
		val db = new Database(tracer)
		val loginController = new LoginController(tracer, db)
		val questionController = new QuestionController(tracer, db)

		staticFileLocation("/resources")
		get("/") [
			return Files.readAllLines(Paths.get("src/main/resources/Sticky_Example.html")).join("\n")
		]
		get("/question") [
			return Files.readAllLines(Paths.get("src/main/resources/question.html")).join("\n")
		]
		get("/profile") [ req, res |
			LoginController.ensureUserIsLoggedIn(req, res)
			return Files.readAllLines(Paths.get("src/main/resources/question.html")).join("\n")
		]
		path("/submit") [
			get("/question", questionController.handleSubmitQuestionGet())
		]
		get("/register") [ req, res |
			return Files.readAllLines(Paths.get("src/main/resources/register.html")).join("\n")
		]
		post("/register") [ req, res |
			try {
				val username = req.queryParams("username")
				val password = req.queryParams("password")
				val passwordRepeat = req.queryParams("password-repeat")
				val email = Optional.ofNullable(req.queryParams("email"))
				println(req.queryParams("type"))
				val type = Optional.ofNullable(Type.valueOf(req.queryParams("type")))
				val user = new User(UUID.randomUUID(), new Profile(username, email, type), password)
				println(user)
				println(db.saveUser(user))
				return user.toString()
			} catch(Exception e) {
				e.printStackTrace()
				return e.getMessage()
			}
		]
		get("/login", loginController.handleLoginGet())
		post("/login", loginController.handleLoginPost())

//		val question = new Question(new Date(), "Anne eats shit because it feels good, what is Anne?", FunctionType.SENSING.getFunctions(), Function.SE, 666, 0)
//		println(question)
//		val response = db.saveQuestion(question)
//		println(response)
//		println(response.getId())
//		Thread.sleep(2000)
//		println(db.getQuestion(response.getId()))
	}

}
