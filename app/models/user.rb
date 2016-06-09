class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token, :state
  before_save   :downcase_email
  before_create :create_activation_digest
  #  this is the first time i've set up an accessor without
  # in some way explicitly defining the variable as either an instance variable
  # or a table column. How exactly does this work? Is it created in the `remember` method?
  has_many :active_relationships, class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                 dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                    foreign_key: "followed_id",
                                    dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_secure_password

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 255}, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: {case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def organizations
    service.organizations(self)
  end

  def service
    @service ||= GithubService.new
  end


  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # could you also define this def self.new_token? YES
  def User.new_token
    SecureRandom.urlsafe_base64
  end


  def remember
    #  ruby defines this as a an attribute/variable of the object
    # even though the object has no such attribute previously defined?
    self.remember_token = User.new_token
    #  an attr_reader can be called in the instance it was defined in. Do you need to use
    # User.digest here instead of just `digest` to let the program know it's a class method?
    # Wouldn't the  method be found as Ruby works it's way up the inheritance chain?
    update_attribute(:remember_digest, User.digest(remember_token))
    #  when i view the cookie in the browser it looks like the remember_token is visible
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

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns a user's status feed.
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # Follows a user.
def follow(other_user)
  active_relationships.create(followed_id: other_user.id)
end

# Unfollows a user.
def unfollow(other_user)
  active_relationships.find_by(followed_id: other_user.id).destroy
end

# Returns true if the current user is following the other user.
def following?(other_user)
  following.include?(other_user)
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
