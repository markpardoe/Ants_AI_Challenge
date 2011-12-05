$:.unshift File.dirname($0)
require 'Array2D.rb'
require "InfluenceMap.rb"
require "TileMap.rb"
require "Utilities.rb"
require "ScoutMap.rb"
require "Settings.rb"
require "ants.rb"
#!/usr/bin/env ruby
require 'logger'

class Map
	include Utilities
#columns = x
#rows = y

	# How many turns since this square was last seen.
	# Can be used to allow scouting of unspotted squares
	# To get the value, call tile.scount_value
	# This allows us to take account of water squares which will always be zero
 	attr_accessor :scout_map
 	
 	# Food influence map
 	attr_accessor :foodValues
 	attr_accessor :myInfluence
 	attr_accessor :enemyInfluence
 	attr_accessor :enemy_hills	# list of enemy hills (hash, with false values)
 	attr_accessor :my_hills		# Array of my hills.  Contains [row, col] values
 	
 	attr_accessor :modifier_map
 	attr_accessor :tile_map
 
 	attr_accessor :my_ants
	attr_accessor :enemy_ants
	attr_accessor :moved_locations  # list of locations being moved to.
	
	attr_accessor :rows
 	attr_accessor :cols
 	
 	attr_accessor :ai
 	
 	def calc_index(row, col)
		row = row % @rows if (row >= @rows || row < 0)
		col = col % @cols if (col >= @cols || col < 0)
		return col + (row * @cols)
	end
 	
	#Creates the new map object of the given size
	def initialize(rows, columns, ai)	
		@rows = rows
		@cols = columns
		@ai = ai
	
	#	@log = Logger.new("Log.txt")
		# Allows for blank ai in testing
		if ai.nil?
			viewRad = 5
			@settings = Settings.new
		else
			@settings = ai.settings	
			viewRad = @ai.viewradius2
			
		end
		@scout_map = ScoutMap.new(@rows,@cols, @settings.scoutCounter, viewRad)
		
		@tile_map = TileMap.new(@rows, @cols)
		@enemy_hills = Hash.new(false)
		@my_hills = Hash.new(false)
		@foodValues = InfluenceMap.new(@rows,@cols,@tile_map)
		@enemyInfluence = InfluenceMap.new(@rows,@cols,@tile_map)
		@myInfluence = InfluenceMap.new(@rows,@cols,@tile_map)
		@modifier_map  = InfluenceMap.new(@rows,@cols,@tile_map,1)
				
		@my_ants=[]
		@enemy_ants=[]
		
		@current_locations = Hash.new()
		@moved_locations = Hash.new()
	end
	
	def reset() 
		@my_ants=[]
		@enemy_ants=[]
		@tile_map.reset
		@tile_map.fill_holes(@scout_map)
	#	@log.info("-----------------------------------------")
	#	@log.info("Turn: #{@ai.turn_number}")
		
		# Create New InfluenceMaps
		@foodValues = InfluenceMap.new(@rows,@cols,@tile_map)
		@enemyInfluence =  InfluenceMap.new(@rows,@cols,@tile_map)
		@myInfluence = InfluenceMap.new(@rows,@cols,@tile_map)
		@scout_map.reset
	end

	def food_value(row,col)
		@foodValues[row,col]
	end
	
	def base_influence(row,col)
		return  @enemyInfluence[row,col] -  @myInfluence[row,col] 
	end
	
	def total_influence(row,col)
		return (base_influence(row,col) + food_value(row, col)  + @scout_map[row,col]) * @modifier_map[row,col]
	end
	
	def tension(row,col)
		return  @myInfluence[row,col] + @enemyInfluence[row,col]
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
		inf.each_with_index do |row, ix| 
			 if (ix >= rowStart && ix <=(rowStart + size))
			 	s << "[#{row[colStart,size].join(' | ')}]"  << "\n"
		 	end
		end
		return s
	end
		
	def addPoint (row, col, pointType, owner = 0)
		case pointType
		when :food
			@tile_map.add_food(row,col)
			@foodValues.add_influence(row, col, @settings.food_value, @settings.food_range)
		when :water
			@tile_map.add_water(row,col)
		when :ant
			ant = Ant.new row, col, true, owner,  self
			@tile_map.add_ant(row,col, owner)
			if ant.owner==0
				@my_ants.push ant
				@scout_map.update_view_range(row,col)
				@myInfluence.add_influence(row, col, @settings.myAnt_value, @settings.myAnt_range)
			else
				@enemy_ants.push ant
				@enemyInfluence.add_influence(row, col, @settings.enemyAnt_value, @settings.enemyAnt_range)
			end
			
		when :hill
			@tile_map.add_hill(row,col, owner)
			if (owner != 0)	# add to list of enemy hills
				@enemy_hills[[row,col]] = true if !@enemy_hills[[row,col]]
			else
				 @myInfluence.add_influence(row, col, @settings.myHill_value, @settings.myHill_range)
				 
				 if (@ai.turn_number <=1) # Only need to do this once as we can't start new hills!
					 @modifier_map.add_influence_linear(row, col, @settings.hill_defence_radius, @settings.hill_defence_radius)
			 	end
				 @my_hills[[row,col]] = true
			end

		else
			raise 'Invalid Point Added'
		end	
	end
	
	
		# Fills tiles surrounded on 3 sides, to prevent movement into them
	
	
	def update_hills
		@enemy_hills.each_pair do |key, val|
			if val
				#check if there is an ant (of mine) on this square
				if (@tile_map.my_ant?(key[0],key[1]))  # my ant on hill location - destroy it
					@enemy_hills[key] = false
				else
					 # add influence to this square
					@foodValues.add_influence(key[0], key[1],  @settings.enemyHill_value,  @settings.enemyHill_range)
				end
			end
		end
	end
	
	
	def update_ants(newAntPositions)
		@my_ants = []
		locations = Hash.new()
		newAntPositions.each do |pos|
			row, col = pos[0], pos[1]
						
			index = calc_index(row, col)
			
			if (@tile_map.my_hill?(row, col))
				ant = Ant.new(row, col, true, 0, self)
				@my_ants << ant 
				locations[index] = ant
			else
			
				# Check for the ant in the moved_to location
				if (ant = @moved_locations[index])
					ant.update_location(row, col)
					@my_ants << ant
					locations[index] = ant
				elsif (ant = @current_locations[index])   #check if still in old location
					ant.update_location(row, col)
					@my_ants << ant 
					locations[index] = ant
				else
					ant = Ant.new(row, col, true, 0, self)
					@my_ants << ant 
					locations[index] = ant
				end
			end
			# Can only have one ant in that square....
			@moved_locations[index] = nil
			@current_locations[index]  = nil		
		end
		
		# Add ants to map
		@my_ants.each do |a|
			@tile_map.add_ant(a.row,a.col, 0)
			@scout_map.update_view_range(a.row, a.col)
			@myInfluence.add_influence(a.row, a.col, @settings.myAnt_value, @settings.myAnt_range)
		end
		
		#Clear movement indexes
		@current_locations = locations
		@moved_locations = Hash.new()	
	end
	

	# Adds an node to the list of directions to check
	def add_direction(row, col, set, chkRow, chkCol, checked, dir)
		# Check if the square can be moved to.
		# Checks against:
		# => 	Array of previously checked values
		# => 	That the square can be moved through
		# => 	That the enemy presence in this square isn't too strong
		if (!checked[chkRow,chkCol])
			if (@tile_map.passable?(row,col) && base_influence(row,col) <= @settings.enemyThreshold ) 
				set << [row,col, dir]
			end
			checked[chkRow,chkCol] = true  # always checked as we have looked at it!
		end
	end
	# Gets the best direction for an ant to move in.
	# Performs a flood fill out to the distance radius, checking suqare values
	def get_best_targets(ant, radius)
		circ = (radius *2)-1
		checked = Array2D.new(circ, circ, false)
		
		nodes = []
		row = ant.row
		col = ant.col
		checked[0,0] = true
		
		add_direction(row + 1, col, nodes, 1,0, checked, :S)
		add_direction(row - 1, col, nodes, -1,0, checked, :N)
		add_direction(row, col +1, nodes, 0,1, checked, :E)
		add_direction(row, col -1, nodes, 0,-1, checked, :W)

		maxValue = total_influence(ant.row, ant.col)
		maxDir = []
		
	
		(1..radius-1).each do |distance|
			children = []
			nodes.each do |point|
	
				curRow, curCol, curDir = point[0], point[1], point[2]
				chkRow, chkCol = point[0] - row , point[1] - col

				# Get the value of the current square / distance from the ant
				val = total_influence(curRow,curCol) / distance.to_f

				# Update the distance list...
				if (val > maxValue)
					maxValue = val
					maxDir = [curDir]
				elsif (val == maxValue)	# Add to the available distance list
					maxDir << curDir
				end
				
				# Add child nodes in each of 4 directions
				if (distance < radius-1)	# no point expanding children on last node
					add_direction(curRow + 1, curCol, children, chkRow+1,chkCol, checked, curDir)
					add_direction(curRow - 1, curCol, children, chkRow-1,chkCol, checked, curDir)
					add_direction(curRow, curCol +1, children, chkRow,chkCol+1, checked, curDir)
					add_direction(curRow, curCol -1, children, chkRow,chkCol-1, checked, curDir)
				end	
			end				
					
			nodes = children	# update the toCheck list
		end
		maxDir.flatten!
		return maxDir.uniq
	end
end
# 
# m = Map.new(200,200, nil)
# a = Ant.new(100,100, true, 0, m)
# m.foodValues.add_influence(90,90, 1000,10)
# m.foodValues.add_influence(105,105, 1000,10)
# m.foodValues.add_influence(95,105, 1000,10)
# beginning = Time.now
# # code block
# 200.times do
# a.get_best_moves()
# end
# puts "Time elapsed #{Time.now - beginning} seconds"
# puts a.targetDirections.inspect