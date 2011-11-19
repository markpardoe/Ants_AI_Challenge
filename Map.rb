class Map
		include Enumerable

#columns = x
#rows = y
 attr_accessor @scoutvalues
 attr_accessor @foodvalues
 attr_accessor @isLand
 

	#Creates the new map object of the given size
	def initialize(rows, columns)	
		@rows = rows
		@cols = columns
		@tilemap= Array.new(@rows){|row| Array.new(@cols){|col| Tile.new(row,col, col + (row * @cols)) } }
		@tilemap = @tilemap.flatten
		
		@scoutvalues = Array.new(rows*columns,0)
		@foodvalues = Array.new(rows*columns,0)
		@isLand  = Array.new(rows*columns,true)
	end
	
	 def each
	 	 @tilemap.each{|tile|yield tile}
	 end
	
	def getTileAtIndex(ix)
		return @tilemap[ix]
	end
	
	# Get the tile from the tileMap
	def getTile(row, col)
		row = row % @rows if (row >= @rows or row<0)
		col =col % @cols if (col >= @cols or col<0)
		return @tilemap[col + (row * @cols)]
	end
	
	def getTileAtPoint(point) 
		return getTile(point[0], point[1])
	end
	
	def [](row,col)
		return getTile(row,col)
	end
	
	# If row or col are greater than or equal map width/height, makes them fit the map.
	# Handles negative values correctly (it may return a negative value, but always one that is a correct index).
	# Returns [row, col].
	def normalize row, col
		[row % @rows, col % @columns]
	end
	
	
	# Generates an array holding the view radius of a ant
	# Array made up of pairs [xOffset, yOffset]
	# xOffset = squares horizontal from center
	# yOffset = maximum distance of viewable range (from center) in the column XoffSet
	def generate_view_area(distance2)
		initalPoint = [0,0]
		distance = Integer(Math.sqrt(distance2))
		
		viewRadius = []
		xCounter = 1
		yCounter = distance
		viewRadius.push([0 , distance])
		
		while (xCounter <= distance) do
		
			x =  xCounter
			y =  yCounter
			
			if ((eculidean_distance(initalPoint, [xCounter,yCounter])) < distance2)
				#Within range, so can use this square
				viewRadius.push([xCounter, yCounter])
				viewRadius.push([-xCounter, yCounter])
				xCounter += 1
			else
				yCounter -=1 # move in slightly and try again
			end
		end
		@viewRadius =  viewRadius
	end
		
	 	# Expects two 2 element arrays [row, col], [row1,col1]
 	# Or two tiles
 	# Or two ant
 	# Or any combination of the above...
	def eculidean_distance(point1, point2)
		(point1[0] - point2[0])**2  + (point1[1] - point2[1])**2 
	end
	
		#Updates every square that the ant can see....
	# Sets tile.scout_value = 0
	def update_view_range(antLocation)
		 antRow = antLocation[0]
		 antCol = antLocation[1]
		 
		 @viewRadius.each do |viewPair|
		 	row = viewPair[0] + antRow
		 	row = row % @cols if (row >= @cols or row <0)	# normalise the y value if needed
		 	row = row * @cols
		 	
		 	startVal = antCol - viewPair[1]	#start index
		 	endVal = antCol + viewPair[1]

		 	(startVal..endVal).each do |x|
		 		x = x % @rows if (x >= @rows or x<0)	# normalise if value on edges of square

		 		@tilemap[x + row].scout_value = 0
		 	end
		 end
	end
	
	def to_s
		s = ""
		@rows.times do |row|
			s << @tilemap[row*@cols, @cols].inspect << "\n"
		end
		s
	end
end



