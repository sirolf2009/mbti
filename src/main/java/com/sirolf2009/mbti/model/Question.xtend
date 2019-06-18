package com.sirolf2009.mbti.model

import com.sirolf2009.util.GSonDTO
import java.util.Date
import org.eclipse.xtend.lib.annotations.Data
import java.util.List

@Data @GSonDTO class Question {
	
	Date created
	String title
	String description
	List<Function> options
	Function correctAnswer
	int upvotes
	int downvotes
	
}