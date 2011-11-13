class Map

	# Map, as a 2D array of co-ordinates to Tiles
	attr_accessor :tilemap
	attr_accessor :my_ants
	attr_accessor :enemy_ants
	
	#Creates the new map object of the given size
	def initialize(rows, columns, ai)	
		puts "R: #{rows}, C: #{columns}"
		@rows = rows
		@columns = columns
		@tilemap = Array.new(rows){|row| Array.new(columns){|col| Tile.new(row, col) } }

		@ai = ai
		@my_ants=[]
		@enemy_ants=[]
	end
	
	def reset 
		# reset the map data
		@tilemap.each do |row|
			row.each do |tile|
				tile.food=false
				tile.ant=nil
				tile.hill=false
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
	
	def propegate_influence(value, momentum, decay)
		
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
	end 
	
	def add_ant(ant)
		if ant.owner==0
			@my_ants.push ant
		else
			@enemy_ants.push ant
		end
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
	
	# If row or col are greater than or equal map width/height, makes them fit the map.
	# Handles negative values correctly (it may return a negative value, but always one that is a correct index).
	# Returns [row, col].
	def normalize row, col
		[row % @rows, col % @columns]
	end
end
