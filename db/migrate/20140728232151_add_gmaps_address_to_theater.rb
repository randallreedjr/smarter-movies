class AddGmapsAddressToTheater < ActiveRecord::Migration
  def change
    add_column :theaters, :gmaps_address, :string
  end
end
