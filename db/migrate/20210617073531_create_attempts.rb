class CreateAttempts < ActiveRecord::Migration[5.2]
  def change
    create_table :attempts do |t|
      t.string :question_ids, array: true, default: []
      t.integer :result, default: 0
      t.integer :current_question_index, default: 0
      t.timestamps
    end
  end
end
