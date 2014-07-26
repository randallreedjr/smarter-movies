class CreateRequestTheaters < ActiveRecord::Migration
  def change
    create_table :request_theaters do |t|
      t.references :request, index: true
      t.references :theater, index: true

      t.timestamps
    end
  end
end
