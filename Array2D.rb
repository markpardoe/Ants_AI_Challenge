#!/usr/bin/env ruby
require 'logger'
require 'thread'

class Array2D
 include Enumerable
  
 def initialize(rows , cols, initalValue = nil)
  	@data = Array.new(rows){|row| Array.new(cols,initalValue)}
  	@rows = rows
  	@cols = cols
  end
  
  def [](row, col = nil)
  	row = row % @rows if (row >= @rows or row<0)	# normalise the row
  	col = col % @cols if (col >= @cols or col<0)	# normalise the column
   	@data[row][col]
  end
  	

   
  def []=(row, col,  value)
  	row = row % @rows if (row >= @rows or row<0)	# normalise the row
  	col = col % @cols if (col >= @cols or col<0)	# normalise the column
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
end

# m = Array2D.new(3,3,0)
# m[0,0] = 3
# m[0,0] += 1
# puts m[4,4]
# 
