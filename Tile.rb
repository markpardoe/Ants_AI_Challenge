
# Represent a single field of the map.
class Tile
	# Ant which sits on this square, or nil. The ant must be alive!
	attr_accessor :ant
	# Which row this square belongs to.
	attr_accessor :row
	# Which column this square belongs to.
	attr_accessor :col
	
	# Boolean values (except AI!)
	attr_accessor :water, :food, :hill, :ai
	
	attr_accessor :target
	
	def initialize row, col, ai
		@water, @food, @hill, @ant, @row, @col, @ai = false, false, false, nil, row, col, ai
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
	
	#Checks if an ant on this square has moved off....
	# Returns true if no ant to indicate the square is free
	def ant_moved?
		if @ant
			ant.moved?
		else
			true
		end
	end
	
	# Returns a square neighboring this one in given direction.
	def neighbor direction
		direction=direction.to_s.upcase.to_sym # canonical: :N, :E, :S, :W
	
		case direction
		when :N
			row, col = @ai.normalize @row-1, @col
		when :E
			row, col = @ai.normalize @row, @col+1
		when :S
			row, col = @ai.normalize @row+1, @col
		when :W
			row, col = @ai.normalize @row, @col-1
		else
			raise 'incorrect direction'
		end
		
		tile = @ai.map[[row, col]]
		if (tile.nil?)
			tile = Tile.new(row,col,@ai)
			@ai.map[[row,col]] = tile
		end
		
		return tile
	end
	
	def is_passable?
		return !@water && !@food && ant_moved?  && @ai.orders.has_value?(self)
	end
	
	def location
		return [row, col]
	end 
	
	def eql? (object)
		if object.equal?(self)
			return true 
		elsif !self.class.equal?(object.class)
  			 return false
  		end
  		
  		return row == object.row && col == object.col
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


