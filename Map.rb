class Map
		include Enumerable

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

		@scoutValues = Array.new(rows*columns,0)
		@foodValues = Array.new(rows*columns,0)
		@enemyInfluence = Array.new(rows*columns,0)
		@myInfluence = Array.new(rows*columns,0)
		@tile_map  = Array.new(rows*columns,0)
		
		@rows = rows
		@cols = columns

		generate_view_area(ai.viewradius2)
		@ai = ai
		@my_ants=[]
		@enemy_ants=[]
		@ant_locations = Hash.new(false)
	end

	def food_value(ix)
		@foodValues[ix]
	end
	
	def base_influence(index)
		return  @enemyInfluence[index] - @myInfluence[index]
	end
	
	def total_influence(index)
		return base_influence(index) + @foodValues[index] + @scoutValues[index]
	end
	
	def tension(index)
		return  @myInfluence[index] + @enemyInfluence[index]
	end
	
	def vunerability(index)
		return tension(index) - base_influence(index).abs
	end
	
	def reset() 
		@my_ants=[]
		@enemy_ants=[]
		@ant_locations = Hash.new(false)
		
		# propegate all influence values
		# Update visible squares
		@scoutValues.map! {|x| x+1 }
		
		# Regenerate food values
		@foodValues = Array.new(@rows*@cols,0)
		@enemyInfluence = Array.new(@rows*@cols,0)
		@myInfluence = Array.new(@rows*@cols,0)
		@tile_map.map! {|x| x > 1 ? 0 : x}
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

		 		@scoutValues[x + row] = 0
		 		# Clear the food value for this square as it is visible.
		 	end
		 end
	end
	
	def addPoint (row, col, pointType, owner = 0)
		ix= calculateIndex(row,col)
		case pointType
		when :food
			@tile_map[ix] = 3
			add_influence(row, col, 1000,10, @foodValues)
		when :water
			@tile_map[ix] = 1
		when :ant
			@tile_map[ix] = 2

			ant = Ant.new row, col, true, owner,  self
			@ant_locations[ant.index] = true
			
			if ant.owner==0
				@my_ants.push ant
				update_view_range([row,col])
				add_influence(row, col, 1000,7, @myInfluence)
			else
				@enemy_ants.push ant
				add_influence(row, col, 2000,7, @enemyInfluence)
			end
			
		when :hill
			@tile_map[ix] = -1
			add_influence(row, col, 10000,20, @foodValues) if (owner != 0) 

		else
			raise 'Invalid Point Added'
		end	
	end
	
	def to_s
		s = ""
		@rows.times do |row|
			s = s<< @foodValues[row*@cols, @cols].join(" ") << "\n"
		end
		s
	end
	
	# Propegate influence within range of the point...	
	#TODO: Use flood fill to flow around obstacles
	def add_influence(row, col, val, radius, map)
		axis = radius -1
		(-axis..axis).each do |ky|	
			
			kRow = row + ky
			kRow = kRow % @rows if (kRow >= @rows or kRow<0)
			ix = kRow * @cols
			
			# For each column...
			(-axis..axis).each do |kx|	
				kCol = col + kx
				kCol = kCol % @cols if (kCol >= @cols or kCol<0)
				distance = (ky.abs + kx.abs)
				
				if (distance < radius)
					ix2 = ix + kCol
					map[ix2] = map[ix2] + (val * (radius - distance))/radius 
				end
			end
		end
	end
	
	#----------------------------------------------------------
	# Depricated - use add_inflence method instead
	def blur(radius)
		tmpVals = Array.new(@rows*@cols, 0)
		blur_horizontal(@foodValues, tmpVals,radius)
		blur_vertical(tmpVals, @foodValues,radius)
	end
	
	def blur_horizontal(source, dest,radius)
		(0..@rows-1).each do |y|
			total = 0
			count = 0
				
			 # Process entire window for first pixel on left
			(-radius..radius).each do |kx|	
				nIx = calculateIndex(kx, y )
				if (@isPassable[nIx] != 1)
					total += source[nIx]
					count +=1
				end
			end
			dest[calculateIndex(0,y)] =  (total >0) ? (total / count) * 0.9 : 0
			
			# Subsequent pixels just update window total		
		    (1..@cols-1).each do |x|
	
		        #  Subtract pixel leaving window
		        oldIx = calculateIndex(x - radius - 1,y)
				if (@isPassable[oldIx] != 1)
					total -= source[oldIx]
					count -= 1
				end
				# Add new pixel entering window
				nIx = calculateIndex(x + radius,y)
				if (@isPassable[nIx] != 1)
					total += source[nIx]
					count += 1
				end
				
				dest[calculateIndex(x,y)] =  (total >0) ? (total / count) * 0.9 : 0
			end	
		end
	end
	
	def blur_vertical(source, dest,radius)
	    (0..@cols-1).each do |x|
	    	total = 0
			count = 0
			
	    	 # Process entire window for first pixel on left
			(-radius..radius).each do |ky|	
				nIx = calculateIndex(x, ky )
				if (@isPassable[nIx] != 1)
					total += source[nIx]
					count +=1
				end
			end
			dest[calculateIndex(x,0)]=  (total >0) ? (total / count) * 0.9 : 0
	    	
			# Subsequent pixels just update window total		
		    (1..@rows-1).each do |y|
	
		        #  Subtract pixel leaving window
		        oldIx = calculateIndex(x,y - radius - 1)
				if (@isPassable[oldIx] != 1)
					total -= source[oldIx]
					count -= 1
				end
				# Add new pixel entering window
				nIx = calculateIndex(x, y + radius)
				if (@isPassable[nIx] != 1)
					total += source[nIx]
					count += 1
				end
				
				dest[calculateIndex(x,y)] =  (total >0) ? (total / count) * 0.9 : 0
			end	
		end
	end
	#----------------------------------------------------------


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
		
		if (tile[0] == 28 && tile[1] == 19)
			ix = calculateIndex(tile[0]-1, tile[1])
			ix = calculateIndex(tile[0]+1, tile[1])
			ix = calculateIndex(tile[0], tile[1]+1)
			ix = calculateIndex(tile[0], tile[1]-1)
		end
		[:N, :E, :S, :W].each do |dir|
			n = neighbor(tile, dir)
			ix = calculateIndex(n[0], n[1])
			val = total_influence(ix)
			
			if (tile_map[ix] < 1 && val > maxVal) 
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
			ix = calculateIndex(n[0], n[1])
			if (@tile_map <1)
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
		return normalize(x,y)
	end

	# System Calculations
	 def calculateIndex(row,col)
	 	row = row % @rows if (row >= @rows or row<0)
		col =col % @cols if (col >= @cols or col<0)
		return (col + (row * @cols))
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
end



# puts "-----------------------------------"
# m = Map.new(43,39)
# .generate_view_area(77)
# m.addPoint(28,17,:food)
# m.addPoint(26,19,:food)
# m.addPoint(28,21,:food)
# m.addPoint(35,19,:food)
# beginning = Time.now
# 
# uts "-----------------------------------"
# m = Map.new(200,200)
# #m.foodValues.each_with_index() {|v, i| m.foodValues[i] = i}
# m.generate_view_area(77)
# beginning = Time.now
# 
# 1000.times do
# 	m.addPoint(1,1,:food)
# end
# 
# #puts m.inspect
# 
# #puts  1/(6.0/5)
# #puts 5/6.0
# puts "Time elapsed for Blur2: #{Time.now - beginning} seconds"
