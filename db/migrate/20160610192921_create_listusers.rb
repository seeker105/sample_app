class CreateListusers < ActiveRecord::Migration
  def change
    create_table :listusers do |t|
      t.references :list, index: true, foreign_key: true
      t.integer :selected_user_id
    end
    add_index :listusers, :selected_user_id
  end
end
