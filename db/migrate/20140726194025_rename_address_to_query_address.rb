class RenameAddressToQueryAddress < ActiveRecord::Migration
  def change
    rename_column :requests, :address, :query_address
  end
end
