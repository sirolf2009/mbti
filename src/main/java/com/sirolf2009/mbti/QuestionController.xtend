package com.sirolf2009.mbti

import com.sirolf2009.mbti.model.Question
import io.opentracing.Tracer
import java.util.Date
import java.util.List
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
					req.queryParams().forEach[
						println('''«it»: «req.queryParams(it)»''')
					]
					LoginController.ensureUserIsLoggedIn(req, res)
					val username = req.session().attribute("currentUser")
					val title = req.queryParams("title")
					val description = req.queryParams("description")
					val options = req.queryParams().filter[startsWith("answer-") && endsWith("-text") && !contains("template")].sortBy[Integer.parseInt(split("-").get(1))].map[req.queryParams(it)].toList()
					val correctOption = Integer.parseInt(req.queryParams("correct-answer").split("-").get(1))
					val explanation = req.queryParams("explanation")
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

	def Route handlePostQuestion() {
		[ Request req, Response res |
			tracer.span("submitQuestionPost") [
				try {
					val ID = req.params("ID")
					val question = db.getQuestion(ID)
					val chosenAnswer = Integer.parseInt(req.queryParams().findFirst[startsWith("answer-")].replace("answer-", ""))
					renderQuestionResult(question, chosenAnswer)
				} catch(Exception e) {
					return ExceptionUtils.getStackTrace(e)
				}
			]
		]
	}

	def renderSubmitQuestion() {
		PageRenderer.getPage("submitQuestion.html")
	}

	def renderQuestions(List<Question> questions) {
		val page = PageRenderer.getPage("questions.html")
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
		val page = PageRenderer.getPage("question.html")
		val optionsText = question.getOptions().map[
			'''
			<button class="ui button" type="submit" name="answer-«question.getOptions().indexOf(it)»">«it»</button>
			'''
		].join("\n")
		val rating = question.getUpvotes().doubleValue().map(0, question.getUpvotes()+question.getDownvotes(), 1, 5)
		return page.replace("%TITLE%", question.getTitle()).replace("%DESCRIPTION%", question.getDescription()).replace("%OPTIONS%", optionsText).replace("%RATING%", Math.round(rating).toString()).replace("%ANSWERCOUNT%", countToHuman.get(question.getOptions().size()))
	}

	def renderQuestionResult(Question question, int chosenAnswer) {
		val page = PageRenderer.getPage("questionResult.html")
		val optionsText = question.getOptions().map[
			'''
			<button class="ui «if(question.getOptions().indexOf(it) === chosenAnswer) "green" else "red"» button">«it»</button>
			'''
		].join("\n")
		val rating = question.getUpvotes().doubleValue().map(0, question.getUpvotes()+question.getDownvotes(), 1, 5)
		val overview = if(question.getCorrectAnswer() == chosenAnswer) {
			'''
			Correct!'''
		} else {
			'''
			Wrong! The correct answer was «question.getOptions().get(question.getCorrectAnswer())»'''
		}
		val explanation = question.getExplanation().map['''<p>«it»</p>'''].orElse("")
		return page.replace("%TITLE%", question.getTitle()).replace("%DESCRIPTION%", question.getDescription()).replace("%OPTIONS%", optionsText).replace("%RATING%", Math.round(rating).toString()).replace("%ANSWERCOUNT%", countToHuman.get(question.getOptions().size())).replace("%OVERVIEW%", overview).replace("%EXPLANATION%", explanation)
	}
	
	static val countToHuman = #{
		1 -> "one",
		2 -> "two",
		3 -> "three",
		4 -> "four",
		5 -> "five",
		6 -> "six",
		7 -> "seven",
		8 -> "eight",
		9 -> "nine",
		10 -> "ten",
		11 -> "eleven",
		12 -> "twelve"
	}
}
