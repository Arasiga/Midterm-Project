class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |p|
      p.references :users
      p.string :title
      p.string :description
      p.datetime :created_at
      p.datetime :udpated_at
    end
  end
end
