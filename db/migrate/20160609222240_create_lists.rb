class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.integer :owner_id
    end
    add_index :lists, :owner_id
  end
end
