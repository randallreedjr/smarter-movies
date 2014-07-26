class AddAddressToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :address, :string
  end
end
