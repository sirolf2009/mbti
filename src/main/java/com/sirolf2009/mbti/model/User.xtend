package com.sirolf2009.mbti.model

import com.sirolf2009.util.GSonDTO
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

@Data @GSonDTO class User {
	
	val UUID ID
	val Profile profile
	val UUID salt
	val String password
	
}