class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :slug, :unique => true
      t.boolean :default

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end

