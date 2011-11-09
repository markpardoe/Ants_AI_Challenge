# Ants AI Challenge framework
# by Matma Rex (matma.rex@gmail.com)
# Released under CC-BY 3.0 license

# Represents a single ant.
class Ant
	# Owner of this ant. If it's 0, it's your ant.
	attr_accessor :owner
	# Square this ant sits on.
	attr_accessor :tile
	
	attr_accessor :alive, :ai
	attr_accessor :target
	
	def initialize alive, owner, tile, ai
		@alive, @owner, @tile, @ai = alive, owner, tile, ai
		@target = nil
	end
	
	# True if ant is alive.
	def alive?; @alive; end
	# True if ant is not alive.
	def dead?; !@alive; end
	
	# Equivalent to ant.owner==0.
	def mine?; owner==0; end
	# Equivalent to ant.owner!=0.
	def enemy?; owner!=0; end
	
	#Equivalent to ant.moved==0
	def moved?; @target; end
	
	# Returns the row of square this ant is standing at.
	def row; @tile.location[0]; end
	# Returns the column of square this ant is standing at.
	def col; @tile.location[1]; end
	
	# Order this ant to go in given direction. Equivalent to ai.order ant, direction.
	def order direction
		@ai.order self, direction
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
		return 'Ant' + @tile.location.inspect
	end
	
	def tile
		return @tile
	end
	
	def location
		return @tile.location
	end 
end










