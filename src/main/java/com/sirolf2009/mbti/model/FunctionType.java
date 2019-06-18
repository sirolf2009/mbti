package com.sirolf2009.mbti.model;

import java.util.Arrays;
import java.util.List;

public enum FunctionType {
	THINKING(Function.TE, Function.TI), FEELING(Function.FE, Function.FI), SENSING(Function.SE, Function.SI), INTUITION(Function.NE, Function.NI);
	
	private final List<Function> functions;
	
	private FunctionType(Function... functions) {
		this.functions = Arrays.asList(functions);
	}

	public List<Function> getFunctions() {
		return functions;
	}
}