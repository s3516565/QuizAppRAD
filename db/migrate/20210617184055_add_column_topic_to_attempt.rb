class AddColumnTopicToAttempt < ActiveRecord::Migration[5.2]
  def change
    add_column :attempts, :topics, :string, array: true, default: []
  end
end
