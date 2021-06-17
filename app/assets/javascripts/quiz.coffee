window.validateForm = (e) ->
  questionCount = $("#question_count").val()
  console.log(questionCount)  
  console.log(parseInt(questionCount))
  if parseInt(questionCount)>=4 && parseInt(questionCount)<=8    
    return true
  else
    console.log('false')
    e.preventDefault();
    return false

$(document).on('ajax:beforeSend', 'form#index-form', (e) -> 
  validateForm(e)
)


window.validateAnswer = (e) ->
  #questionCount = $("#question_count").value
  
  console.log('validate answer')
  if $('#answer_a').is(':checked') ||
         $('#answer_b').is(':checked') || 
         $('#answer_c').is(':checked') ||
         $('#answer_d').is(':checked') ||
         $('#answer_e').is(':checked') ||
         $('#answer_f').is(':checked')
    console.log('true')
    return true
  else
    console.log('false')
    e.preventDefault();
    return false

$(document).on('ajax:beforeSend', 'form#answer-form', (e) -> 
  validateAnswer(e)
)