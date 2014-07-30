class AddNormalizedNameToTheaters < ActiveRecord::Migration
  def change
    add_column :theaters, :normalized_name, :string
  end
end
