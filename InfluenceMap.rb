
class InfluenceMap < Array

	def initialize(rows, columns, defaultValue)
		super(rows*columns, defaultValue)
		@rows = rows
		@cols = columns
	end

	def calculateIndex(row,col)
	 	row = row % @rows if (row >= @rows or row<0)
		col =col % @cols if (col >= @cols or col<0)
		return (col + (row * @cols))
 	end

	def increment(value) 
		self.each_with_index {|x, i| self[i] = x + value}
	end
	
	def getValue(row, col)
		return self[calculateIndex(row,col)]
	end
	
end

m = Array.new(5, Integer(5))
m[2] = 4

c = m.dup
c[2] = 6
puts m.inspect
puts ""
puts c.inspect