class CreatePackets < ActiveRecord::Migration
  def change
    create_table :packets do |t|
      t.integer :number
      t.integer :size
      t.integer :arrival
      t.references :simulation
      t.timestamps
    end
  end
end
