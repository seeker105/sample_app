class CreateDirectmessages < ActiveRecord::Migration
  def change
    create_table :directmessages do |t|
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps null: false
    end
    add_index :directmessages, :sender_id
    add_index :directmessages, :receiver_id
  end
end
