class AddMeansToSimulation < ActiveRecord::Migration
  def change
    add_column :simulations, :time_mean, :float
    add_column :simulations, :ratio_mean, :float
  end
end
