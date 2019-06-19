package com.sirolf2009.mbti.model;

import static com.sirolf2009.mbti.model.Function.*;

public enum Type {
	
	ENTP("Debater", NE, TI, FE, SI),
	ENTJ("Commander", TE, NI, SE, FI),
	ENFJ("Protagonist", FE, NI, SE, TI),
	ENFP("Campaigner", NE, FI, TE, SI),
	ESTJ("Executive", TE, SI, NE, FI),
	ESTP("Entrepeneur", SE, TI, FE, NI),
	ESFJ("Consul", FE, SI, NE, TI),
	ESFP("Entertainer", SE, FI, TE, NI),
	INTP("Logician", TI, NE, SI, FE),
	INTJ("Architect", NI, TE, FI, SE),
	INFJ("Advocate", NI, FE, TI, SE),
	INFP("Mediator", FI, NE, SI, TE),
	ISTJ("Logistician", SI, TE, TI, NE),
	ISTP("Virtuoso", TI, SE, NI, FE),
	ISFJ("Defender", SI, FE, TI, NE),
	ISFP("Adventurer", FI, SE, NI, TE);
	
	private final String title;
	private final Function dominant;
	private final Function auxiliary;
	private final Function tertiary;
	private final Function inferior;
	
	private Type(String title, Function dominant, Function auxiliary, Function tertiary, Function inferior) {
		this.title = title;
		this.dominant = dominant;
		this.auxiliary = auxiliary;
		this.tertiary = tertiary;
		this.inferior = inferior;
	}

	public String getTitle() {
		return title;
	}

	public Function getDominant() {
		return dominant;
	}

	public Function getAuxiliary() {
		return auxiliary;
	}

	public Function getTertiary() {
		return tertiary;
	}

	public Function getInferior() {
		return inferior;
	}

}
