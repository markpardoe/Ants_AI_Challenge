$:.unshift File.dirname($0)
require 'ants.rb'
require 'AI.rb'
require 'Tile.rb'
require 'Map.rb'
require 'InfluenceMap.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
	
end

ai.run do |ai|
	# your turn code here
	@map = ai.map	

	@map.my_ants.each do |ant|

		# try to go north, if possible; otherwise try east, south, west.
		#[:N, :E, :S, :W].each do |dir|
	#		if @map.neighbor(ant, dir).is_passable?
	#			ant.move_direction dir
	#			break
	#		end
	#	end
		ant.move_direction @map.get_best_direction(ant)
	
	end
	
end