$:.unshift File.dirname($0)
require 'Array2D.rb'
class InfluenceMap < Array2D
	
	def initialize(row, cols, tilemap)
		super(row, cols, 0)
		@tiles = tilemap
	end
	
	def add_influence(row, col, val, radius)
		circ = (radius *2)-1
		checked = Array2D.new(circ, circ, false)
	
		nodes = [[row,col]]
		checked[0,0] = true

		(0..radius-1).each do |distance|
			children = []
			nodes.each do |point|

				curRow = point[0] 
				chkRow = point[0] - row
				curCol = point[1]
 				chkCol = point[1] - col

				self[curRow,curCol] += (val * (radius - distance))/radius 	#update tile value

				if (distance < radius-1)
					if (!checked[chkRow+1,chkCol] && @tiles.passable?(curRow+1,curCol))
						children << [curRow+1,curCol]
						checked[chkRow+1,chkCol] = true
					end
					if (!checked[chkRow-1,chkCol] && @tiles.passable?(curRow-1,curCol))
						children << [curRow-1,curCol]
						checked[chkRow-1,chkCol] = true
					end
					if (!checked[chkRow,chkCol+1] && @tiles.passable?(curRow,curCol+1))
						children << [curRow,curCol+1]
						checked[chkRow,chkCol+1] = true
					end
					if (!checked[chkRow,chkCol-1] && @tiles.passable?(curRow,curCol-1))
						children << [curRow,curCol-1]
						checked[chkRow,chkCol-1] = true
					end			
				end
			end					
			nodes = children
		end
	end
end