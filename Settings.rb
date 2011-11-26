class Settings
	
	attr_reader :enemyThreshold
	attr_reader :scoutCounter
	attr_reader :food_value
	attr_reader :food_range
	attr_reader :myAnt_value
	attr_reader :myAnt_range
	attr_reader :enemyAnt_value
	attr_reader :enemyAnt_range
	attr_reader :enemyHill_value
	attr_reader :enemyHill_range
	attr_reader :myHill_value
	attr_reader :myHill_range
	
	def initialize
		@enemyThreshold = 1000
		@scoutCounter = 50
		@food_value = 5000
		@food_range = 7
		
		@myAnt_value = 1000
		@myAnt_range = 3
		@enemyAnt_value = 2000
		@enemyAnt_range = 7
		
	    @enemyHill_value = 100000
		@enemyHill_range = 20
		
		@myHill_value = 100
		@myHill_range = 1	
	end
end