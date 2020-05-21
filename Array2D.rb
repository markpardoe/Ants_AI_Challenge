#!/usr/bin/env ruby

class Array2D
  
 def initialize(rows , cols, initalValue = nil)
  	@data = Array.new(rows){|row| Array.new(cols,initalValue)}
  	@rows = rows
  	@cols = cols
  end
  
  def [](row, col = nil)
  	row = row % @rows if (row >= @rows or row<0)	# normalise the row
  	col = col % @cols if (col >= @cols or col<0)	# normalise the column
 # 	raise "Invalid co-ordinates #{[row,col].inspect}" if ((row >= @rows) || (col >= @cols))
  
  	 @data[row][col]
  end
  	   
  def []=(row, col,  value)
  	row = row - @rows if (row >= @rows)	# normalise the row
  	col = col - @cols if (col >= @cols)	# normalise the column
  	
  #	raise "Invalid co-ordinates #{[row,col].inspect}" if ((row >= @rows) || (col >= @cols))
  	
    @data[row][col] = value
  end
  
  def each(&block) # Returns each row
    @data.each do |row|
      	block.call(row)
    end
  end
    
  def to_s
  	s = ""
  	@data.each do |row| 
  		s << row.inspect << "\n"
  	end
  	s
  end
  
  	# If row or col are greater than or equal map width/height, makes them fit the map.
	#
	# Handles negative values correctly (it may return a negative value, but always one that is a correct index).
	#
	# Returns [row, col].
	def normalize row, col
		[row % @rows, col % @cols]
	end
end

