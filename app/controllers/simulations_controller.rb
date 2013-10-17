class SimulationsController < ApplicationController
  inherit_resources

  def simulate
    
  end

  private

    def resource_params
      params.require(:simulation).permit(:name, :method, :loss_probability, :lambda, :length_avg, :length_dev)
    end
end
