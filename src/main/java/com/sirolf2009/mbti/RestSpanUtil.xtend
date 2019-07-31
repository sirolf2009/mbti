package com.sirolf2009.mbti

import com.sirolf2009.util.SpanUtil
import com.sirolf2009.util.SpanUtil.Function_WithExceptions
import io.opentracing.Span
import io.opentracing.Tracer
import java.util.function.BiConsumer
import java.util.function.Consumer
import spark.Request

class RestSpanUtil {

	def static <R, E extends Exception> R span(Tracer tracer, String name, Request req, Function_WithExceptions<Span, R, E> scopeConsumer) throws E {
		return SpanUtil.span(tracer, name) [
			setHttpTags(req)
			return scopeConsumer.apply(it)
		]
	}

	def static <R, E extends Exception> R span(Tracer tracer, String name, Request req, Function_WithExceptions<Span, R, E> spanFunction, BiConsumer<Span, Throwable> errorConsumer) throws E {
		return SpanUtil.span(tracer, name, [
			setHttpTags(req)
			return spanFunction.apply(it)
		], errorConsumer)
	}

	def static void span(Tracer tracer, String name, Request req, Consumer<Span> scopeConsumer) {
		SpanUtil.span(tracer, name) [
			setHttpTags(req)
			scopeConsumer.accept(it)
		]
	}

	def static void span(Tracer tracer, String name, Request req, Consumer<Span> scopeConsumer, BiConsumer<Span, Throwable> errorConsumer) {
		SpanUtil.span(tracer, name, [
			setHttpTags(req)
			scopeConsumer.accept(it)
		], errorConsumer)
	}

	def static setHttpTags(Span span, Request req) {
		req.headers().filter[!contains("password")].forEach[span.setTag('''header.«it»''', req.headers(it))]
		req.queryParams().filter[!contains("password")].forEach[span.setTag('''queryParam.«it»''', req.queryParams(it))]
		span.setTag("body", req.body())
		span.setTag("ip", req.ip())
		LoginController.getUserID(req).ifPresent[span.setTag("userID", toString())]
	}

}
