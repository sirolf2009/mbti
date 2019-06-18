package com.sirolf2009.mbti.model

import com.sirolf2009.util.GSonDTO
import java.util.Date
import java.util.List
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

@Data @GSonDTO class Question {
	
	UUID ID
	String username
	Date created
	String title
	String description
	List<Function> options
	Function correctAnswer
	int upvotes
	int downvotes
	
}