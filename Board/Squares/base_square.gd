extends Button
@onready var button:Button = $"."
@onready var color_rect:ColorRect = $ColorRect
@onready var sprite2D:Sprite2D = $CenterContainer/Sprite2D
# Called when the node enters the scene tree for the first time.
	
func set_color(color): 
	color_rect.color =  color
func get_color():
	return color_rect.color
func set_texture(texture:Texture):
	sprite2D.texture = texture
func  get_texture():
	return sprite2D.texture

func set_sprite_name(piece:String):
	sprite2D.name = piece
func get_sprite_name():
	return sprite2D.name
func get_has_moved():
	return sprite2D.get_meta("Has_Moved")
	
func set_has_moved(boolean = true):
	sprite2D.set_meta("Has_Moved",boolean)
	
func get_moved_twice():
	return sprite2D.get_meta("Moved_Twice")


func set_moved_twice(boolean = false):
	sprite2D.set_meta("Moved_Twice", boolean)




