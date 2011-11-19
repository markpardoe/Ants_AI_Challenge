
# Represent a single field of the map.
class Tile
	# Ant which sits on this square, or nil. The ant must be alive!
	attr_accessor :ant
	# Which row this square belongs to.
	attr_accessor :row
	# Which column this square belongs to.
	attr_accessor :col
	
	attr_accessor :food_influence
	
	# How many turns since this square was last seen.
	# Can be used to allow scouting of unspotted squares
	# To get the value, call tile.scount_value
	# This allows us to take account of water squares which will always be zero
	attr_writer  :scout_value
	
	# Boolean values (except AI!)
	attr_accessor :water, :food, :hill
	
	def initialize row, col
		@water = false
		@food = false
		@hill = false
		@ant = nil
		@row = row
		@col = col
		@scout_value = 0
		@food_influence = 0.0
	end
	
	def reset
		@food=false
		@ant=nil
		@hill=false
		@scout_value +=1
		@food_influence = 0#@food_influence / 3.0 if !@water
	end
	
	def scout_value
		if land?
			@scout_value
		else
			0 # water always counts as scouted...
		end
	end
	
	# Returns true if this square is not water. Square is passable if it's not water, it doesn't contain alive ants and it doesn't contain food.
	def land?; !@water; end
	# Returns true if this square is water.
	def water?; @water; end
	# Returns true if this square contains food.
	def food?; @food; end
	# Returns owner number if this square is a hill, false if not
	def hill?; @hill; end
	# Returns true if this square has an alive ant.
	def ant?; @ant and @ant.alive?; end;
	#returns true if this tile has been viewed at some point
	def viewed?(gameLength)
		return (@scout_value < gameLength)
	end
	
	#  Tile[0] = row
	#  Tile[1] = column
	def [](index)
		location[index]
 	end
	
 	
	def is_passable?
	#	Can't move to a square containing water, food or an ant.
		return !@water && !@food && !@ant
	end
	
	def location
		return [@row, @col]
	end 
	
	def eql? (object)
		if object.equal?(self)
			return true 
		elsif !self.class.equal?(object.class)
  			 return false
  		end
  		
  		return @row == object.row && @col == object.col
	end
	
	def to_s
		if (@water)
			code = "W"
		elsif (@hill)
			code = "H"
		elsif (@food)
			code = "F"
		elsif (ant?)
			code = "A"
		else
			code = "-"
		end
		
		return location.inspect + " - " 
	end
	

	
end


