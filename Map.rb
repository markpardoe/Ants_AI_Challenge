$:.unshift File.dirname($0)
require 'Array2D.rb'
require "InfluenceMap.rb"
require "TileMap.rb"
require "Utilities.rb"
require "ScoutMap.rb"

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
 	
 	attr_accessor :tile_map
 
 	attr_accessor :my_ants
	attr_accessor :enemy_ants
	
	attr_accessor :rows
 	attr_accessor :cols
 	
 	
	#Creates the new map object of the given size
	def initialize(rows, columns, ai)	
		@rows = rows
		@cols = columns
		@settings = ai.settings
		@ai = ai
		
		@tile_map = TileMap.new(@rows, @cols)
		@enemy_hills = Hash.new(false)
		
		viewRad = @ai.nil? ? 5 : @ai.viewradius2	# allows for blank ai values in testing

		@scout_map = ScoutMap.new(@rows,@cols, @settings.scoutCounter, viewRad)
		
		@foodValues = InfluenceMap.new(@rows,@cols,@tile_map)
		@enemyInfluence = InfluenceMap.new(@rows,@cols,@tile_map)
		@myInfluence = InfluenceMap.new(@rows,@cols,@tile_map)
		
				
		@my_ants=[]
		@enemy_ants=[]
	end
	
	def reset() 
		@my_ants=[]
		@enemy_ants=[]
		@tile_map.reset
		@tile_map.fill_holes(@scout_map)
		
		
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
		return  @enemyInfluence[row,col] - @myInfluence[row,col]
	end
	
	def total_influence(row,col)
		return base_influence(row,col) + food_value(row, col)  + @scout_map[row,col]
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
	

	def try_move_ant ant
		directions = ant.targetDirections
		# Check if ant is to stay still...
		return true if directions.empty?
		
		directions.each do |dir|
			dest = neighbor(ant, dir)
			if (!@tile_map.occupied?(dest[0], dest[1]))
				# Moves the ant to the new tile.
				@ai.order ant, dir
				# Remove old position from tilemap
				@tile_map.remove_ant(ant.row, ant.col)
				# Add ant at new position
				@tile_map.add_ant(dest[0], dest[1],0)
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


	def add_direction(row, col, set, chkRow, chkCol, checked, dir)
		if (!checked[chkRow,chkCol] && @tile_map.passable?(row,col))
			set << [row,col, dir]
			checked[chkRow,chkCol] = true
		end
	end

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

		maxValue =-99999
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
		return maxDir.uniq
	end
end
	