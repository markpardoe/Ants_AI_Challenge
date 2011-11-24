$:.unshift File.dirname($0)
require 'Array2D.rb'

class Map

#columns = x
#rows = y

	# How many turns since this square was last seen.
	# Can be used to allow scouting of unspotted squares
	# To get the value, call tile.scount_value
	# This allows us to take account of water squares which will always be zero
 	attr_accessor :scoutValues
 	
 	# Food influence map
 	attr_accessor :foodValues
 	attr_accessor :myInfluence
 	attr_accessor :enemyInfluence
 
 	# -1 = Enemy Hill
 	# 0 = land
 	# 1 = water
 	# 2 = ant (temp block)
 	# 3 = food (temp block)
 	attr_accessor :tile_map
 
 	attr_accessor :my_ants
	attr_accessor :enemy_ants
	
	attr_accessor :rows
 	attr_accessor :cols
 	
	#Creates the new map object of the given size
	def initialize(rows, columns, ai)	
		@rows = rows
		@cols = columns
	#	@log = Logger.new('log.txt')
		@scoutValues = Array2D.new(@rows,@cols,0)
		@foodValues =Array2D.new(@rows,@cols,0)
		@enemyInfluence = Array2D.new(@rows,@cols,0)
		@myInfluence = Array2D.new(@rows,@cols,0)
		@tile_map  = Array2D.new(@rows,@cols,0)
		
		@ai = ai
		generate_view_area(@ai.viewradius2) if (ai)
		
		@my_ants=[]
		@enemy_ants=[]
	end
	
	

	def food_value(row,col)
		@foodValues[row,col]
	end
	
	def base_influence(row,col)
		return  @enemyInfluence[row,col] - @myInfluence[row,col]
	end
	
	def total_influence(row,col)
		return base_influence(row,col) + food_value(row, col)  + @scoutValues[row,col]
	end
	
	def tension(row,col)
		return  @myInfluence[row,col] + @enemyInfluence[row,col]
	end
	
	def tile_value(row,col)
		return @tile_map[row,col]
	end
	
	def vunerability(row,col)
		return tension(row,col) - base_influence(row,col).abs
	end
	
	
	def reset() 
		@my_ants=[]
		@enemy_ants=[]
		
		# propegate all influence values
		# Update visible squares
		@scoutValues.each do |row|
			row.map! {|y| y+1 }
		end
		
		# Regenerate food values
		@foodValues = Array2D.new(@rows,@cols,0)
		@enemyInfluence = Array2D.new(@rows,@cols,0)
		@myInfluence = Array2D.new(@rows,@cols,0)
	
		# Remove temporary objects from tilemap
		@tile_map.each do |row|
			row.map! {|x| x > 1 ? 0 : x}
		end
	end
	
	def size()
		return [@rows, @cols]
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
		
	
	# Updates every square that the ant can see....
	# Sets tile.scout_value = 0
	def update_view_range(row, col)
		 antRow = row
		 antCol = col
		 
		 @viewRadius.each do |viewPair|
		 	row = viewPair[0] + antRow
		 	row = row % @rows if (row >= @rows or row <0)	# normalise the y value if needed
		 #	row = row * @cols
		 	
		 	startVal = antCol - viewPair[1]	#start index
		 	endVal = antCol + viewPair[1]

		 	(startVal..endVal).each do |col|
		 		col = col % @cols if (col >= @cols or col<0)	# normalise if value on edges of square

		 		@scoutValues[row,col] = 0
		 		# Clear the food value for this square as it is visible.
		 	end
		 end
	end
	
	def addPoint (row, col, pointType, owner = 0)

		case pointType
		when :food
			@tile_map[row,col] = 3
			 add_influence(row, col, 1000,7, @foodValues)
			#flood_influence(row, col, 1000, 7, @foodValues)
		when :water
			@tile_map[row,col] = 1
		when :ant
			@tile_map[row,col] = 2

			ant = Ant.new row, col, true, owner,  self

			if ant.owner==0
				@my_ants.push ant
				update_view_range(row,col)
			#	flood_influence(row, col, 1000, 7, @myInfluence)
				add_influence(row, col, 1000,7, @myInfluence)
			else
				@enemy_ants.push ant
				add_influence(row, col, 2000,7, @enemyInfluence)
			#	flood_influence(row, col, 2000, 7, @enemyInfluence)
			end
			
		when :hill
			@tile_map[row,col] = -1
			add_influence(row, col, 10000,20, @foodValues) if (owner != 0) 
		#	flood_influence(row, col, 10000, 20, @enemyInfluence)
		else
			raise 'Invalid Point Added'
		end	
	end
	
	
	# # Propegate influence within range of the point...	
	# #TODO: Use flood fill to flow around obstacles
	# def add_influence(row, col, val, radius, map)
	# 	axis = radius -1
	# 	(-axis..axis).each do |ky|	
	# 		
	# 		kRow = row + ky
	# 		kRow = kRow % @rows if (kRow >= @rows or kRow<0)	# normalise the row
	# 
	# 		# For each column...
	# 		(-axis..axis).each do |kx|	
	# 			kCol = col + kx
	# 			kCol = kCol % @cols if (kCol >= @cols or kCol<0)	# normalise the column
	# 			distance = (ky.abs + kx.abs)
	# 			
	# 			if (distance < radius)
	# 				map[kRow,kCol] += (val * (radius - distance))/radius 
	# 			end
	# 		end
	# 	end
	# end
	

	def get_best_direction(tile)
	#		try to go north, if possible; otherwise try east, south, west.
		# [:N, :E, :S, :W].each do |dir|
		# 	if neighbor(ant, dir).is_passable?
		# 		return dir
		# 		break
		# 	end
		# end
		maxVal = 0-999999
		maxDir =  nil
		
		[:N, :E, :S, :W].each do |dir|
			n = neighbor(tile, dir)
			val = total_influence(n[0], n[1])
			if (tile_value(n[0], n[1]) < 1 && val > maxVal) 
				maxDir = dir
				maxVal = val
			end
		end
		return maxDir
	end
	
	def ant_dir_to_target ant
		# Write to standard out
	#	ant, direction = a, b
		dirs = ant.dirs_to_target
		
		dirs.each do |d|
			n = neighbor(ant, d)
			if (@tile_map[n[0],n[1]] <1)
				puts "Ant #{ant.location.inspect}.  Best dir = #{d}"
				return d
			end
		end
		
		return get_best_direction(ant)
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
 	# Point can be a ant, and or 2d location array ([x, y])
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
		return normalize(x,y)
	end

 	# Expects two 2 element arrays [row, col], [row1,col1]
 	# Or two tiles
 	# Or two ant
 	# Or any combination of the above...
	def eculidean_distance(point1, point2)
		(point1[0] - point2[0])**2  + (point1[1] - point2[1])**2 
	end
		
	 	
	# Expects two 2 element arrays [x, y], [x1,y1]
	# Or two tiles
 	# Or two ant
 	# Or any combination of the above...
 	#http://en.wikipedia.org/wiki/Taxicab_geometry
	def move_distance(point1, point2)
		dR = (point1[0] - point2[0]).abs
		dC = (point1[1]-point2[1]).abs
		# Deal with wraparound map
		dR = @rows - dR if (dR*2 > @rows)
		dC = @cols - dC if (dC*2 > @cols)

		return dR + dC
	end
	
	# If row or col are greater than or equal map width/height, makes them fit the map.
	#
	# Handles negative values correctly (it may return a negative value, but always one that is a correct index).
	#
	# Returns [row, col].
	def normalize row, col
		[row % @rows, col % @cols]
	end
	
	# System Calculations
	 def calculateIndex(row,col)
	 	row = row % @rows if (row >= @rows or row<0)
		col =col % @cols if (col >= @cols or col<0)
		return (col + (row * @cols))
 	end
 	
 	def map_to_s(map)
 		s = ""
 		map.each do |row|
			s << row.inspect << "\n"
		end
		return s
 	end

	def add_influence(row, col, val, radius, map)
	circ = (radius *2)-1
	checked = Array2D.new(circ, circ, false)
	
	nodes = [[row,col]]
	checked[0,0] = true

		(0..radius-1).each do |distance|
			children = []
			nodes.each do |point|

				curRow = point[0] 
				chkRow = point[0] - row
				curCol = point[1]
 				chkCol = point[1] - col

			#	puts "#{point.inspect} = #{[chkRow, chkCol].inspect} = #{(val * (radius - distance))/radius }"
				map[curRow,curCol] += (val * (radius - distance))/radius 	#update tile value
				
			#	puts checked.to_s 
			#	puts "------------" #if distance ==2
				if (!checked[chkRow+1,chkCol] && @tile_map[curRow+1,curCol] != 1)
					children << [curRow+1,curCol]
					checked[chkRow+1,chkCol] = true
				end
				if (!checked[chkRow-1,chkCol] && @tile_map[curRow-1,curCol] != 1)
					children << [curRow-1,curCol]
					checked[chkRow-1,chkCol] = true
				end
				if (!checked[chkRow,chkCol+1] && @tile_map[curRow,curCol+1] != 1)
					children << [curRow,curCol+1]
					checked[chkRow,chkCol+1] = true
				end
				if (!checked[chkRow,chkCol-1] && @tile_map[curRow,curCol-1] != 1)
					children << [curRow,curCol-1]
					checked[chkRow,chkCol-1] = true
				end			
				
			end				
					
			nodes = children
		end
	end
end
	
	
# beginning = Time.now
# 	m = Map.new(200,200, nil)
# 	400.times do
# 		m.addPoint 4,4, :food
# 	end
# 	#puts m.map_to_s(m.foodValues)
# 	puts "Time elapsed for radius  = #{Time.now - beginning} seconds"
# 	
# puts "-------------------------"
# 	beginning = Time.now
# 	m = Map.new(200,200, nil)
# 	1000.times do
# 		m.flood_influence 1,1, 1000, 7, m.foodValues
# 	end
# 	#puts m.map_to_s(m.foodValues)
# 	puts "Time elapsed for flood  = #{Time.now - beginning} seconds"
# 	
# 
	# puts "-------------------------"
	# beginning = Time.now
	# m = m = Map.new(200,200, nil)
	# 100.times do
	# 	m.flood_influence2 5,7, 1000, 7, m.foodValues
	# end
	# #puts m.map_to_s(m.foodValues)
	# puts "Time elapsed for flood2  = #{Time.now - beginning} seconds"
	# 
	# puts "-------------------------"
	# beginning = Time.now
	# m = Map.new(200,200, nil)
	# 100.times do
	# 	m.flood_influence3 5,7, 1000,7, m.foodValues
	# end
	# #puts m.map_to_s(m.foodValues)
	# puts "Time elapsed for flood3  = #{Time.now - beginning} seconds"
	