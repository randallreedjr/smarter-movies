class AddThreeDToShowtimes < ActiveRecord::Migration
  def change
    add_column :showtimes, :three_d, :boolean
  end
end
