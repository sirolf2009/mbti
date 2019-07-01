package com.sirolf2009.mbti.model

import com.sirolf2009.util.GSonDTO
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.mbti.Util

@Data @GSonDTO class Profile {
	
	val String username
	val String email
	val Type type
	
	def getType() {
		return Optional.ofNullable(type)
	}
	
	
	def getGravatar() {
		return Util.md5Hex(email)
	}
	
}