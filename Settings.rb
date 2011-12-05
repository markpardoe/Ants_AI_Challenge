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
	attr_reader :hill_defence_radius
	
	def initialize
		@enemyThreshold =1000
		@scoutCounter = 100
		@food_value = 5000
		@food_range = 3
		
		@myAnt_value = 500
		@myAnt_range = 4
		@enemyAnt_value = 2000
		@enemyAnt_range = 7
		
	    @enemyHill_value = 10000
		@enemyHill_range = 20
		
		@myHill_value = 2000000
		@myHill_range = 2	
		
		@hill_defence_radius = 10
		@hill_defence_modifier = 20
	end
end