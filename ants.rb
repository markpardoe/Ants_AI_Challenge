# Ants AI Challenge framework
# by Matma Rex (matma.rex@gmail.com)
# Released under CC-BY 3.0 license

# Represents a single ant.

class Ant

	# Owner of this ant. If it's 0, it's your ant.
	attr_accessor :owner
	# Square this ant sits on.

	attr_accessor :alive, :Map
	attr_accessor :moved

	def initialize row, col, alive, owner, mapController, map
		@alive, @owner, @mapController, @map = alive, owner, mapController, map
		@row, @col = row, col
		@moved = false
		@index = @map.calculateIndex(row, col)
		puts "Max Size of grid: #{[@rows, @cols].inspect}"
	end
	
	# True if ant is alive.
	def alive?; @alive; end
	# True if ant is not alive.
	def dead?; !@alive; end
	
	# Equivalent to ant.owner==0.
	def mine?; owner==0; end
	# Equivalent to ant.owner!=0.
	def enemy?; owner!=0; end
	
	#Equivalent to !ant.moved?
	def moved?; @moved; end
	
	# Returns the row of square this ant is standing at.
	def row; @row; end
	# Returns the column of square this ant is standing at.
	def col; @col; end

	def index; @index; end
	
	def update_location(row, col)
		@row, @col = row, col
		@index = @map.calculateIndex(row, col)
		@moved = true
	end

	def eql? (object)
		if object.equal?(self)
			return true 
		elsif !self.class.equal?(object.class)
  			 return false
  		end
  		return @owner == object.owner && @alive = object.alive? && row == object.row && col == object.col	
	end
	
	def to_s
		return 'Ant' + location.inspect
	end
	
	def location
		return [@row, @col]
	end 
	
	def[](index)
		location[index]
	end
 	

end










