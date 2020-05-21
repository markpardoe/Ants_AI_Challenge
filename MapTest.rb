def add_influence(row, col, val, radius, map)
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

			#	puts "#{point.inspect} = #{[chkRow, chkCol].inspect} = #{(val * (radius - distance))/radius }"
				map[curRow,curCol] += (val * (radius - distance))/radius 	#update tile value
				
			#	puts checked.to_s 
			#	puts "------------" #if distance ==2
				if (distance < radius-1)
					if (!checked[chkRow+1,chkCol] && @tile_map[curRow+1,curCol] != 1)
						children << [curRow+1,curCol]
						checked[chkRow+1,chkCol] = true
					end
					if (!checked[chkRow-1,chkCol] && @tile_map[curRow-1,curCol] != 1)
						children << [curRow-1,curCol]
						checked[chkRow-1,chkCol] = true
					end
					if (!checked[chkRow,chkCol+1] && @tile_map[curRow,curCol+1] != 1)
						children << [curRow,curCol+1]
						checked[chkRow,chkCol+1] = true
					end
					if (!checked[chkRow,chkCol-1] && @tile_map[curRow,curCol-1] != 1)
						children << [curRow,curCol-1]
						checked[chkRow,chkCol-1] = true
					end			
				end
			end				
					
			nodes = children
		end
	end
	
	
	def addPoint (row, col, pointType, owner = 0)

		case pointType
		when :food
			@tile_map[row,col] = 3
			 add_influence(row, col, 3000,7, @foodValues)
			#flood_influence(row, col, 1000, 7, @foodValues)
		when :water
			@tile_map[row,col] = 1
		when :ant
			@tile_map[row,col] = 2

			ant = Ant.new row, col, true, owner,  self

			if ant.owner==0
				@my_ants.push ant
				update_view_range(row,col)
			#	flood_influence(row, col, 1000, 7, @myInfluence)
				add_influence(row, col, 1000,3, @myInfluence)
			else
				@enemy_ants.push ant
				add_influence(row, col, 2000,7, @enemyInfluence)
			#	flood_influence(row, col, 2000, 7, @enemyInfluence)
			end
			
		when :hill
			@tile_map[row,col] = -1
			add_influence(row, col, 10000,20, @foodValues) if (owner != 0) 
		#	flood_influence(row, col, 10000, 20, @enemyInfluence)
		else
			raise 'Invalid Point Added'
		end	
	end
	
	
	
	-------------------------------------------------------------------------------
	MyBot.rb:
	
	(0..maxRow-1).each do |row|
			
		rowIx = row * maxCol
		(0..maxCol-1).each do |col|
			if @mapController.tile_map[row,col] < 1	# is the square passable...
					if @mapController.base_influence(row,col) < @enemyThreshold
							val = @mapController.total_influence(row,col)
							
							myAnts.each do |ant|
								ant.check_max_value(row, col, val)
								
							end
					end
			end
		end	
	end
		
		# puts "total ants = #{myAnts.length}" ------------------------
		  @mapController.my_ants.each do |ants| 		
		 		d = @mapController.ant_dir_to_target(ants)
		 		puts "Ant #{[ants.row, ants.col].inspect} - Max Distance = #{ants.maxDistance}"
				@mapController.move_ant(ants, d ) if (!d.nil?)
		 end