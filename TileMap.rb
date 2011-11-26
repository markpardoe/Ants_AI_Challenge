$:.unshift File.dirname($0)
require 'Array2D.rb'
class TileMap < Array2D
	
	# Values = 
	# :myHill = -1
	# :water = 0
	# :land = 1
	# :food = 2
	# :myAnt = 3
	# :enemyAnt = 4
	# ignore enemy hills as they are passable
	def initialize(row, cols)
		super(row, cols, 1)
		puts "Data length = #{@data.length}"
	end
	
	def reset()
		self.each do |row|
			row.map! {|x| x > 1 ? 1 : x}
		end
	end
	
	
	def my_ant?(row,col)
		self[row,col] == 3
	end
	
	def water?(row, col)
		self[row,col] == 0
	end
	
	def passable?(row,col)
		return self[row,col] >= 1
	#puts "#{[row, col].inspect}"
	end
	
	def occupied?(row, col)
		self[row,col] != 1 
	end
	
	def add_water(row,col)
		self[row,col] = 0
	end
	
	def add_food(row,col)
		self[row,col] = 2
	end
	
	def add_ant(row,col, owner)
		self[row,col] = (owner == 0? 3 : 4)
	end
	
	def remove_ant(row,col)
		self[row,col] = 1
	end
	
	def add_hill(row,col, owner)
		self[row,col] = -1 if owner == 0
	end	
	

		
end
