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
		@enemyThreshold = 1000
		@log = Logger.new('log.txt')
		
		
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
	
	def print_influence(rowStart, colStart, size)
		inf = Array.new(@rows){|row| Array.new(@cols,0)}
		(0..@rows-1).each do |row|
			(0..@cols-1).each do |col|
				inf[row][col] = total_influence(row,col)
			end
		end

		s = ""
				# 
				# inf.transpose
				# inf.unshift((0..inf.length-1).to_a)   # inserts column labels #
				# inf.map.with_index{|col, i|
				#     col.unshift(i.zero?? nil : i-1)   # inserts row labels #
				#     w = col.map{|cell| cell.to_s.length}.max   # w = "column width" #
				#  
				#     col.map.with_index{|cell, i|
				#          i.zero?? cell.to_s.center(w) : cell.to_s.ljust(w)}   # alligns the column #
				# }
				# inf.transpose
		inf.each_with_index do |row, ix| 
			 if (ix >= rowStart && ix <=(rowStart + size))
	
			 	s << "[#{row[colStart,size].join(' | ')}]"  << "\n"
		 	end
		end
		return s
	end
	
	
	def reset() 
		@my_ants=[]
		@enemy_ants=[]
		fill_holes
		# propegate all influence values
		# Update visible squares
		@scoutValues.each do |row|
			row.map! {|y| y+10 }
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
			 add_influence(row, col, 5000,5, @foodValues)
			#flood_influence(row, col, 1000, 7, @foodValues)
		when :water
			@tile_map[row,col] = 1
		when :ant
			@tile_map[row,col] = 2

			ant = Ant.new row, col, true, owner,  self

			if ant.owner==0
				@my_ants.push ant
				update_view_range(row,col)
				add_influence(row, col, 500,5, @myInfluence)
			else
				@enemy_ants.push ant
				add_influence(row, col, 500,5, @enemyInfluence)
			end
			
		when :hill
			@tile_map[row,col] = -1
			add_influence(row, col, 10000,30, @foodValues) if (owner != 0) 
		#	flood_influence(row, col, 10000, 20, @enemyInfluence)
		else
			raise 'Invalid Point Added'
		end	
	end
	
	
	# Fills tiles surrounded on 3 sides, to prevent movement into them
	def fill_holes
		(0..@rows-1).each do |row|
			(0..@cols-1).each do |col|
				# Only check visible squares
				if (@scoutValues[row,col] == 0 && @tile_map[row,col] != 1)
					count = 0
					count +=1 if @tile_map[row-1,col] == 1
					count +=1 if @tile_map[row+1,col] == 1
					count +=1 if @tile_map[row,col-1] == 1
					count +=1 if @tile_map[row,col+1] == 1
					
					@tile_map[row, col] = 1 if (count >= 3)

				end
			end
		end
	end
		
	def try_move_ant ant
		directions = ant.targetDirections
		# Check if ant is to stay still...
		return true if directions.empty?
		
		directions.each do |dir|
			dest = neighbor(ant, dir)
			if (@tile_map[dest[0], dest[1]] <1)
				# Moves the ant to the new tile.
				@ai.order ant, dir
				# Remove old position from tilemap
				@tile_map[ant.row, ant.col] =0
				# Add ant at new position
				@tile_map[dest[0], dest[1]] = 2
				ant.update_location(dest[0], dest[1])
				return true
			end
		end
		return false
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
			raise "incorrect direction: #{direction}"
		end
		return x,y
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
			if (distance < radius - 1)
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
				
			end				
					
			nodes = children
		end
	end
	
	def get_best_targets(ant, radius)
		circ = (radius *2)-1
		checked = Array2D.new(circ, circ, false)
		
		nodes = []
		row = ant.row
		col = ant.col
		checked[0,0] = true
		
		# Add initial values with their starting directions
	#	if (!checked[1,0] && @tile_map[row+1,col] != 1 && total_influence(row+1, col) < @enemyThreshold)
		if (!checked[1,0] && @tile_map[row+1,col] != 1)
			nodes << [row+1,col, :S]
			checked[1,0] = true
		end
	#	if (!checked[-1,0] && @tile_map[row-1,col] != 1 && total_influence(row-1, col) < @enemyThreshold)
		if (!checked[-1,0] && @tile_map[row-1,col] != 1)
			nodes << [row-1,col, :N]
			checked[-1,0] = true
		end
	#	if (!checked[0,1] && @tile_map[row,col+1] != 1 && total_influence(row, col+1) < @enemyThreshold)
		if (!checked[0,1] && @tile_map[row,col+1] != 1)
			nodes << [row,col+1, :E]
			checked[0,1] = true
		end
	#	if (!checked[0,-1] && @tile_map[row,col-1] != 1 && total_influence(row, col-1) < @enemyThreshold)
		if (!checked[0,-1] && @tile_map[row,col-1] != 1)
			nodes << [row,col-1, :W]
			checked[0,-1] = true
		end			
		maxValue =-99999
		maxDir = []
		
	
		(1..radius-1).each do |distance|
			children = []
			nodes.each do |point|
	
				curRow = point[0] 
				chkRow = point[0] - row
				curCol = point[1]
				chkCol = point[1] - col
				curDir = point[2]
	
				# Get the value of the current square / distance from the ant
				val = total_influence(curRow,curCol) / distance.to_f
			#	val = total_influence(curRow,curCol)
				# Update the distance list...
				if (val > maxValue)
					maxValue = val
					maxDir = [curDir]
				elsif (val == maxValue)	# Add to the available distance list
					maxDir << curDir
				end
				
			#	if (distance < radius-1)	# no point expanding children on last node
					# if (!checked[chkRow+1,chkCol] && @tile_map[curRow+1,curCol] != 1 && total_influence(curRow+1, col) < @enemyThreshold)
					if (!checked[chkRow+1,chkCol] && @tile_map[curRow+1,curCol] !=1)
						children << [curRow+1,curCol, curDir]
						checked[chkRow+1,chkCol] = true
					end
					#if (!checked[chkRow-1,chkCol] && @tile_map[curRow-1,curCol] != 1 && total_influence(curRow-1, col) < @enemyThreshold)
					if (!checked[chkRow-1,chkCol] && @tile_map[curRow-1,curCol] != 1)
						children << [curRow-1,curCol, curDir]
						checked[chkRow-1,chkCol] = true
					end
					#if (!checked[chkRow,chkCol+1] && @tile_map[curRow,curCol+1] != 1 && total_influence(curRow, col+1) < @enemyThreshold)
					if (!checked[chkRow,chkCol+1] && @tile_map[curRow,curCol+1] != 1)
						children << [curRow,curCol+1, curDir]
						checked[chkRow,chkCol+1] = true
					end
					#if (!checked[chkRow,chkCol-1] && @tile_map[curRow,curCol-1] != 1 && total_influence(curRow, col-1) < @enemyThreshold)
					if (!checked[chkRow,chkCol-1] && @tile_map[curRow,curCol-1] != 1)
						children << [curRow,curCol-1, curDir]
						checked[chkRow,chkCol-1] = true
					end		
				#end	
			end				
					
			nodes = children	# update the toCheck list
		end
		return maxDir.uniq
	end
end
	
# 
# beginning = Time.now
# 	m = Map.new(10,10, nil)
# 	1.times do
# 		m.add_influence 4,4, 1000, 3, m.foodValues
# 	end
# 	puts m.map_to_s(m.tile_map)
# 	puts "----------"
# 	#puts m.print_influence 2,2,8
# 	puts "Time elapsed for radius  = #{Time.now - beginning} seconds"
# 	
