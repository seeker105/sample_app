class AddIndexToListusers < ActiveRecord::Migration
  def change
    add_index :listusers, [:list_id, :selected_user_id], unique: true, name: 'by_list_and_user'
  end
end
