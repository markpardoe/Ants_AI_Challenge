$:.unshift File.dirname($0)
require 'ants.rb'
require 'AI.rb'
require 'Map.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
	
end

ai.run do |ai|
	# your turn code here
	@mapController = ai.map	
		

	myAnts = @mapController.my_ants
	

		  myAnts.each do |ants| 		
		 		ants.get_best_moves()
		 		@mapController.try_move_ant(ants)
		 end
		 
		 
end
	
	
	#   row = row % @rows if (row >= @rows or row<0)
	#	col =col % @cols if (col >= @cols or col<0)
	#	return (col + (row * @cols))
