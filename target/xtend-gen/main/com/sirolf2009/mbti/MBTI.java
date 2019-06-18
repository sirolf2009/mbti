package com.sirolf2009.mbti;

import com.sirolf2009.mbti.Database;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import spark.Request;
import spark.Response;
import spark.Route;
import spark.Spark;

@SuppressWarnings("all")
public class MBTI {
  public static void main(final String[] args) {
    final Database db = new Database();
    Spark.staticFileLocation("/resources");
    final Route _function = (Request $0, Response $1) -> {
      return IterableExtensions.join(Files.readAllLines(Paths.get("src/main/resources/Sticky_Example.html")), "\n");
    };
    Spark.get("/", _function);
    final Route _function_1 = (Request $0, Response $1) -> {
      return IterableExtensions.join(Files.readAllLines(Paths.get("src/main/resources/question.html")), "\n");
    };
    Spark.get("/question", _function_1);
  }
}
