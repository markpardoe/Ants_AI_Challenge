class MapController


	attr_accessor :my_ants
	attr_accessor :enemy_ants
	 
	 attr_accessor :rows 
	 attr_accessor :cols
	
	
	#Creates the new map object of the given size
	def initialize(rows, columns, ai)	
		@rows = rows
		@cols = columns
		@map = Map.new(rows, columns)
		@map.generate_view_area(ai.viewradius2)
		@ai = ai
		@my_ants=[]
		@enemy_ants=[]
		@ant_locations = Hash.new(false)
	end
	
	def reset 
		@my_ants=[]
		@enemy_ants=[]
		@ant_locations = Hash.new(false)
		@map.reset
	end
	


	#Add a food source to the map
	def add_food x, y
		@map.addPoint(x,y, :food)
	end
	
	# Add a water tile to the map
	def add_water x, y
		@map.addPoint(x,y, :water)
	end
	
	# Add a hill tile to the map
	def add_hill x, y, owner
		# TO BE IMPLEMENTED
	end
	
	# Add an ant to the map
	def add_ant row, col, owner
		ix = @map.calculateIndex(row, col)
		ant = Ant.new row, col, true, owner, self, @map
		@ant_locations[ant.index] = true

		if ant.owner==0
			@my_ants.push ant
			@map.addPoint(row, col, :ant)
		else
			@enemy_ants.push ant
			@map.addPoint(row, col, :enemy)
		end
	end

	def get_best_direction(tile)
	#		try to go north, if possible; otherwise try east, south, west.
		# [:N, :E, :S, :W].each do |dir|
		# 	if neighbor(ant, dir).is_passable?
		# 		return dir
		# 		break
		# 	end
		# end
		maxVal = - 999999
		maxDir =  nil
		
		[:N, :E, :S, :W].each do |dir|
			n = neighbor(tile, dir)
			ix = @map.calculateIndex(n[0], n[1])
			val = @map.total_influence(ix)
			
		
			if (@map.tile_map[ix] < 1 && val > maxVal) 
				maxDir = dir
				maxVal = val
			end
		end
		return maxDir
	end
	
	def move_ant ant, direction
		# Write to standard out
	#	ant, direction = a, b
		@ai.order ant, direction
		
		# Moves the ant to the new tile.
		dest = neighbor(ant, direction)

		ant.update_location(dest[0], dest[1])
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
		return @map.normalize(x,y)
	end
	
end
