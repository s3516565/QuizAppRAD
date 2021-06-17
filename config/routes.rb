Rails.application.routes.draw do  
  root             'quiz#index'
  post '/'  => 'attempt#create'
  get 'attempt/:id' => 'attempt#show', as: 'attempt'
  post 'attempt/' => 'attempt#update'
end
