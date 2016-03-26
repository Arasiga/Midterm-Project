class Membership < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  validates_presence_of :user, :project
  validates_associated :user, :project
  validate :admin_check


  def no_current_admins
    self.project.memberships.reduce (true) do |no_admins, member|
      no_admins = false if member.is_admin
      no_admins
    end
  end


  def admin_check
    errors.add(:is_admin, "Project already has admin") if self.is_admin && !no_current_admins && self.project.admin != self.user
  end

end