# Ants AI Challenge framework
# by Matma Rex (matma.rex@gmail.com)
# Released under CC-BY 3.0 license

# Represents a single ant.
require "Utilities.rb"
class Ant
	include Utilities
	# Owner of this ant. If it's 0, it's your ant.
	attr_accessor :owner
	# Square this ant sits on.

	attr_accessor :alive, :map
	#attr_accessor :moved

	#attr_accessor :targetDirections
	
	def initialize row, col, alive, owner, map
		@alive, @owner, @map  = alive, owner, map
		@row, @col = row, col
	#	@moved = false

		@targetDirections = []
	end
	
	# True if ant is alive.
	def alive?; @alive; end
	# True if ant is not alive.
	def dead?; !@alive; end
	
	# Equivalent to ant.owner==0.
	def mine?; owner==0; end
	# Equivalent to ant.owner!=0.
	def enemy?; owner!=0; end
	
#	#Equivalent to !ant.moved?
#	def moved?; @moved; end
	
	# Returns the row of square this ant is standing at.
	def row; @row; end
	# Returns the column of square this ant is standing at.
	def col; @col; end

	def update_location(row, col)
		@row, @col = row, col
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
 	
	def get_best_moves(search_radius)
		@targetDirections = @map.get_best_targets(self,search_radius)
	end
	
	def move
		directions = @targetDirections
		moved = false
		# Check if ant is to stay still...
		if directions.empty?
			moved = true 
		else
			tiles = @map.tile_map
			directions.each do |dir|
				if (!moved) 
					dest = neighbor(location, dir)
					r, c = dest[0], dest[1]
					
					if (!tiles.occupied?(r, c))
						# Send the move order
						@map.ai.order location, dir
						
						# Remove old position from tilemap
						tiles.remove_ant(@row, @col)
						
						# Add ant at new position
						tiles.add_ant(r, c,0)
						
						@row, @col = r, c
						moved =  true
					end
				end
			end
		end
		
		if moved
			 ix = @map.calc_index(@row, @col)
			@map.moved_locations[ix] = self
		end
		return moved
	end 
	
	
end










