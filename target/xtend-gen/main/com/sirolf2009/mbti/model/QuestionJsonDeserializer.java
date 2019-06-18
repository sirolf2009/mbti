package com.sirolf2009.mbti.model;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.sirolf2009.mbti.model.Question;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;

@SuppressWarnings("all")
public class QuestionJsonDeserializer implements JsonDeserializer<Question> {
  public Question deserialize(final JsonElement json, final Type typeOfT, final JsonDeserializationContext context) throws JsonParseException {
    JsonObject object = json.getAsJsonObject();
    java.util.Date created = context.deserialize(object.get("created"), java.util.Date.class);
    java.lang.String title = context.deserialize(object.get("title"), java.lang.String.class);
    java.lang.String description = context.deserialize(object.get("description"), java.lang.String.class);
    java.util.List options = context.deserialize(object.get("options"), new com.google.gson.reflect.TypeToken<java.util.List<com.sirolf2009.mbti.model.Function>>(){}.getType());
    com.sirolf2009.mbti.model.Function correctAnswer = context.deserialize(object.get("correctAnswer"), com.sirolf2009.mbti.model.Function.class);
    int upvotes = context.deserialize(object.get("upvotes"), int.class);
    int downvotes = context.deserialize(object.get("downvotes"), int.class);
    return new Question(created, title, description, options, correctAnswer, upvotes, downvotes);
  }
  
  public static void write(final Question dto, final File file) throws FileNotFoundException {
    try(PrintWriter out = new PrintWriter(file.getAbsolutePath())) {
    	out.println(new Gson().toJson(dto));
    }
  }
  
  public static Question read(final File file) throws IOException {
    Gson gson = new GsonBuilder().registerTypeAdapter(Question.class, new QuestionJsonDeserializer()).create();
    return gson.fromJson(new String(Files.readAllBytes(Paths.get(file.getAbsolutePath())), Charset.defaultCharset()), Question.class);
  }
}
