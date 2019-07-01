package com.sirolf2009.mbti.model

import com.sirolf2009.util.GSonDTO
import java.util.Date
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

@Data @GSonDTO class Vote {
	
	val UUID ID
	val UUID userID
	val UUID questionID
	val boolean up
	val Date timestamp
	
}