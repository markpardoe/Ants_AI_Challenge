$:.unshift File.dirname($0)
require 'Array2D.rb'
require 'Utilities.rb'

class ScoutMap < Array2D
include Utilities
	attr_accessor :viewArea
	def initialize(row, cols, unseen_value, viewDistance2)
		super(row, cols, 0)
		@unseen = unseen_value
		@viewArea = generate_area(viewDistance2)
	end
	
	
	def reset
	 	@data.each do |row|
	 		row.map! {|y| y+ @unseen }
		 end		
	end
	
	# Updates every square that the ant can see....
	# Sets tile.scout_value = 0
	def update_view_range(row, col)
		 antRow = row
		 antCol = col
		 
		 @viewArea.each do |viewPair|
		 	row = viewPair[0] + antRow
		#	row = row % @rows if (row >= @rows or row <0)	# normalise the y value if needed
		 #	row = row * @cols
		 	
		 	startVal = antCol - viewPair[1]	#start index
		 	endVal = antCol + viewPair[1]

		 	(startVal..endVal).each do |col|
		 	#	col = col % @cols if (col >= @cols or col<0)	# normalise if value on edges of square

		 		self[row,col] = 0
		 		# Clear the food value for this square as it is visible.
		 	end
		 end
	end
end