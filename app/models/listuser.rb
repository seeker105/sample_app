class Listuser < ActiveRecord::Base
  belongs_to :list
  belongs_to :selected_user, class_name: "User",
                            foreign_key: "id"






  def selected_user
    User.find(selected_user_id)
  end


end
