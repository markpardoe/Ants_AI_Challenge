$:.unshift File.dirname($0)
require 'ants.rb'
require 'AI.rb'
require 'Map.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
	@enemyThreshold = 1000
end

ai.run do |ai|
	# your turn code here
	@mapController = ai.map	
		
	maxRow = @mapController.rows
	maxCol = @mapController.cols
	myAnts = @mapController.my_ants
		
	(0..maxRow-1).each do |row|
			
		rowIx = row * maxCol
		(0..maxCol-1).each do |col|
			if @mapController.tile_map[row,col] < 1	# is the square passable...
					if @mapController.base_influence(row,col) < @enemyThreshold
							val = @mapController.total_influence(row,col)
							
							myAnts.each do |ant|
								ant.check_max_value(row, col, val)
								
							end
					end
			end
		end	
	end
		
		# puts "total ants = #{myAnts.length}" ------------------------
		  @mapController.my_ants.each do |ants| 		
		 		d = @mapController.ant_dir_to_target(ants)
		 		
				@mapController.move_ant(ants, d ) if (!d.nil?)
		 end
end
	
	
	#   row = row % @rows if (row >= @rows or row<0)
	#	col =col % @cols if (col >= @cols or col<0)
	#	return (col + (row * @cols))
