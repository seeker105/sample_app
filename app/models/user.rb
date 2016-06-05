class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token
  before_save   :downcase_email
  before_create :create_activation_digest
  # TODO this is the first time i've set up an accessor without
  # in some way explicitly defining the variable as either an instance variable
  # or a table column. How exactly does this work? Is it created in the `remember` method?

  has_secure_password

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 255}, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: {case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # TODO could you also define this def self.new_token ?
  def User.new_token
    SecureRandom.urlsafe_base64
  end


  def remember
    # TODO ruby defines this as a an attribute/variable of the object
    # even though the object has no such attribute previously defined?
    self.remember_token = User.new_token
    # TODO an attr_reader can be called in the instance it was defined in. Do you need to use
    # User.digest here instead of just `digest` to let the program know it's a class method?
    # Wouldn't the  method be found as Ruby works it's way up the inheritance chain?
    update_attribute(:remember_digest, User.digest(remember_token))
    # TODO when i view the cookie in the browser it looks like the remember_token is visible
    # in plain text. I thought the cookie was supposed to be encrypted? Am I viewing the decrypted
    # version because I'm looking at it on my machine?
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end
  
  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private
    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
