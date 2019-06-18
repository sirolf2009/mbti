package com.sirolf2009.mbti.model;

import com.sirolf2009.mbti.model.Function;
import com.sirolf2009.util.GSonDTO;
import java.util.Date;
import java.util.List;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@GSonDTO
@SuppressWarnings("all")
public class Question {
  private final Date created;
  
  private final String title;
  
  private final String description;
  
  private final List<Function> options;
  
  private final Function correctAnswer;
  
  private final int upvotes;
  
  private final int downvotes;
  
  public Question(final Date created, final String title, final String description, final List<Function> options, final Function correctAnswer, final int upvotes, final int downvotes) {
    super();
    this.created = created;
    this.title = title;
    this.description = description;
    this.options = options;
    this.correctAnswer = correctAnswer;
    this.upvotes = upvotes;
    this.downvotes = downvotes;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((this.created== null) ? 0 : this.created.hashCode());
    result = prime * result + ((this.title== null) ? 0 : this.title.hashCode());
    result = prime * result + ((this.description== null) ? 0 : this.description.hashCode());
    result = prime * result + ((this.options== null) ? 0 : this.options.hashCode());
    result = prime * result + ((this.correctAnswer== null) ? 0 : this.correctAnswer.hashCode());
    result = prime * result + this.upvotes;
    return prime * result + this.downvotes;
  }
  
  @Override
  @Pure
  public boolean equals(final Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Question other = (Question) obj;
    if (this.created == null) {
      if (other.created != null)
        return false;
    } else if (!this.created.equals(other.created))
      return false;
    if (this.title == null) {
      if (other.title != null)
        return false;
    } else if (!this.title.equals(other.title))
      return false;
    if (this.description == null) {
      if (other.description != null)
        return false;
    } else if (!this.description.equals(other.description))
      return false;
    if (this.options == null) {
      if (other.options != null)
        return false;
    } else if (!this.options.equals(other.options))
      return false;
    if (this.correctAnswer == null) {
      if (other.correctAnswer != null)
        return false;
    } else if (!this.correctAnswer.equals(other.correctAnswer))
      return false;
    if (other.upvotes != this.upvotes)
      return false;
    if (other.downvotes != this.downvotes)
      return false;
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("created", this.created);
    b.add("title", this.title);
    b.add("description", this.description);
    b.add("options", this.options);
    b.add("correctAnswer", this.correctAnswer);
    b.add("upvotes", this.upvotes);
    b.add("downvotes", this.downvotes);
    return b.toString();
  }
  
  @Pure
  public Date getCreated() {
    return this.created;
  }
  
  @Pure
  public String getTitle() {
    return this.title;
  }
  
  @Pure
  public String getDescription() {
    return this.description;
  }
  
  @Pure
  public List<Function> getOptions() {
    return this.options;
  }
  
  @Pure
  public Function getCorrectAnswer() {
    return this.correctAnswer;
  }
  
  @Pure
  public int getUpvotes() {
    return this.upvotes;
  }
  
  @Pure
  public int getDownvotes() {
    return this.downvotes;
  }
}
