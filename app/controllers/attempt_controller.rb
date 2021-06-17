class AttemptController < ApplicationController
  def create    
    #url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=linux&difficulty=Easy&limit=10"
    #response = RestClient.get(url)    
    
    begin 
        if params[:Linux]=="Linux"
          url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=linux&difficulty=Easy&limit=10"
          response = RestClient.get(url)
          @questions1 = JSON.parse(response)         
        end

        if params[:DevOps]=="DevOps"
          url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=devops&difficulty=Easy&limit=10"
          response = RestClient.get(url)
          @questions2 = JSON.parse(response) 
        end


        if params[:Programming]=="Programming"
          url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=code&difficulty=Easy&limit=10"
          response = RestClient.get(url)
          @questions3 = JSON.parse(response) 
        end

        if params[:Docker]=="Docker"
          url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=docker&difficulty=Easy&limit=10"
          response = RestClient.get(url)
          @questions4 = JSON.parse(response) 
        end
      
      @questions = []
      unless @questions1.nil? 
        @questions = @questions + @questions1
      end
      unless @questions2.nil? 
        @questions = @questions + @questions2
      end

      unless @questions3.nil? 
        @questions = @questions + @questions3
      end
      unless @questions4.nil? 
        @questions = @questions + @questions4
      end

    rescue
      response = File.read(Rails.root.join('quiz.json'))
      @questions = JSON.parse(response) 
    end

    if params[:commit] == "Start Quiz"
      question_count = params[:question_count].to_i
      session[:question_count] = question_count    
    else
      puts 'hihi'
      puts session[:question_count]
      question_count = session[:question_count].to_i
      @questions = Attempt.find(params[:prev_id]).questions_json
    end

    @questions = @questions.shuffle.each{|x|}.first(question_count)
    @attempt = Attempt.new()
    @attempt.question_ids = @questions.map{|question| question['id']}
    @attempt.questions_json = @questions
    @attempt.save!

    session[:attempt_ids] ||= []
    session[:attempt_ids] << @attempt.id    
    redirect_to attempt_url(id: @attempt.id)
  end

  def show        
    id = params[:id]
      
    @attempt = Attempt.find(id)
    question_pool = @attempt.questions_json
    @questions = []
    question_pool.each do |question|
      if @attempt.question_ids.include? question['id'].to_s
        @questions << question
      end
    end
    @last_five_attempts = session[:attempt_ids].last(5).map{|i| Attempt.find(i)}
  end

  def update
    id = params[:id]
    answer = params[:answers]
    @attempt = Attempt.find(id)

    
    question_pool = @attempt.questions_json
    @questions = []
    question_pool.each do |question|
      if @attempt.question_ids.include? question['id'].to_s
        @questions << question
      end
    end
    

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
