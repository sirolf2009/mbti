package com.sirolf2009.mbti

import com.sirolf2009.util.SpanUtil
import java.util.HashMap
import org.apache.commons.lang3.exception.ExceptionUtils

import static spark.Spark.*

class MBTI {

	def static void main(String[] args) {
		val tracer = SpanUtil.getTracer("localhost", "mbti")
		val db = new Database(tracer)
		val loginController = new LoginController(tracer, db)
		val questionController = new QuestionController(tracer, db)

		if(args.size() == 1) {
			port(Integer.parseInt(args.get(0)))
		}

		staticFileLocation("/resources")

		get("/", questionController.handleGetQuestions())
		get("/question/:ID", questionController.handleGetQuestion())
		post("/question/:ID", questionController.handlePostQuestion())
		post("/vote/question", questionController.handleVoteQuestionPost())
		get("/questions", questionController.handleGetQuestions())
		get("/questions/:CATEGORY", questionController.handleGetQuestionsCategory())
		path("/submit") [
			get("/question", questionController.handleSubmitQuestionGet())
			post("/question", questionController.handleSubmitQuestionPost())
		]
		get("/profile/:ID", loginController.handleProfileGet())
		get("/register", loginController.handleRegisterGet())
		post("/register", loginController.handleRegisterPost())
		get("/login", loginController.handleLoginGet())
		post("/login", loginController.handleLoginPost())

		val sessionSpans = new HashMap()
//		before[ req, res |
//			val span = tracer.buildSpan(req.url()).asChildOf(tracer.activeSpan()).start()
//			req.headers().forEach[span.setTag('''header.«it»''', req.headers(it))]
//			req.queryParams().forEach[span.setTag('''queryParam.«it»''', req.queryParams(it))]
//			span.setTag("body", req.body())
//			span.setTag("ip", req.ip())
//			LoginController.getUserID(req).ifPresent[span.setTag("userID", toString())]
//			sessionSpans.put(req, span)
//		]
//		exception(Exception) [err,req,res|
//			sessionSpans.get(req) => [
//				setTag("error", true)
//				log(ExceptionUtils.getStackTrace(err))
//			]
//		]
//		afterAfter[ req, res |
//			sessionSpans.get(req).finish()
//		]
	}

}
