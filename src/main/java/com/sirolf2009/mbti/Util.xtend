package com.sirolf2009.mbti

import java.io.UnsupportedEncodingException
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class Util {

	def static String hex(byte[] array) {
		array.map[
			Integer.toHexString(bitwiseAnd(0xFF).bitwiseOr(0x100)).substring(1, 3)
		].join()
	}

	def static String md5Hex(String message) {
		try {
			var md = MessageDigest.getInstance("MD5")
			return hex(md.digest(message.getBytes("CP1252")))
		} catch(NoSuchAlgorithmException e) {
		} catch(UnsupportedEncodingException e) {
		}
		return null
	}

}
