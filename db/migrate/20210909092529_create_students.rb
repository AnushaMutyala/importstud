class CreateStudents < ActiveRecord::Migration[5.2]
  def change
    create_table :students do |t|
      t.string :name
      t.integer :roll_no
      t.integer :marks1
      t.integer :marks2
      t.integer :marks3
      t.integer :avg

      t.timestamps
    end
  end
end
