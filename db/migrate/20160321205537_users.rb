class Users < ActiveRecord::Migration
  def change
    create_table :users do |u|
      u.string :first_name
      u.string :last_name
      u.string :country
      u.string :email
      u.string :username
      u.string :password
      u.string :repeat_password
      u.datetime :created_at
      u.datetime :updated_at
    end
  end
end
