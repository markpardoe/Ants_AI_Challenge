$:.unshift File.dirname($0)
require 'ants.rb'
require 'AI.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
end

ai.run do |ai|
	# your turn code here

	ai.orders.clear
	ai.my_ants.each do |ant|
		x = x+1
		# try to go north, if possible; otherwise try east, south, west.
		[:N, :E, :S, :W].each do |dir|
			if ant.square.neighbor(dir).is_unoccupied?
				ant.order dir
				break
			end
		end
	end
	
end