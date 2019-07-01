package com.sirolf2009.mbti.model;

public enum QuestionCategory {

	IDENTIFYING_FUNCTIONS("Identifying Functions", 1), IDENTIFYING_FUNCTION_AXES("Identifying Function Axes", 2), IDENTIFYING_INTERACTION_STYLES("Identifying Interaction Styles", 3), IDENTIFYING_TYPES("Identifying Types", 4);
	
	private final String humanReadable;
	private final int order;
	
	private QuestionCategory(String humanReadable, int order) {
		this.humanReadable = humanReadable;
		this.order = order;
	}
	
	public String getHumanReadable() {
		return humanReadable;
	}
	
	public int getOrder() {
		return order;
	}
	
}
