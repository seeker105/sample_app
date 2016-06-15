class AddContentToDirectmessages < ActiveRecord::Migration
  def change
    add_column :directmessages, :content, :string
  end
end
