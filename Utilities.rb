 
module Utilities 
 	# Expects two 2 element arrays [row, col], [row1,col1]
 	# Or two tiles
 	# Or two ant
 	# Or any combination of the above...
	def eculidean_distance(point1, point2)
		(point1[0] - point2[0])**2  + (point1[1] - point2[1])**2 
	end
		
	 	
	# Expects two 2 element arrays [x, y], [x1,y1]
	# Or two tiles
 	# Or two ant
 	# Or any combination of the above...
 	#http://en.wikipedia.org/wiki/Taxicab_geometry
	def move_distance(point1, point2)
		dR = (point1[0] - point2[0]).abs
		dC = (point1[1]-point2[1]).abs
		# Deal with wraparound map
		dR = @rows - dR if (dR*2 > @rows)
		dC = @cols - dC if (dC*2 > @cols)

		return dR + dC
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
	
		# Generates an array holding the view radius of a ant
	# Array made up of pairs [xOffset, yOffset]
	# xOffset = squares horizontal from center
	# yOffset = maximum distance of viewable range (from center) in the column XoffSet
	def generate_area(distance2)
		distance2
		initalPoint = [0,0]
		distance = Integer(Math.sqrt(distance2))
		viewRadius = []
		xCounter = 1
		yCounter = distance
		viewRadius.push([0 , distance])
		
		while (xCounter <= distance) do
			x =  xCounter
			y =  yCounter		

			if ((eculidean_distance(initalPoint, [xCounter,yCounter])) <= distance2)
				#Within range, so can use this square
				viewRadius.push([xCounter, yCounter])
				viewRadius.push([-xCounter, yCounter])
				xCounter += 1
			else
				yCounter -=1 # move in slightly and try again
			end
		end
		return viewRadius
	end
end