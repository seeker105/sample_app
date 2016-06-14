class Directmessage < ActiveRecord::Base
  has_one :sender, class_name: "User",
                   foreign_key: "id"
  has_one :receiver, class_name: "User",
                     foreign_key: "id"
end
