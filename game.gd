extends Control
@onready var board = $Board
@onready var slider = $HSlider
# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass






func _on_h_slider_value_changed(value):
	print(value)
	var size = board.set_grid_columns(value)
	board.inst(value)
	var squares = board.get_squares()
	board.color_squares()
	return size 
