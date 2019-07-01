package com.sirolf2009.mbti.model

import com.sirolf2009.util.GSonDTO
import java.util.Date
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

@Data @GSonDTO class Attempt {
	
	val UUID ID
	val UUID userID
	val UUID questionID
	val int chosenAnswer
	val Date timestamp
	
}