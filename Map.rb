class Map

	# Map, as a 2D array of co-ordinates to Tiles
	attr_accessor :tilemap
	attr_accessor :my_ants
	attr_accessor :enemy_ants

	# Generates an array holding the view radius of a ant
	# Array made up of pairs [xOffset, yOffset]
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
				xCounter += 1
			else
				yCounter -=1 # move in slightly and try again
			end
		end
		
		return viewRadius
	end
	
	#Creates the new map object of the given size
	def initialize(rows, columns, ai)	

		@rows = rows
		@columns = columns
		@tilemap = Array.new(rows){|row| Array.new(columns){|col| Tile.new(row, col) } }
		@viewRadius = generate_view_area(ai.viewradius2)

		@ai = ai
		@my_ants=[]
		@enemy_ants=[]
		
		@foodValue = 100
		 @foodDecay = 6.0
	end
	
	def reset 
	#	puts "[26,19] = #{@tilemap[26][19].food_influence}"
	#	puts "[27,19] = #{@tilemap[26][19].food_influence}"
		
	#	puts "[28,17] = #{@tilemap[28][17].food_influence}"
		
	#	puts "[28,18] = #{@tilemap[26][19].food_influence}"
		# reset the map data
		@tilemap.each do |row|
			row.each do |tile|
				tile.reset
			end
		end

		@my_ants=[]
		@enemy_ants=[]
	end
	
	# Allows map[row][column] to select a tile
	def [](index)
		@tilemap[index]
 	end
 	
 	# Expects two 2 element arrays [row, col], [row1,col1]
 	# Or two tiles
 	# Or two ant
 	# Or any combination of the above...
	def eculidean_distance(point1, point2)
		(point1[0] - point2[0])**2  + (point1[1] - point2[1])**2 
	end
	
	# Expects two 2 element arrays [row, col], [row1,col1]
	# Or two tiles
 	# Or two ant
 	# Or any combination of the above...
	def move_distance(point1, point2)
		#http://en.wikipedia.org/wiki/Taxicab_geometry
		(point1[0] - point2[0]).abs + (point1[1]-point2[1]).abs
	end
	
	def move_ant ant, direction
		# Write to standard out
	#	ant, direction = a, b
		@ai.order ant, direction
		
		# Moves the ant to the new tile.
		dest = neighbor(ant, direction)
		source = ant.tile
		
		source.ant = nil
		ant.tile = dest
		dest.ant = ant
		ant.moved = true
	end 
	
 	# Returns a square neighboring this one in given direction.
 	# Point can be a tile, and or 2d location array ([row, column])
	def neighbor point, direction
		direction=direction.to_s.upcase.to_sym # canonical: :N, :E, :S, :W

		case direction
		when :N
			row, col = normalize(point[0]-1, point[1])
		when :E
			row, col = normalize(point[0],  point[1]+1)
		when :S
			row, col = normalize(point[0]+1, point[1])
		when :W
			row, col = normalize(point[0],  point[1]-1)
		else
			raise 'incorrect direction'
		end
	#	puts "Neightbout: " + direction.to_s + " -" + [row,col].inspect
		return tilemap[row][col]
	end
	
	def all_neighbours(point)
		row = point[0]
		col = point[1]

		puts "Row, column = #{point.inspect}"
	#	puts [@tilemap[row][col-1], @tilemap[row][col+1], @tilemap[row-1][col],@tilemap[row+1][col]].inspect
		return [@tilemap[row][col-1], @tilemap[row][col+1], @tilemap[row-1][col],@tilemap[row+1][col]] #.select {|tile| tile.is_passable?}	
	end
	
	# If row or col are greater than or equal map width/height, makes them fit the map.
	# Handles negative values correctly (it may return a negative value, but always one that is a correct index).
	# Returns [row, col].
	def normalize row, col
		[row % @rows, col % @columns]
	end

	#Add a food source to the map
	def add_food row, col
		@tilemap[row][col].food = true
		add_goal(row, col)
		@tilemap[row][column].food_influence = [@tilemap[row][column].food_influence + value,100].Max
	end
	
	# Add a water tile to the map
	def add_water row, col
		@tilemap[row][col].water = true
		@tilemap[row][col].food_influence = nil
	end
	
	# Add a hill tile to the map
	def add_hill row, col, owner
		@tilemap[row][col].hill = true
	end
	
	# Add an ant to the map
	def add_ant row, col, owner
		ant = Ant.new true, owner, tilemap[row][col], self
		tilemap[row][col].ant = ant
		if ant.owner==0
			@my_ants.push ant
			update_view_range(ant.location)
		else
			@enemy_ants.push ant
		end
	end
	
	#Updates every square that the ant can see....
	# Sets tile.scout_value = 0
	def update_view_range(antLocation)
		antX = antLocation[0]
		antY = antLocation[1]
		@viewRadius.each do |viewPair|
			
			x = viewPair[0]
			yMax = viewPair[1]
			
			(-yMax..yMax).each do |y|
				@tilemap[antX + x][antY + y].scout_value = 0
				@tilemap[antX -x][antY + y].scout_value = 0
			end
			
		end
	end
	
	def propegateInfluence()
	end
	
	def get_best_direction(point)
	#		try to go north, if possible; otherwise try east, south, west.
		# [:N, :E, :S, :W].each do |dir|
		# 	if neighbor(ant, dir).is_passable?
		# 		return dir
		# 		break
		# 	end
		# end

		maxDir = [:N, :S, :E, :W].max_by {|dir| value_in_direction(point[0],point[1] , dir)}
	#	puts "Maximum direction for #{point} = #{maxDir}" 
		return maxDir
	end
	
	
	def value_in_direction row, column, direction
		case direction
		when :N
			return @tilemap[row-1][column].food_influence ||=0 
		when :E
			return @tilemap[row-1][column].food_influence ||=0 
		when :S
			return @tilemap[row-1][column].food_influence ||=0 
		when :W
			return @tilemap[row-1][column].food_influence ||=0 
		else
			raise 'incorrect direction'
			return 0
		end
		return 0
		
	end
end
