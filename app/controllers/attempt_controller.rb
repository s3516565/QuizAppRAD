class AttemptController < ApplicationController
  def create    
    #url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=linux&difficulty=Easy&limit=10"
    #response = RestClient.get(url)    
    response = File.read(Rails.root.join('quiz.json'))
    @questions = JSON.parse(response)   
    @attempt = Attempt.new()
    @attempt.question_ids = @questions.map{|question| question['id']}
    @attempt.save!
    redirect_to attempt_url(id: @attempt.id)
  end

  def show        
    id = params[:id]
    response = File.read(Rails.root.join('quiz.json'))
    @questions = JSON.parse(response)   
    @attempt = Attempt.find(id)
  end

  def update
    id = params[:id]
    puts params
    answer = params[:answers]

    response = File.read(Rails.root.join('quiz.json'))
    @questions = JSON.parse(response)
    @attempt = Attempt.find(id)

    current_question = @questions[@attempt.current_question_index]
    user_answer = [answer == 'answer_a', answer =='answer_b', answer =='answer_c', answer =='answer_d', answer =='answer_e', answer =='answer_f']
    expected_answer = [current_question["correct_answers"]["answer_a_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_b_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_c_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_d_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_e_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_f_correct"].downcase=="true"]
    
    if user_answer == expected_answer
      @attempt.result = @attempt.result + 1
    end
    
    @attempt.current_question_index = @attempt.current_question_index + 1    
    @attempt.save

    redirect_to attempt_url(id: @attempt.id)
  end
end
