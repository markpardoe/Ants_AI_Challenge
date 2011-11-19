
foodValue = 100
foodDecay = 6.0
distance = 0
beginning = Time.now

	map = Array.new()
	(0..199).each do |x|
		map[x] = Array.new(200, x**2)
	end
		map[4][4] = 200
(1...5).each do |x|

	map.each do |row|
		row.each do |val|
			val = val *2
		end
	end
end



	
# code block
puts "Time elapsed #{Time.now - beginning} seconds"


# 
# def propagateInfluence()
# 	maxInf = 0.0
# 	
# 	#map.each_with_index do |rowMap, row |
# 	#	rowMap.each_with_index do |val, col|
# 	#		connections = [[row, col-1], [row, col+1], [row-1, col], [row+1, col], [row+1,col+1], [row-1,col-1]]]
# 			
# 	#		connections.each do |connect|
# 	#			inf = 	
# 	#		end
# 	#	end
# 	#end
# end
	


# 	void InfluenceMap::propagateInfluence()
# {
#   for (size_t i = 0; i < m_pAreaGraph->getSize(); ++i)
#   {
	# 	float maxInf = 0.0f;
	# 	Connections& connections = m_pAreaGraph->getEdgeIndices(i);
	# 	for (Connections::const_iterator it = connections.begin();
	#  		it != connections.end(); ++it)
	# 	 { 
	#   	const AreaConnection& c = m_pAreaGraph->getEdge(*it);
	#   	float inf = m_Influences[c.neighbor] * expf(-c.dist * m_fDecay);
	#    	maxInf = std::max(inf, maxInf);
	#  	 }
	# 
	# 	m_Influences[i] = lerp(m_Influences[i], maxInf, m_fMomentum);
#   }
# }