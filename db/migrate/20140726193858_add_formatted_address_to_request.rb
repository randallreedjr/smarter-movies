class AddFormattedAddressToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :formatted_address, :string
  end
end
