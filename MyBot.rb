$:.unshift File.dirname($0)
require 'ants.rb'
require 'AI.rb'
require 'Tile.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
end

ai.run do |ai|
	# your turn code here
		
	ai.orders.clear
	ai.my_ants.each do |ant|

		# try to go north, if possible; otherwise try east, south, west.
		[:N, :E, :S, :W].each do |dir|
			if ant.tile.neighbor(dir).is_passable?
				ant.order dir
				break
			end
		end
	end
	
end