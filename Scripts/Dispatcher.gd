extends Node2D

var interaction_queue = []
signal open_encounter_screen
signal open_exchange_screen
signal open_city_menu

func _on_Ship_target_entity_reached(targeting_entity, target_entity):
	if targeting_entity.player_ship == true:
		resolve_player_interaction(target_entity)
	else:
		resolve_interaction(targeting_entity, target_entity)

func resolve_player_interaction(target_entity):
	print("resolving player junk")
	if target_entity.is_ship == true:
		emit_signal("open_encounter_screen", target_entity.captain, target_entity)
	elif target_entity.is_city == true:
		emit_signal("open_city_menu", target_entity)
	elif target_entity.is_ship == false and target_entity.is_city == false:
		emit_signal("open_exchange_screen", target_entity)

func resolve_interaction(targeting_entity, target_entity):
	if target_entity.is_ship == true:
		pass
	elif target_entity.is_city == true:
		targeting_entity.captain.on_destination_reached()
	else:
		targeting_entity.captain.on_destination_reached()
