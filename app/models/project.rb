class Project < ActiveRecord::Base

  has_many :memberships
  has_many :users, :through => :memberships

  validates_presence_of :name
  validates :name, :uniqueness => true

  class InvalidUser < TypeError
    def initialize(msg="Invalid user")
    end
  end

  def set_admin(user)
    raise InvalidUser.new if !user.is_a?(User)
    raise InvalidUser.new("User is not in project") if !self.users.include?(user)
    required_membership = nil
    self.memberships.each do |member|
     required_membership = member if member.user == user
     member.update!(is_admin: false)
    end
    required_membership.update!(is_admin: true)
  end

  def admin
    self.memberships.reduce(nil) do |administrator, member|
      administrator = member.user if member.is_admin
      administrator
    end
  end


  def add(new_user)
    raise InvalidUser.new if !new_user.is_a?(User)
    raise InvalidUser.new("User is already in project") if self.users.include?(new_user)
    m = Membership.new(user: new_user, project: self, is_admin: false)
    m.save
  end
end