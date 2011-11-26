$:.unshift File.dirname($0)
require 'ants.rb'
require 'AI.rb'
require 'Map.rb'
require "Settings.rb"


@settings = Settings.new()	
ai=AI.new @settings

ai.setup do |ai|
	@args = []
	# your setup code here, if any
	ARGV.each do|a|
	  @args << a
	end
	
end

ai.run do |ai|
	# your turn code here
	@mapController = ai.map	
	@mapController.update_hills

	myAnts = @mapController.my_ants
	

		  myAnts.each do |ants| 		
		 		ants.get_best_moves()
		 end
		 
		 
		 10.times do 
		 	unmoved = []
		 	myAnts.each do |ants| 		
		 		if (!@mapController.try_move_ant(ants))
		 			unmoved << ants
	 			end
		 	end
		 	myAnts = unmoved
	 	end
end
