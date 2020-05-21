$:.unshift File.dirname($0)
require 'Array2D.rb'
require 'Utilities.rb'

# Map of last scouted positions.
# Holds the number of turns since a position was last viewed.
# This allows us to 
class ScoutMap < Array2D
include Utilities

	# 2d array holding view area of an ant. (eg. circle based on x squares around centre point).
	# This makes updating the viewed location very fast as we can just add the 2 arrays (with the view area offset to centre on the current position)
	attr_accessor :viewArea	
	
	def initialize(row, cols, unseen_value, viewDistance)
		super(row, cols, 0)
		@unseen = unseen_value
		@viewArea = generate_area(viewDistance)
	end
	
	# Each turn, we update all squares by the given value (normally 1?)
	# So older sqaures (since last viewed) get higher values making them more attractive for scouting.
	def reset
	 	@data.each do |row|
	 		row.map! {|y| y+ @unseen }
		 end		
	end
	
	# Updates every square that an ant can see.
	# Sets tile.scout_value = 0
	# (row, col) = location of an ant.
	def update_view_range(row, col)
		 antRow = row
		 antCol = col		 
		 
		 @viewArea.each do |viewPair|
		 	row = viewPair[0] + antRow
		 	startVal = antCol - viewPair[1]	#start index
		 	endVal = antCol + viewPair[1]

		 	(startVal..endVal).each do |col|
		 		self[row,col] = 0
		 		# Clear the food value for this square as it is visible.
		 	end
		 end
	end
end