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

executeTime = ai.turntime - 50 	# Execution time available
ai.run do |ai|
	beginning = Time.now.to_f

	# your turn code here
	@mapController = ai.map	
	@mapController.update_hills

	myAnts = @mapController.my_ants
	total_ants = myAnts.length
	
	if total_ants < 20
		search = 30
	elsif total_ants < 100
		search = 20
	elsif total_ants < 200
		search = 15
	elsif total_ants < 250
		search = 10
	else
		search = 7
	end
	

	  myAnts.each do |ants| 		
	 	ants.get_best_moves(search)
	 end
	 count = 0
	#while (myAnts.length > 0 && executeTime - (Time.now.to_f - beginning) >= 0.03 ) do
	while ((count < 10) && ((Time.now.to_f - beginning) * 1000 < executeTime) && (myAnts.length >0)) do
	 	unmoved = []
	 	# try to move each bot
	 	myAnts.each do |ant| 		
	 		if (!ant.move)
	 			# failed to move the bot - so add it to the umnoved list to retry.
	 			unmoved << ant
 			end
	 	end
	 	myAnts = unmoved
	 	count +=1
 	end
 	
end
