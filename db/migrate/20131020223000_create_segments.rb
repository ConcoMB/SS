class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.integer :losts
      t.integer :number
      t.integer :transmitted
      t.boolean :sent, default: false
      t.integer :sent_time
      t.boolean :ack, default: false
      t.references :packet
      t.timestamps
    end
  end
end
