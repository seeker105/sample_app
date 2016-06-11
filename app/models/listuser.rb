class Listuser < ActiveRecord::Base
  belongs_to :list
  has_many :selected_users, class_name: "User",
                            foreign_key: "id"
end
