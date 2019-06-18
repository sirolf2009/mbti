package com.sirolf2009.mbti.model;

import java.util.Arrays;
import java.util.List;

public enum FunctionPurpose {
	JUDGING(FunctionType.THINKING, FunctionType.FEELING), PERCEIVING(FunctionType.SENSING, FunctionType.INTUITION);
	
	private final List<FunctionType> functionTypes;
	
	private FunctionPurpose(FunctionType... functionTypes) {
		this.functionTypes = Arrays.asList(functionTypes);
	}

	public List<FunctionType> getFunctionTypes() {
		return functionTypes;
	}
}
