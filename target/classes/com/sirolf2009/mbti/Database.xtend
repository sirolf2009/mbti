package com.sirolf2009.mbti

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.sirolf2009.mbti.model.Question
import com.sirolf2009.mbti.model.QuestionJsonDeserializer
import org.apache.http.HttpHost
import org.elasticsearch.action.index.IndexRequest
import org.elasticsearch.client.RestClient
import org.elasticsearch.client.RestHighLevelClient
import org.elasticsearch.common.xcontent.XContentType
import java.util.UUID
import org.elasticsearch.search.builder.SearchSourceBuilder
import org.elasticsearch.index.query.QueryBuilders
import org.elasticsearch.action.search.SearchRequest

class Database {
	
	val RestHighLevelClient client
	val Gson gson
	
	new() {
		this(new HttpHost("localhost", 9200, "http"))
	}
	
	new(HttpHost... hosts) {
		this(new RestHighLevelClient(RestClient.builder(hosts)))
	}
	
	new(RestHighLevelClient client) {
		this.client = client
		this.gson = new GsonBuilder().registerTypeAdapter(Question, new QuestionJsonDeserializer()).create()
	}
	
	def getQuestion(String ID) {
		val search = new SearchSourceBuilder() => [
			query(QueryBuilders.termQuery("_id", ID))
		]
		client.search(new SearchRequest(#["mbti-question"], search)).getHits().map[gson.fromJson(getSourceAsString(), Question)].findFirst[true]
	}
	
	def saveQuestion(Question question) {
		val request = new IndexRequest("mbti-question") => [
			val json = gson.toJson(question)
			id(UUID.randomUUID().toString())
			type("json")
			println(json)
			source(json, XContentType.JSON)
		]
		client.index(request)
	}
	
}