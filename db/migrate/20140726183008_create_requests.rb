class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :radius
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
