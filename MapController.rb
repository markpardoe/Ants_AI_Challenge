class MapController


	attr_accessor :my_ants
	attr_accessor :enemy_ants

	
	
	#Creates the new map object of the given size
	def initialize(rows, columns, ai)	

		@map = Map.new(rows, columns)
		@rows = rows
		@columns = columns
		@map = Map.new(rows, columns)
		@map.generate_view_area(ai.viewradius2)

		@ai = ai
		@my_ants=[]
		@enemy_ants=[]
		
		@foodValue = 100
		 @foodDecay = 6.0
	end
	
	

	
	
	def reset 
		@my_ants=[]
		@enemy_ants=[]
		@map.each do |tile|
			tile.reset
		end
	end
	


	# Expects two 2 element arrays [x, y], [x1,y1]
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
 	# Point can be a tile, and or 2d location array ([x, y])
	def neighbor point, direction
		direction=direction.to_s.upcase.to_sym # canonical: :N, :E, :S, :W

		case direction
		when :N
			x, y = point[0]-1, point[1]
		when :E
			x, y = point[0],  point[1]+1
		when :S
			x, y = point[0]+1, point[1]
		when :W
			x, y = point[0],  point[1]-1
		else
			raise 'incorrect direction'
		end
		return @map[x,y]
	end
	
	# def all_neighbours(point)
	# 	x = point[0]
	# 	y = point[1]
	# 	return [@map[x,y-1], @map[x,y+1], @map[x-1,y],@map[x+1,y]] #.select {|tile| tile.is_passable?}	
	# end


	#Add a food source to the map
	def add_food x, y
		@map[x,y].food = true
		@map[x,y].food_influence = [@map[x,y].food_influence + 85,100].max
	end
	
	# Add a water tile to the map
	def add_water x, y
		t = @map[x,y]
		t.water = true
		t.food_influence = nil
	end
	
	# Add a hill tile to the map
	def add_hill x, y, owner
		@map[x,y].hill = true
	end
	
	# Add an ant to the map
	def add_ant row, col, owner
		ant = Ant.new true, owner, @map[row,col], self, @map
		@map[row,col].ant = ant
		if ant.owner==0
			@my_ants.push ant
			@map.update_view_range(ant.location)
		else
			@enemy_ants.push ant
		end
	end
	

	def get_best_direction(point)
	#		try to go north, if possible; otherwise try east, south, west.
		# [:N, :E, :S, :W].each do |dir|
		# 	if neighbor(ant, dir).is_passable?
		# 		return dir
		# 		break
		# 	end
		# end
		maxVal = -0.1
		maxDir = nil
		[:N, :E, :S, :W].each do |dir|
			t = neighbor(point, dir)
			puts "#{t.location.inspect} is passable: #{t.is_passable?}  Value = #{t.food_influence}"
			if (t.is_passable? && t.food_influence > maxVal) 
				
				maxDir = dir
				maxVal = t.food_influence
			end
		end
		
		return maxDir
	end
		# 
		# 
		# def value_in_direction x, y, direction
		# 	case direction
		# 	when :N
		# 		return @map[x,y-1].food_value ||=0 
		# 	when :E
		# 		return @map[x+1,y].food_value ||=0 
		# 	when :S
		# 		return @map[x,y+1].food_value ||=0 
		# 	when :W
		# 		return @map[x-1,y].food_value ||=0 
		# 	else
		# 		raise 'incorrect direction'
		# 		return 0
		# 	end
		# 	return 0
		# 	
		# end
end
