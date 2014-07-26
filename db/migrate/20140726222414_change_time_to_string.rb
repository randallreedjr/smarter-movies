class ChangeTimeToString < ActiveRecord::Migration
  def up
    change_column :showtimes, :time, :string
  end
  def down
    change_column :showtimes, :time, :datetime
  end
end
