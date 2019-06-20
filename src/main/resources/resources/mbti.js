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
	console.log(answers.length);
	for (var i = 0; i < answers.length; i++) {
		console.log(answers[i]);
		answers[i].id = "answer-"+i;
		var content = answers[i].children[0]
		content.children[0].name = "answer-"+i+"-text"
		content.children[1].name = "answer-"+i+"-correct"
		console.log("set answer-"+i)
	}
}

function addParamRow() {
	var clone = $('#params-0')[0].cloneNode(true);
	var paramRows = $('#params-tbody')[0].children;
	var lastRow = paramRows[paramRows.length - 1];
	var cloneChildren = clone.children;
	var lastRowChildren = lastRow.children;
	copyValues(cloneChildren, lastRowChildren);
    resetRow(lastRowChildren);
	paramRows[paramRows.length - 2].after(clone);
	setAllParamsAttr(paramRows);
}

function copyValues(cloneChildren, lastRowChildren) {
	for (var i = 0; i < cloneChildren.length - 1; i++) {
		var cloneInput = cloneChildren[i].children[0];
		var lastRowInput = lastRowChildren[i].children[0];
		if (cloneInput.type === "checkbox") {
			cloneInput.checked = lastRowInput.checked;
		} else {
			cloneInput.value = lastRowInput.value;
		}
    }
}

function resetRow(lastRowChildren) {
    for (var i = 0; i < lastRowChildren.length - 1; i++) {
		var input = lastRowChildren[i].children[0];
		input.value = "";
		if (input.type === "checkbox") {
			input.checked = false;
		}
    }
}

function setAllParamsAttr(paramRows) {
	for (var i = 0; i < paramRows.length - 1; i++) {
		paramRows[i].id = "params-" + i;
		var children = paramRows[i].children;
		children[0].children[0].name = "param-name-" + i;
		children[1].children[0].name = "param-type-" + i;
		children[2].children[0].name = "param-required-" + i;
	}
}

function addOutputRow() {
	var clone = $('#output-0')[0].cloneNode(true);
	var outputRows = $('#output-tbody')[0].children;
	var lastRow = outputRows[outputRows.length - 1];
	var cloneChildren = clone.children;
	var lastRowChildren = lastRow.children;
	copyValues(cloneChildren, lastRowChildren);
    resetRow(lastRowChildren);
	outputRows[outputRows.length - 2].after(clone);
	setAllOutputAttr(outputRows);
}

function setAllOutputAttr(outputRows) {
	for (var i = 0; i < outputRows.length - 1; i++) {
		outputRows[i].id = "output-" + i;
		var children = outputRows[i].children;
		children[0].children[0].name = "output-type-" + i;
		children[1].children[0].name = "output-provider-" + i;
		children[2].children[0].name = "output-location-" + i;
		children[3].children[0].name = "output-source-" + i;
		children[4].children[0].name = "output-phase-" + i;
		children[5].children[0].name = "output-interval-" + i;
	}
}

$("#params-tbody").on('click', '.button.red', handleMinimumRows("#params-tbody"));

$("#output-tbody").on('click', '.button.red', handleMinimumRows("#output-tbody"));

function handleMinimumRows(tbody) {
    return function() {
        if ($(tbody)[0].children.length > 2) {
            $(this).closest('tr').remove();
            if (tbody === "#params-tbody") {
                setAllParamsAttr($('#params-tbody')[0].children);
            } else {
                setAllOutputAttr($('#output-tbody')[0].children);
            }
        } else {
            $('.ui.basic.modal').modal('show');
        }
    }    
}

$("#params-tbody").on('click', '.button.blue', copyRow("#params-tbody"));

$("#output-tbody").on('click', '.button.blue', copyRow("#output-tbody"));

function copyRow(tbody) {
    return function() {
		var clone = $(this).closest('tr')[0].cloneNode(true);
		$(this).closest('tr').after(clone);
		if (tbody === "#params-tbody") {
			setAllParamsAttr($('#params-tbody')[0].children);
		} else {
			setAllOutputAttr($('#output-tbody')[0].children);
		}
    }    
}

$("#output-tbody").on('click', '.button.default', function() {
	window.location.href = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";
});