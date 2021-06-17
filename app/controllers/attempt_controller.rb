class AttemptController < ApplicationController
  def create    
    #url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=linux&difficulty=Easy&limit=10"
    #response = RestClient.get(url)    
    

    difficulty = params[:difficulty]
    topics = []

    begin 
        if params[:Linux]=="Linux"
          url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=linux&difficulty=#{difficulty}&limit=10"
          response = RestClient.get(url)
          questions1 = JSON.parse(response)      
          topics << "Linux"   
        end

        if params[:DevOps]=="DevOps"
          url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=devops&difficulty=#{difficulty}&limit=10"
          response = RestClient.get(url)
          questions2 = JSON.parse(response) 
          topics << "DevOps"   
        end


        if params[:Programming]=="Programming"
          url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=code&difficulty=#{difficulty}&limit=10"
          response = RestClient.get(url)
          questions3 = JSON.parse(response) 
          topics << "Programming"  
        end

        if params[:Docker]=="Docker"
          url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=docker&difficulty=#{difficulty}&limit=10"
          response = RestClient.get(url)
          questions4 = JSON.parse(response) 
          topics << "Docker"  
        end
      
      questions_json = []
      unless questions1.nil? 
        questions_json = questions_json + questions1
      end
      unless questions2.nil? 
        questions_json = questions_json + questions2
      end

      unless questions3.nil? 
        questions_json = questions_json + questions3
      end
      unless questions4.nil? 
        questions_json = questions_json + questions4
      end

    rescue
      response = File.read(Rails.root.join('quiz.json'))
      questions_json = JSON.parse(response) 
    end

    if params[:commit] == "Start Quiz"
      question_count = params[:question_count].to_i
      session[:question_count] = question_count    
      @questions = questions_json.shuffle.each{|x|}.first(question_count)
      question_ids = @questions.map{|question| question['id']}
    elsif params[:commit] == "Reload"
      question_count = session[:question_count].to_i
      questions_json = Attempt.find(params[:prev_id]).questions_json
      @questions = questions_json.shuffle.each{|x|}.first(question_count)      
      question_ids = @questions.map{|question| question['id']}
    else       
      question_count = session[:question_count].to_i
      question_ids = Attempt.find(params[:prev_id]).question_ids
      questions_json = Attempt.find(params[:prev_id]).questions_json
      puts 'hihi'
      puts questions_json
      @questions = question_ids.map{|question_id| questions_json.find{|q| q['id'].to_s==question_id.to_s}}
    end

    
    @attempt = Attempt.new()
    @attempt.question_ids = question_ids
    @attempt.questions_json = questions_json
    @attempt.difficulty = difficulty
    @attempt.topics = topics
    @attempt.save!

    session[:attempt_ids] ||= []
    session[:attempt_ids] << @attempt.id    
    session[:user_answers] = {}
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

    current_question = @questions[@attempt.current_question_index]    
    
    unless current_question.nil?
      expected_answer = [current_question["correct_answers"]["answer_a_correct"].downcase=="true", 
                          current_question["correct_answers"]["answer_b_correct"].downcase=="true", 
                          current_question["correct_answers"]["answer_c_correct"].downcase=="true", 
                          current_question["correct_answers"]["answer_d_correct"].downcase=="true", 
                          current_question["correct_answers"]["answer_e_correct"].downcase=="true", 
                          current_question["correct_answers"]["answer_f_correct"].downcase=="true"]
      count_answer = 0                    
      expected_answer.each do |answer|
        if answer
          count_answer = count_answer + 1
        end
      end
      @is_multiple_answer = count_answer>1
    end

    session[:user_answers] ||= {}
    @prev_user_answer = session[:user_answers][@attempt.current_question_index.to_s] || [false, false, false, false, false, false]
    puts 'hihi'
    puts session[:user_answers]
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
    expected_answer = [current_question["correct_answers"]["answer_a_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_b_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_c_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_d_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_e_correct"].downcase=="true", 
                        current_question["correct_answers"]["answer_f_correct"].downcase=="true"]
    count_answer = 0                    
    expected_answer.each do |answer|
      if answer
        count_answer = count_answer + 1
      end
    end
    is_multiple_answer = count_answer>1
    
    if is_multiple_answer
      user_answer = [params[:answer_a] == 'answer_a', params[:answer_b] =='answer_b', params[:answer_c] =='answer_c', params[:answer_d] =='answer_d', params[:answer_e] =='answer_e', params[:answer_f] =='answer_f']
    else
      user_answer = [answer == 'answer_a', answer =='answer_b', answer =='answer_c', answer =='answer_d', answer =='answer_e', answer =='answer_f']
    end    
    
    session[:user_answers] ||= {}

    @prev_user_answer = session[:user_answers][@attempt.current_question_index.to_s] || [false, false, false, false, false, false]
    puts 'hihi'
    puts session[:user_answers]
    if user_answer == expected_answer && @prev_user_answer != expected_answer
      @attempt.result = @attempt.result + 1
    elsif user_answer != expected_answer && @prev_user_answer == expected_answer
      @attempt.result = @attempt.result - 1
    end
        
    session[:user_answers][@attempt.current_question_index.to_s] = user_answer
    puts 'haha'
    puts session[:user_answers]
    if params[:commit] == 'Next' || params[:commit] == 'Submit'
      @attempt.current_question_index = @attempt.current_question_index + 1    
    else
      @attempt.current_question_index = @attempt.current_question_index - 1    
    end

    @attempt.save

    redirect_to attempt_url(id: @attempt.id)
  end

  def index
    @attempts = Attempt.all.sort_by{|a| a.updated_at}.reverse!
  end
end
