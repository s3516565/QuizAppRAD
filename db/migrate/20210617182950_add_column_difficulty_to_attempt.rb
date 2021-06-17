class AddColumnDifficultyToAttempt < ActiveRecord::Migration[5.2]
  def change
    add_column :attempts, :difficulty, :string
  end
end
