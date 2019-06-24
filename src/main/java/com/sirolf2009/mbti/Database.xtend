package com.sirolf2009.mbti

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.sirolf2009.mbti.model.Profile
import com.sirolf2009.mbti.model.ProfileJsonDeserializer
import com.sirolf2009.mbti.model.Question
import com.sirolf2009.mbti.model.QuestionJsonDeserializer
import com.sirolf2009.mbti.model.User
import com.sirolf2009.mbti.model.UserJsonDeserializer
import io.opentracing.Tracer
import org.apache.http.HttpHost
import org.elasticsearch.action.admin.indices.create.CreateIndexRequest
import org.elasticsearch.action.admin.indices.get.GetIndexRequest
import org.elasticsearch.action.index.IndexRequest
import org.elasticsearch.action.search.SearchRequest
import org.elasticsearch.client.RestClient
import org.elasticsearch.client.RestHighLevelClient
import org.elasticsearch.common.xcontent.XContentType
import org.elasticsearch.index.query.QueryBuilders
import org.elasticsearch.search.builder.SearchSourceBuilder

import static extension com.sirolf2009.util.SpanUtil.*

class Database {

	val Tracer tracer
	val RestHighLevelClient client
	val Gson gson

	new(Tracer tracer) {
		this(tracer, new HttpHost("localhost", 9200, "http"))
	}

	new(Tracer tracer, HttpHost... hosts) {
		this(tracer, new RestHighLevelClient(RestClient.builder(hosts)))
	}

	new(Tracer tracer, RestHighLevelClient client) {
		this.tracer = tracer
		this.client = client
		this.gson = new GsonBuilder().registerTypeAdapter(Question, new QuestionJsonDeserializer()).registerTypeAdapter(Profile, new ProfileJsonDeserializer()).registerTypeAdapter(User, new UserJsonDeserializer()).create()
		#["mbti-user", "mbti-question"].forEach [
			if(!client.indices().exists(new GetIndexRequest().indices(it))) {
				client.indices().create(new CreateIndexRequest(it))
			}
		]
	}

	def getTopQuestions() {
		tracer.span("getTopQuestions") [
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.matchAllQuery())
			]
			client.search(new SearchRequest(#["mbti-question"], search.sort("upvotes"))).getHits().map[gson.fromJson(getSourceAsString(), Question)].toList()
		]
	}

	def getQuestion(String ID) {
		tracer.span("getQuestion") [
			setTag("ID", ID)
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.termQuery("_id", ID))
			]
			client.search(new SearchRequest(#["mbti-question"], search)).getHits().map[gson.fromJson(getSourceAsString(), Question)].findFirst[true]
		]
	}

	def saveQuestion(Question question) {
		tracer.span("saveQuestion") [
			setTag("question", question.toString())
			val json = gson.toJson(question)
			setTag("question.json", json)
			val request = new IndexRequest("mbti-question") => [
				id(question.getID().toString())
				type("json")
				source(json, XContentType.JSON)
			]
			client.index(request)
		]
	}

	def getUser(String username) {
		tracer.span("getUser") [
			setTag("username", username)
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.termQuery("profile.username", username))
			]
			val hit = client.search(new SearchRequest(#["mbti-user"], search)).getHits().map[gson.fromJson(sourceAsString, User)].findFirst[true]
			val found = hit !== null
			setTag("found", found)
			return hit
		]
	}

	def getUserByID(String ID) {
		tracer.span("getUserByID") [
			setTag("ID", ID)
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.idsQuery().addIds(ID))
			]
			val hit = client.search(new SearchRequest(#["mbti-user"], search)).getHits().map[gson.fromJson(sourceAsString, User)].findFirst[true]
			val found = hit !== null
			setTag("found", found)
			return hit
		]
	}

	def saveUser(User user) {
		tracer.span("saveUser") [
			setTag("user", user.toString())
			val json = gson.toJson(user)
			setTag("user.json", json)
			val request = new IndexRequest("mbti-user") => [
				id(user.getID().toString())
				type("json")
				source(json, XContentType.JSON)
			]
			client.index(request)
		]
	}

}
