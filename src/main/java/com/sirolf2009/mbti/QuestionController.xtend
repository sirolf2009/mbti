package com.sirolf2009.mbti

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.sirolf2009.mbti.model.Attempt
import com.sirolf2009.mbti.model.Question
import com.sirolf2009.mbti.model.QuestionCategory
import com.sirolf2009.mbti.model.Vote
import io.opentracing.Tracer
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
import static extension com.sirolf2009.util.OptionalUtil.*
import static extension com.sirolf2009.util.SpanUtil.*
import static extension com.sirolf2009.mbti.RestSpanUtil.*
import java.util.Objects

@FinalFieldsConstructor class QuestionController {

	val Tracer tracer
	val Database db

	def Route handleVoteQuestionPost() {
		val gson = new Gson();
		[ Request req, Response res |
			tracer.span("voteQuestionPost", req) [
				setTag("body", req.body())
				LoginController.getUserID(req).ifPresent [ userID |
					val json = gson.fromJson(req.body(), JsonObject)
					val questionID = UUID.fromString(json.getAsJsonPrimitive("questionID").getAsString())
					val up = json.getAsJsonPrimitive("up").getAsBoolean()

					Optional.ofNullable(db.getVote(userID, questionID)).consume([ existing |
						tracer.span("updateVote") [
							setTag("existing", existing.toString())
							db.updateVote(existing.getID(), up)
						]
					], [
						tracer.span("createNewVote") [
							val vote = new Vote(UUID.randomUUID(), userID, questionID, up, new Date())
							db.saveVote(vote)
						]
					])
				]
				return ""
			]
		]
	}

	def Route handleSubmitQuestionGet() {
		[ Request req, Response res |
			tracer.span("submitQuestionGet", req) [
				LoginController.ensureUserIsLoggedIn(req, res)
				return renderSubmitQuestion(req)
			]
		]
	}

	def Route handleSubmitQuestionPost() {
		[ Request req, Response res |
			try {
				tracer.span("submitQuestionPost", req) [
					LoginController.ensureUserIsLoggedIn(req, res)
					val username = req.session().attribute("currentUser")
					val title = req.queryParams("title")
					val description = req.queryParams("description")
					val options = req.queryParams().filter[startsWith("answer-") && endsWith("-text") && !contains("template")].sortBy[Integer.parseInt(split("-").get(1))].map[req.queryParams(it)].toList()
					val correctOption = Integer.parseInt(req.queryParams("correct-answer").split("-").get(1))
					val explanation = req.queryParams("explanation")
					val questionCategory = QuestionCategory.valueOf(req.queryParams("questionCategory"))
					val question = new Question(UUID.randomUUID(), username, new Date(), title, description, options, correctOption, explanation, questionCategory)
					db.saveQuestion(question)
					res.redirect('''/question/«question.getID()»''')
					return ""
				]
			} catch(Exception e) {
				return ExceptionUtils.getStackTrace(e).replace("\n", "<br />")
			}
		]
	}

	def Route handleGetQuestions() {
		[ Request req, Response res |
			tracer.span("getQuestion", req) [
				try {
					return renderQuestionsList(req)
				} catch(Exception e) {
					return ExceptionUtils.getStackTrace(e).replace("\n", "<br />")
				}
			]
		]
	}

	def Route handleGetQuestionsCategory() {
		[ Request req, Response res |
			tracer.span("getQuestion", req) [
				try {
					return renderQuestionsList(req, db.getQuestions(QuestionCategory.valueOf(req.params(":CATEGORY").toUpperCase())))
				} catch(Exception e) {
					return ExceptionUtils.getStackTrace(e).replace("\n", "<br />")
				}
			]
		]
	}

	def Route handleGetQuestion() {
		[ Request req, Response res |
			tracer.span("submitQuestionGet", req) [
				try {
					val ID = req.params("ID")
					val question = db.getQuestion(ID)
					Objects.requireNonNull(question, '''Question with «ID» not found!''')
					return renderQuestion(req, question)
				} catch(Exception e) {
					return ExceptionUtils.getStackTrace(e).replace("\n", "<br />")
				}
			]
		]
	}

	def Route handlePostQuestion() {
		[ Request req, Response res |
			tracer.span("submitQuestionPost", req) [
				try {
					val ID = req.params("ID")
					val question = db.getQuestion(ID)
					val chosenAnswer = Integer.parseInt(req.queryParams().findFirst[startsWith("answer-")].replace("answer-", ""))
					LoginController.getUserID(req).ifPresent [ userID |
						tracer.span("saveAttempt") [
							db.saveAttempt(new Attempt(UUID.randomUUID(), userID, UUID.fromString(ID), chosenAnswer, new Date()))
						]
					]
					renderQuestionResult(req, question, chosenAnswer)
				} catch(Exception e) {
					return ExceptionUtils.getStackTrace(e).replace("\n", "<br />")
				}
			]
		]
	}

	def renderSubmitQuestion(Request req) {
		val page = PageRenderer.getPage(req, "submitQuestion.html")
		val categories = QuestionCategory.values().sortBy[getOrder()].map [
			'''
			<option value="«name()»">«getHumanReadable()»</option>'''
		].join("\n")
		return page.replace("%QUESTIONCATEGORIES%", categories)
	}

	def renderQuestionsList(Request req, List<Question> questions) {
		val page = PageRenderer.getPage(req, "questionList.html")
		val questionsText = questions.map [
			val upvotes = db.getVotes(getID())
			'''
			<div class="item" id="answer-0">
				<div class="content">
					<a class="header" href="/question/«getID()»">«getTitle()»</a>
					<div class="description">«upvotes.filter[up].size()» upvotes «upvotes.filter[!up].size()» downvotes</div>
				</div>
			</div>'''
		].join("\n")
		return page.replace("%QUESTIONS%", questionsText)
	}

	def renderQuestionsList(Request req) {
		val page = PageRenderer.getPage(req, "questions.html")
		return page
	}

	def renderQuestion(Request req, Question question) {
		try {
			val page = PageRenderer.getPage(req, "question.html")
			val optionsText = question.getOptions().map [
				'''
				<button class="ui button" type="submit" name="answer-«question.getOptions().indexOf(it)»">«it»</button>'''
			].join("\n")
			val votes = db.getVotes(question.getID())
			val rating = votes.filter[isUp()].size().doubleValue().map(0, votes.size(), 1, 5)
			return page.replace("%TITLE%", question.getTitle()).replace("%DESCRIPTION%", question.getDescription()).replace("%OPTIONS%", optionsText).replace("%RATING%", Math.round(rating).toString()).replace("%ANSWERCOUNT%", countToHuman.get(question.getOptions().size()))
		} catch(Exception e) {
			throw new RuntimeException('''Failed to render question «question»''', e)
		}
	}

	def renderQuestionResult(Request req, Question question, int chosenAnswer) {
		try {
			val page = PageRenderer.getPage(req, "questionResult.html")
			val optionsText = question.getOptions().map [
				'''
				<button class="ui «if(question.getOptions().indexOf(it) === chosenAnswer) "green" else "red"» button">«it»</button>'''
			].join("\n")
			val votes = db.getVotes(question.getID())
			val rating = votes.filter[isUp()].size().doubleValue().map(0, votes.size(), 1, 5)
			val overview = if(question.getCorrectAnswer() == chosenAnswer) {
					'''
					Correct!'''
				} else {
					'''
					Wrong! The correct answer was «question.getOptions().get(question.getCorrectAnswer())»'''
				}
			val vote = LoginController.getUserID(req).map [
				'''
				<div class="ui buttons">
					<button class="ui positive button" onClick="vote('«question.getID()»', true)">Vote up</button>
					<div class="or"></div>
					<button class="ui negative button" onClick="vote('«question.getID()»', false)">Vote down</button>
				</div>'''
			].orElse("")
			val explanation = question.getExplanation().map['''<p>«it»</p>'''].orElse("")
			return page.replace("%TITLE%", question.getTitle()).replace("%ID%", question.getID().toString()).replace("%DESCRIPTION%", question.getDescription()).replace("%OPTIONS%", optionsText).replace("%RATING%", Math.round(rating).toString()).replace("%ANSWERCOUNT%", countToHuman.get(question.getOptions().size())).replace("%OVERVIEW%", overview).replace("%EXPLANATION%", explanation).replace("%VOTE%", vote)
		} catch(Exception e) {
			throw new RuntimeException('''Failed to render question result, chosenAnswer=«chosenAnswer» question=«question»''', e)
		}
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
