package com.sirolf2009.mbti;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.sirolf2009.mbti.model.Question;
import com.sirolf2009.mbti.model.QuestionJsonDeserializer;
import java.util.UUID;
import org.apache.http.HttpHost;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.common.xcontent.XContentType;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;

@SuppressWarnings("all")
public class Database {
  private final RestHighLevelClient client;
  
  private final Gson gson;
  
  public Database() {
    this(new HttpHost("localhost", 9200, "http"));
  }
  
  public Database(final HttpHost... hosts) {
    this(new RestHighLevelClient(RestClient.builder(hosts)));
  }
  
  public Database(final RestHighLevelClient client) {
    this.client = client;
    GsonBuilder _gsonBuilder = new GsonBuilder();
    QuestionJsonDeserializer _questionJsonDeserializer = new QuestionJsonDeserializer();
    this.gson = _gsonBuilder.registerTypeAdapter(Question.class, _questionJsonDeserializer).create();
  }
  
  public Question getQuestion(final String ID) {
    try {
      Question _xblockexpression = null;
      {
        SearchSourceBuilder _searchSourceBuilder = new SearchSourceBuilder();
        final Procedure1<SearchSourceBuilder> _function = (SearchSourceBuilder it) -> {
          it.query(QueryBuilders.termQuery("_id", ID));
        };
        final SearchSourceBuilder search = ObjectExtensions.<SearchSourceBuilder>operator_doubleArrow(_searchSourceBuilder, _function);
        SearchRequest _searchRequest = new SearchRequest(new String[] { "mbti-question" }, search);
        final Function1<SearchHit, Question> _function_1 = (SearchHit it) -> {
          return this.gson.<Question>fromJson(it.getSourceAsString(), Question.class);
        };
        final Function1<Question, Boolean> _function_2 = (Question it) -> {
          return Boolean.valueOf(true);
        };
        _xblockexpression = IterableExtensions.<Question>findFirst(IterableExtensions.<SearchHit, Question>map(this.client.search(_searchRequest).getHits(), _function_1), _function_2);
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public IndexResponse saveQuestion(final Question question) {
    try {
      IndexResponse _xblockexpression = null;
      {
        IndexRequest _indexRequest = new IndexRequest("mbti-question");
        final Procedure1<IndexRequest> _function = (IndexRequest it) -> {
          final String json = this.gson.toJson(question);
          it.id(UUID.randomUUID().toString());
          it.type("json");
          InputOutput.<String>println(json);
          it.source(json, XContentType.JSON);
        };
        final IndexRequest request = ObjectExtensions.<IndexRequest>operator_doubleArrow(_indexRequest, _function);
        _xblockexpression = this.client.index(request);
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
