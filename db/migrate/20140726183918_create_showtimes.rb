class CreateShowtimes < ActiveRecord::Migration
  def change
    create_table :showtimes do |t|
      t.string :fandango_url
      t.datetime :time
      t.references :theater, index: true
      t.references :movie, index: true

      t.timestamps
    end
  end
end
