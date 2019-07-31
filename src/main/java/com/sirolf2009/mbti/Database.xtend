package com.sirolf2009.mbti

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.sirolf2009.mbti.model.Attempt
import com.sirolf2009.mbti.model.AttemptJsonDeserializer
import com.sirolf2009.mbti.model.Profile
import com.sirolf2009.mbti.model.ProfileJsonDeserializer
import com.sirolf2009.mbti.model.Question
import com.sirolf2009.mbti.model.QuestionCategory
import com.sirolf2009.mbti.model.QuestionJsonDeserializer
import com.sirolf2009.mbti.model.User
import com.sirolf2009.mbti.model.UserJsonDeserializer
import com.sirolf2009.mbti.model.Vote
import io.opentracing.Tracer
import java.util.Date
import java.util.Optional
import java.util.UUID
import org.apache.http.HttpHost
import org.elasticsearch.action.admin.indices.create.CreateIndexRequest
import org.elasticsearch.action.admin.indices.get.GetIndexRequest
import org.elasticsearch.action.admin.indices.refresh.RefreshRequest
import org.elasticsearch.action.index.IndexRequest
import org.elasticsearch.action.search.SearchRequest
import org.elasticsearch.action.update.UpdateRequest
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
		val gsonBuilder = new GsonBuilder() => [
			registerTypeAdapter(Question, new QuestionJsonDeserializer())
			registerTypeAdapter(Profile, new ProfileJsonDeserializer())
			registerTypeAdapter(User, new UserJsonDeserializer())
			registerTypeAdapter(Attempt, new AttemptJsonDeserializer())
		]
		this.gson = gsonBuilder.create()
		tracer.span("setupDatabase") [
			#["mbti-user", "mbti-question", "mbti-attempt", "mbti-vote"].forEach [ index |
				tracer.span("checkIndex") [
					setTag("index", index)
					if(!client.indices().exists(new GetIndexRequest().indices(index))) {
						tracer.span("createIndex") [
							client.indices().create(new CreateIndexRequest(index)).acknowledged
						]
					}
				]
			]
		]
	}

	@Deprecated
	def getTopQuestions() {
		tracer.span("getTopQuestions") [
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.matchAllQuery())
			]
			client.search(new SearchRequest(#["mbti-question"], search)).getHits().map[gson.fromJson(getSourceAsString(), Question)].toList()
		]
	}

	def getQuestions(QuestionCategory category) {
		tracer.span("getQuestions") [
			setTag("category", category.toString())
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.matchQuery("questionCategory", category.toString()))
			]
			client.search(new SearchRequest(#["mbti-question"], search)).getHits().map[gson.fromJson(getSourceAsString(), Question)].toList()
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
			client.indices().refresh(new RefreshRequest("mbti-question"))
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
			return Optional.ofNullable(hit)
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

	def saveAttempt(Attempt attempt) {
		tracer.span("saveAttempt") [
			setTag("attempt", attempt.toString())
			val json = gson.toJson(attempt)
			setTag("attempt.json", json)
			val request = new IndexRequest("mbti-attempt") => [
				id(attempt.getID().toString())
				type("json")
				source(json, XContentType.JSON)
			]
			client.index(request)
		]
	}
	
	def getAttempts(UUID userID) {
		tracer.span("getAttempts") [
			setTag("userID", userID.toString())
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.matchQuery("userID", userID.toString()))
			]
			val hits = client.search(new SearchRequest(#["mbti-attempt"], search)).getHits().map[gson.fromJson(sourceAsString, Attempt)].toList()
			setTag("found", hits.size())
			return hits
		]
	}

	def updateVote(UUID voteID, boolean up) {
		tracer.span("updateVote") [
			setTag("voteID", voteID.toString())
			setTag("up", up)
			val update = new UpdateRequest("mbti-vote", "json", voteID.toString()).doc(#{
				"up" -> up,
				"timestamp" -> new Date()
			})
			client.update(update)
		]
	}

	def saveVote(Vote vote) {
		tracer.span("saveVote") [
			setTag("vote", vote.toString())
			val json = gson.toJson(vote)
			setTag("vote.json", json)
			val request = new IndexRequest("mbti-vote") => [
				id(vote.getID().toString())
				type("json")
				source(json, XContentType.JSON)
			]
			client.index(request)
		]
	}

	def getVote(UUID userID, UUID questionID) {
		tracer.span("getVote") [
			setTag("userID", userID.toString())
			setTag("questionID", questionID.toString())
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.boolQuery().must(QueryBuilders.matchQuery("userID", userID.toString())).filter(QueryBuilders.matchQuery("questionID", questionID.toString())))
			]
			val hit = client.search(new SearchRequest(#["mbti-vote"], search)).getHits().map[gson.fromJson(sourceAsString, Vote)].findFirst[true]
			val found = hit !== null
			setTag("found", found)
			return hit
		]
	}
	
	def getVotes(UUID questionID) {
		tracer.span("getVotes") [
			setTag("questionID", questionID.toString())
			val search = new SearchSourceBuilder() => [
				query(QueryBuilders.matchQuery("questionID", questionID.toString()))
			]
			val hits = client.search(new SearchRequest(#["mbti-vote"], search)).getHits().map[gson.fromJson(sourceAsString, Vote)].toList()
			setTag("found", hits.size())
			return hits
		]
	}

}
