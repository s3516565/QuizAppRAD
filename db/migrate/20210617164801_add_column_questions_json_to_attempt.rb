class AddColumnQuestionsJsonToAttempt < ActiveRecord::Migration[5.2]
  def change
    add_column :attempts, :questions_json, :json
  end
end
