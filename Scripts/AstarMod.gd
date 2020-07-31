extends AStar2D

func _estimate_cost(from_id, to_id):
	var from = get_point_position(from_id)
	var to = get_point_position(to_id)
	return manhattan_dist(from,to)

func _compute_cost(from_id, to_id):
	var from = get_point_position(from_id)
	var to = get_point_position(to_id)
	return manhattan_dist(from,to)

func manhattan_dist(from,to):
	
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	return dx + dy
