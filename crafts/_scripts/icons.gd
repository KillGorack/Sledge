extends Control

@export var grid_container: GridContainer

func _ready():
	Utilities.update_icon.connect(_on_icon_updated)

func _on_icon_updated(icon: Texture2D, add_icon: bool):
	if add_icon:
		for child in grid_container.get_children():
			if child.texture and child.texture == icon:
				return
		var texture_rect = TextureRect.new()
		texture_rect.texture = icon
		texture_rect.custom_minimum_size = Vector2(30, 30)
		texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		texture_rect.expand = true
		texture_rect.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT
		grid_container.add_child(texture_rect)
	else:
		for child in grid_container.get_children():
			if child.texture and child.texture == icon:
				child.queue_free()
				break
