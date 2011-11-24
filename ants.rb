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

	attr_accessor :targetValue
	attr_accessor :targetRow
	attr_accessor :targetCol
	
	def initialize row, col, alive, owner, map
		@alive, @owner, @map = alive, owner, map
		@row, @col = row, col
		@moved = false
		@targetValue = 0
		@targetRow = nil
		
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

	def update_location(row, col)
		@row, @col = row, col
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
 	
	def check_max_value(row2, col2, value)
		dR = (row - row2).abs
		dC = (col-col2).abs
		# Deal with wraparound map
		dR = @map.rows - dR if (dR*2 > @map.rows)
		dC = @map.cols - dC if (dC*2 > @map.cols)
		
		if (dR + dC) != 0
		
			eval = value / (dR + dC)
			if (eval > @targetValue)
				@targetValue = eval
				targetRow = row2
				targetCol = col2
			end
		end
	end
	
	def dirs_to_target()
		return [] if !@targetRow
		dirs = []
		
		if (@row > @targetRow)
			dirs.push[:N]
		elsif (@row < @targetRow)
			dirs.push[:S]
		end
		
		if (@col > @targetCol)
			dirs.push[:W]
		elsif (@col < @targetCol)
			dirs.push[:E]
		end
		dirs
	end

end










