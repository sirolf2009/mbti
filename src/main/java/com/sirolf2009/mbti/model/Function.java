package com.sirolf2009.mbti.model;

public enum Function {
	TE(FunctionType.THINKING), TI(FunctionType.THINKING),
	FE(FunctionType.FEELING), FI(FunctionType.FEELING),
	SE(FunctionType.SENSING), SI(FunctionType.SENSING),
	NE(FunctionType.INTUITION), NI(FunctionType.INTUITION);
	
	private final FunctionType functionType;
	
	private Function(FunctionType functionType) {
		this.functionType = functionType;
	}

	public FunctionType getFunctionType() {
		return functionType;
	}
}
