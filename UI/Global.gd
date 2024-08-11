extends Node

var user_data = {}

func set_user_data(data: Dictionary):
	user_data = data

func get_user_data() -> Dictionary:
	return user_data
