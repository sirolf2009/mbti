function addAnswer() {
	var clone = $('#answerTemplate')[0].cloneNode(true);
	var answers = $('#answers')[0].children;
	var lastAnswer = answers[answers.length - 1];
	var cloneChildren = clone.children;
	var lastAnswerChildren = lastAnswer.children;
	answers[answers.length - 1].after(clone);
	fixAnswerIDS(answers);
}

function fixAnswerIDS(answers) {
	for (var i = 0; i < answers.length; i++) {
		answers[i].id = "answer-"+i;
		var content = answers[i].children[0]
		content.children[0].name = "answer-"+i+"-text"
		content.children[1].name = "correct-answer"
		content.children[1].id = "answer-"+i+"-correct"
		content.children[1].value = "answer-"+i+"-correct"
		content.children[2].for = "answer-"+i+"-correct"
	}
}

function vote(questionID, up) {
  (async () => {
	  const rawResponse = await fetch('/vote/question', {
	    method: 'POST',
	    headers: {
	      'Accept': 'application/json',
	      'Content-Type': 'application/json'
	    },
	    body: JSON.stringify({
	    	questionID: questionID,
	    	up: up
	    })
	  });
	  const content = await rawResponse;
	})();
}

$(document).ready(function() {

	// fix main menu to page on passing
	$('.main.menu').visibility({
		type : 'fixed'
	});
	$('.overlay').visibility({
		type : 'fixed',
		offset : 80
	});

	// lazy load images
	$('.image').visibility({
		type : 'image',
		transition : 'vertical flip in',
		duration : 500
	});

	// show dropdown on hover
	$('.main.menu  .ui.dropdown').dropdown({
		on : 'hover'
	});

	$(".rating").rating();
	$(".rating").rating('disable')
});