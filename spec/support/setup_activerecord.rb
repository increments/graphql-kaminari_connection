# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

class CreateAllTables < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.migrate(:up)

class Post < ActiveRecord::Base
  validates :title, presence: true
end
