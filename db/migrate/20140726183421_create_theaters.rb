class CreateTheaters < ActiveRecord::Migration
  def change
    create_table :theaters do |t|
      t.string :name
      t.string :location
      t.float :rating

      t.timestamps
    end
  end
end
