class QuizController < ApplicationController
  def index    
    #url = "https://quizapi.io/api/v1/questions?apiKey=ELfM6cBcbI1M87LAn8nv4uCoB90fGDyYY2hditsI&category=linux&difficulty=Easy&limit=10"
    #response = RestClient.get(url)    
    response = File.read(Rails.root.join('quiz.json'))
    @questions = JSON.parse(response)   
    @attempt = Attempt.new()
    @attempt.question_ids = @questions.map{|question| question['id']}
    @attempt.save!
  end
end
