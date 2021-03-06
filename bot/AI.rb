#!/usr/bin/env ruby
#require 'logger'

class AI

	
	# Number of current turn. If it's 0, we're in setup turn. If it's :game_over, you don't need to give any orders; instead, you can find out the number of players and their scores in this game.
	attr_accessor	:turn_number
	
	# Game settings. Integers.
	attr_accessor :loadtime, :turntime, :rows, :cols, :turns, :viewradius2, :attackradius2, :spawnradius2, :seed
	# Radii, unsquared. Floats.
	attr_accessor :viewradius, :attackradius, :spawnradius
	
	# Number of players. Available only after game's over.
	attr_accessor :players
	# Array of scores of players (you are player 0). Available only after game's over.
	attr_accessor :score
	
	attr_accessor :map
	
	attr_accessor :settings
	
	

	# Initialize a new AI object. Arguments are streams this AI will read from and write to.
	def initialize settingsFile, stdin=$stdin, stdout=$stdout
		@stdin, @stdout = stdin, stdout
		@turn_number=0
		@did_setup=false
		@settings = settingsFile
	#	@log = Logger.new("log.txt")	
	#	@log.info("")
	#	@log.info("NEW GAME -----------------------------------------")	
		
	end
	
		
	# Zero-turn logic. 
	def setup # :yields: self
		read_intro
		yield self
		
		@stdout.puts 'go'
		@stdout.flush
		@map = Map.new(@rows, @cols, self)
		@did_setup=true
	end
	
	# Turn logic. If setup wasn't yet called, it will call it (and yield the block in it once).
	def run &b # :yields: self
		setup &b if !@did_setup
		
		over=false
		until over
			over = read_turn
			yield self
			
			@stdout.puts 'go'
			@stdout.flush
		end
		
	end

	# Internal; reads zero-turn input (game settings).
	def read_intro
		rd=@stdin.gets.strip
		warn "unexpected: #{rd}" unless rd=='turn 0'
		#@log.info("#{rd}")
		until((rd=@stdin.gets.strip)=='ready')
			_, name, value = *rd.match(/\A([a-z0-9]+) (\d+)\Z/)
		#	@log.info("#{rd}")
			case name
			when 'loadtime'; @loadtime=value.to_i
			when 'turntime'; @turntime=value.to_i
			when 'rows'; @rows=value.to_i
			when 'cols'; @cols=value.to_i
			when 'turns'; @turns=value.to_i
			when 'viewradius2'; @viewradius2=value.to_i
			when 'attackradius2'; @attackradius2=value.to_i
			when 'spawnradius2'; @spawnradius2=value.to_i
			when 'seed'; @seed=value.to_i
			else
				warn "unexpected: #{rd}"
			end
		end
	#	@log.info("#{rd}")
		@viewradius=Math.sqrt @viewradius2
		@attackradius=Math.sqrt @attackradius2
		@spawnradius=Math.sqrt @spawnradius2
	end
	
	
	# Internal; reads turn input (map state).
	def read_turn
		ret=false
		rd=@stdin.gets.strip
	#	@log.info("#{rd}")
		
		if rd=='end'
			@turn_number=:game_over
		#	@log.info("GAMEOVER")
			rd=@stdin.gets.strip
		#	@log.info("#{rd}")
			_, players = *rd.match(/\Aplayers (\d+)\Z/)
			@players = players.to_i
			
			rd=@stdin.gets.strip
		#	@log.info("#{rd}")
			_, score = *rd.match(/\Ascore (.*) (.*)\Z/)
			@score = score.split(' ').map{|s| s.to_i}
			puts "------------"
			puts "Score = #{@score}"
			@stdout.flush
			ret=true
		else
			_, num = *rd.match(/\Aturn (\d+)\Z/)
			@turn_number=num.to_i
		end
	
		@map.reset
		
		antPositions = []
		until((rd=@stdin.gets.strip)=='go')
		#	@log.info("#{rd}")
			_, type, row, col, owner = *rd.match(/(w|f|h|a|d) (\d+) (\d+)(?: (\d+)|)/)
			row, col = row.to_i, col.to_i
			owner = owner.to_i if owner
												
			case type
				when 'w'
					@map.addPoint row, col, :water
				when 'f'
					@map.addPoint row, col, :food
				when 'h'
					@map.addPoint row, col, :hill, owner
				when 'a'
					if (owner == 0)
						antPositions << [row,col]
					else
						@map.addPoint row, col, :ant,  owner
					end
				when 'd'	# Ignore dead ants for now
					# do nothing
				when 'r'
					# pass
				else
					warn "unexpected: #{rd}"
			end
		end
		@map.update_ants(antPositions)
		
		return ret
	end
	
	# Point can be an ant, a tile or a location
	def order point, direction
		# Write to standard out

		@stdout.puts "o #{point[0]} #{point[1]} #{direction.to_s.upcase}"
	#	puts "Moving Ant: #{point.location.inspect} -> #{direction}"
	end 
end