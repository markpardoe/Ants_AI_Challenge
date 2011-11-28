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
		self[row,col] = (owner == 0? 3 : 4) if !my_hill?(row,col)
	end
	
	def remove_ant(row,col)
		self[row,col] = 1
	end
	
	def add_hill(row,col, owner)
		self[row,col] = -1 if owner == 0
	end	
	
	def my_hill?(row, col)
		self[row,col] == -1
	end
	
	 # Scoutmap should be a 2D array of scouting values
  	def fill_holes(scoutMap)
		(0..@rows-1).each do |row|
			(0..@cols-1).each do |col|
				# Only check visible squares
				if (scoutMap[row,col] == 0 && !water?(row,col))
					count = 0
					count +=1 if water?(row-1,col)
					count +=1 if water?(row+1,col)
					count +=1 if water?(row,col - 1)
					count +=1 if water?(row,col + 1)
					add_water(row, col)  if (count >= 3)
				end
			end
		end
	end
		
end
