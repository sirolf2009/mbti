package com.sirolf2009.mbti

import com.sirolf2009.mbti.model.Question
import io.opentracing.Tracer
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Date
import java.util.List
import java.util.Optional
import java.util.UUID
import org.apache.commons.lang3.exception.ExceptionUtils
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import spark.Request
import spark.Response
import spark.Route

import static extension com.sirolf2009.util.DoubleExtensions.map
import static extension com.sirolf2009.util.SpanUtil.*

@FinalFieldsConstructor class QuestionController {

	val Tracer tracer
	val Database db

	def Route handleSubmitQuestionGet() {
		[ Request req, Response res |
			tracer.span("submitQuestionGet") [
				LoginController.ensureUserIsLoggedIn(req, res)
				return renderSubmitQuestion()
			]
		]
	}

	def Route handleSubmitQuestionPost() {
		[ Request req, Response res |
			try {
				tracer.span("submitQuestionPost") [
					LoginController.ensureUserIsLoggedIn(req, res)
					val username = req.session().attribute("currentUser")
					val title = req.queryParams("title")
					val description = req.queryParams("description")
					val options = req.queryParams().filter[startsWith("answer-") && endsWith("-text") && !contains("template")].sortBy[Integer.parseInt(split("-").get(1))].map[req.queryParams(it)].toList()
					val correctOption = req.queryParams().filter[startsWith("answer-") && endsWith("-correct") && !contains("template")].map[Integer.parseInt(split("-").get(1))].findFirst[true]
					val explanation = if(req.queryParams("explanation").isNullOrEmpty()) Optional.empty() else Optional.of(req.queryParams("explanation"))
					val question = new Question(UUID.randomUUID(), username, new Date(), title, description, options, correctOption, explanation, 0, 0)
					db.saveQuestion(question)
					return renderSubmitQuestion()
				]
			} catch(Exception e) {
				return ExceptionUtils.getStackTrace(e)
			}
		]
	}

	def Route handleGetQuestions() {
		[ Request req, Response res |
			tracer.span("getQuestion") [
				try {
					return renderQuestions(db.getTopQuestions())
				} catch(Exception e) {
					return ExceptionUtils.getStackTrace(e)
				}
			]
		]
	}

	def Route handleGetQuestion() {
		[ Request req, Response res |
			tracer.span("submitQuestionGet") [
				try {
					val ID = req.params("ID")
					return renderQuestion(db.getQuestion(ID))
				} catch(Exception e) {
					return ExceptionUtils.getStackTrace(e)
				}
			]
		]
	}

	def renderSubmitQuestion() {
		val page = Files.readAllLines(Paths.get("src/main/resources/submitQuestion.html")).join("\n")
		return page
	}

	def renderQuestions(List<Question> questions) {
		val page = Files.readAllLines(Paths.get("src/main/resources/questions.html")).join("\n")
		val questionsText = questions.map[
			'''
			<div class="item" id="answer-0">
				<div class="content">
					<a class="header" href="/question/«getID()»">«getTitle()»</a>
					<div class="description">«getUpvotes()» upvotes «getDownvotes()» downvotes</div>
				</div>
			</div>
			'''
		].join("\n")
		return page.replace("%QUESTIONS%", questionsText)
	}

	def renderQuestion(Question question) {
		val page = Files.readAllLines(Paths.get("src/main/resources/question.html")).join("\n")
		val optionsText = question.getOptions().map[
			'''
			<button class="ui button" >«it»</button>
			'''
		].join("\n")
		val rating = question.getUpvotes().doubleValue().map(0, question.getUpvotes()+question.getDownvotes(), 1, 5)
		return page.replace("%TITLE%", question.getTitle()).replace("%DESCRIPTION%", question.getDescription()).replace("%OPTIONS%", optionsText).replace("%RATING%", Math.round(rating).toString())
	}
}
