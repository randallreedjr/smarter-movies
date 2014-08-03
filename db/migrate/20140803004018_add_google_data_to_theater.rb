class AddGoogleDataToTheater < ActiveRecord::Migration
  def change
    add_column :theaters, :lat, :float
    add_column :theaters, :lng, :float
    add_column :theaters, :photo_reference, :text
    add_column :theaters, :place_id, :string
  end
end
