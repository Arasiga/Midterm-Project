class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |p|
      p.string :name
      p.timestamps
    end

    create_table :memberships do |m|
      m.references :user
      m.references :project
      m.boolean :is_admin
      m.timestamps
    end
  end
end
