class MapController


	attr_accessor :my_ants
	attr_accessor :enemy_ants

	
	
	#Creates the new map object of the given size
	def initialize(rows, columns, ai)	

		@map = Map.new(rows, columns)
		@map.generate_view_area(ai.viewradius2)

		@ai = ai
		@my_ants=[]
		@enemy_ants=[]
		@food = []
	end
	

	
	def reset 
		@my_ants=[]
		@enemy_ants=[]
		@map.each do |tile|
			tile.reset
		end
		@food = []
		@map.reset
		
	end
	
	def map_created() 
		@food.each do |ix|
			@map.addPoint(ix[0], ix[1], :food)
		end
		
	#	@map.blur(4)
	#	@map.blur(4)
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
	

	#Add a food source to the map
	def add_food x, y
		@food.push([x,y])
	end
	
	# Add a water tile to the map
	def add_water x, y
		t = @map[x,y]
		t.water = true
		@map.addPoint(x,y, :water)
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
		maxVal =  0
		maxDir =  nil
		
		[:N, :E, :S, :W].each do |dir|
			t = neighbor(tile, dir)
			val = @map.food_value(t.index)
			puts "#{t.location.inspect} is passable: #{t.is_passable?}  Value = #{val}"
			if (t.is_passable? && val > maxVal) 
				
				maxDir = dir
				maxVal = val
			end
		end
		
		return maxDir
	end
end
