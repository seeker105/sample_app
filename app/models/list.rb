class List < ActiveRecord::Base
  belongs_to :owner, class_name: "User",
                     foreign_key: "owner_id"
  has_many :listusers
  has_many :selected_users, through: "listusers",
                            class_name: "User",
                            foreign_key: "selected_user_id"
end
