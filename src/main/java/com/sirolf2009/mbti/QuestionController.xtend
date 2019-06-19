package com.sirolf2009.mbti

import io.opentracing.Tracer
import java.nio.file.Files
import java.nio.file.Paths
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import spark.Request
import spark.Response
import spark.Route

import static extension com.sirolf2009.util.SpanUtil.*

@FinalFieldsConstructor class QuestionController {

	val Tracer tracer
	val Database db

	def Route handleSubmitQuestionGet() {
		[ Request req, Response res |
			tracer.span("submitQuestionGet") [
				LoginController.ensureUserIsLoggedIn(req, res)
				return render()
			]
		]
	}

	def render() {
		val page = Files.readAllLines(Paths.get("src/main/resources/submitQuestion.html")).join("\n")
		return page
	}
}
