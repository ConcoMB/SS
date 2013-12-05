class AddMinAndMaxToSimulations < ActiveRecord::Migration
  def change
    add_column :simulations, :time_min, :float
    add_column :simulations, :time_max, :float
    add_column :simulations, :ratio_min, :float
    add_column :simulations, :ratio_max, :float
  end
end
