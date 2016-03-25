

class User < ActiveRecord::Base

  has_many :projects

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :country
  validates_presence_of :email #validate format later
  validates_presence_of :username
  validates_presence_of :password
  validates_presence_of :repeat_password

  validates_uniqueness_of :username

  validate :check_password_and_repeat_password

  def check_password_and_repeat_password
    errors.add(:repeat_password, "must be the same as password") if repeat_password != password
  end

  validates_format_of :email, :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i


end