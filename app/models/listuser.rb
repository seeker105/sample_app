class Listuser < ActiveRecord::Base
  belongs_to :list
  has_one :selected_user, class_name: "User",
                            foreign_key: "id"

  validates_uniqueness_of :selected_user_id, :scope => :list




  def selected_user
    User.find(selected_user_id)
  end


end
