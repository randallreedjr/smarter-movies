class RemoveGmapsAddressFromTheater < ActiveRecord::Migration
  def change
    remove_column :theaters, :gmaps_address
  end
end
