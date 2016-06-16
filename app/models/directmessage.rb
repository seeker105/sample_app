class Directmessage < ActiveRecord::Base
  belongs_to :sender, class_name: "User",
                      foreign_key: "id"
  has_one :receiver, class_name: "User",
                     foreign_key: "id"
  validates :content, presence: true

  def sender
    User.find_by(id: sender_id)
  end

  def receiver
    User.find_by(id: receiver_id)
  end
end
