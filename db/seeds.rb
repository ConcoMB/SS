# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Simulation.demand.each do |demand, values|
  Simulation.technologies.each do |tech, probability|
    Simulation.available_methods.each do |method|
      method_name = method.split('_').map{|w|w.first}.join
      name = "#{method_name}_#{tech.to_s.upcase.first}_#{demand.to_s.upcase.first}"
      Simulation.create!(name: name,
       method: method,
       loss_probability: probability,
       lambda: values[:lambda],
       length_avg: values[:avg],
       length_dev: values[:dev],
       total_packets: 100)
    end
  end
end