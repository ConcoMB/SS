class CreateSimulations < ActiveRecord::Migration
  def change
    create_table :simulations do |t|
      t.string :name
      t.string :method
      t.float :loss_probability
      t.float :lambda
      t.float :length_avg
      t.float :length_dev

      t.timestamps
    end
  end
end
