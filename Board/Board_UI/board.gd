extends Control


@onready var preset:board_preset = preload("res://Board/Board_presets/Normal.tres")
@onready var square = preload("res://Board/Squares/base_square.tscn")
@onready var grid_container = $GridContainer
@onready var slider = $"../HSlider"
var squares

func _ready():
	set_grid_columns()
	inst() # created 64 squares
	squares = get_squares() # creates an array of all squares
	
	color_squares()# colores the squares
	preset_to_board(preset) # puts the pieces on the board
	check_for_square_clicks()
	print(_on_square_id())
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass
func check_for_square_clicks():
	for square in squares:
		square.button_down.connect(get_square_id.bind(square))



func clear_inst():
	for n in grid_container.get_children():

		grid_container.remove_child(n)

		n.queue_free()

func inst(rows= get_grid_columns()):

	var board_squares = pow(rows,2)
	for i in board_squares: 
		var instance = square.instantiate()
		instance.name=str(i)
		grid_container.add_child(instance)


var black_square_color = Color(0.149, 0.286, 0.494)
var white_square_color = Color(1,1,1)
var attacking_color = Color(0.531, 0.185, 0.191)
func color_squares():
	var board_size = get_grid_columns()
	for i in board_size:
		for j in board_size:
			if (i*1+j)%2 == 0 :
				squares[i*board_size+j].set_color(white_square_color) # white
				pass
			else:
				squares[i*board_size+j].set_color(black_square_color) # black
				pass

func preset_to_board(preset):

	for i in squares.size():
		if i<preset.board_preset.size() and preset.board_preset[i]:
			squares[i].set_texture(preset.board_preset[i].texture)
			squares[i].set_sprite_name(preset.board_preset[i].name)
			squares[i].set_has_moved(false)
		else:
			squares[i].set_texture(null)
			squares[i].set_sprite_name("nothing")
			

func get_squares():
	var squares = grid_container.get_children()
	return squares
	
signal square_id(id)

func get_square_id(square):
	square_id.emit(square.name)


func get_grid_columns():
	var gridcolumns = grid_container.get("columns")
	return gridcolumns


func get_piece_from_id(id): 
	id = id.to_int()
	if id>=0:
		var piece = squares[id].get_sprite_name()
	
		return piece

func twod_board(board_size):
	var matrix=[]
	var value
	
	for x in range(board_size): # creates the matrix
		matrix.append([])

		for y in range(board_size):
			value = board_size
			matrix[x].append(y*board_size+x)
	return matrix


var piece_id # stores the old piece square id
func _on_square_id(id ="-1"): # Runs whenver a square is clicked
	var int_id = id.to_int()
	
	if int_id>=0 and squares[int_id].get_color()==attacking_color: # if valid id and square attaking is clicked
		int_id = take_piece(int_id, piece_id)
	
	if piece_id == int_id: # if same piece is clicked deselect it
		for square in squares:
			if square.get_color()== attacking_color:
				int_id = -1
				color_squares()

			
		

		
	if int_id>=0: # if valid id check piece clicked and do the correct moveset
		var piece_name = get_piece_from_id(id)  # stores name of the piece clicked
		print(id)
		print(piece_name)
		color_squares() # to remove attacking square color from piece before


		piece_id = int_id
		if piece_name.contains("_rook"): # This is how the rook moves on an empty board
			rook(int_id)
			
		if piece_name.contains("_bishop"):
			bishop(int_id)
		if piece_name.contains("_queen"):

			bishop(int_id)
			rook(int_id)
		if piece_name.contains("_knight"):
			knight(int_id)
		if piece_name.contains("_king"):
			king(int_id)
		if piece_name.contains("_pawn"):
			pawn(int_id,piece_name)
		
	
						
func bishop(int_id):# moveset for bishop
	var bishop_offsets1 = get_grid_columns()+1
	var bishop_offsets2 = get_grid_columns()-1
	var plus_index1 
	var minus_index1
	var plus_index2 
	var minus_index2
	var id_on_left_edge = false # this is a wierd edge case
	var attacking_piece_color 
	var current_piece_color = get_piece_color(int_id)
	var attacking_own_piece = false
	if int_id%get_grid_columns() ==0:
				id_on_left_edge = true
	for i in range(1,get_grid_columns()): # bottom right diagnol
			plus_index1 = int_id + i*bishop_offsets1
			if plus_index1<squares.size():
				attacking_piece_color= get_piece_color(plus_index1)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true

				break
			else: 
				
				attacking_own_piece = false
			if plus_index1%get_grid_columns() == 0: # whenever the square goes off the edge the loop will stop
				break
			if plus_index1<squares.size() and attacking_own_piece == false:
				squares[plus_index1].set_color(attacking_color)
			if plus_index1<squares.size() :
				attacking_piece_color= squares[plus_index1].get_sprite_name().get_slice("_",0)
				if attacking_piece_color != current_piece_color and attacking_piece_color != "nothing": # breaks if attacking the other color piece
					break
	for i in range(1,get_grid_columns()): # top left diagnol
			minus_index1 = int_id - i*bishop_offsets1
			if id_on_left_edge == true:
				break
			if minus_index1>=0:
				attacking_piece_color= get_piece_color(minus_index1)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
				break
			else: 
				
				attacking_own_piece = false
			
			if minus_index1>=0  and id_on_left_edge == false and attacking_own_piece == false:
				squares[minus_index1].set_color(attacking_color)
			if minus_index1%get_grid_columns() == 0: # whenever the square goes off the edge the loop will stop
				break
			if minus_index1>=0 and id_on_left_edge == false:
				attacking_piece_color= squares[minus_index1].get_sprite_name().get_slice("_",0)
				if attacking_piece_color != current_piece_color and attacking_piece_color != "nothing": # breaks if attacking the other color piece
					break
	for i in range(1,get_grid_columns()): # bottom left diagnol
			plus_index2 = int_id + i*bishop_offsets2
			if id_on_left_edge == true:
				break
			if plus_index2<squares.size():
				attacking_piece_color= get_piece_color(plus_index2)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
				break
			else: 
				
				attacking_own_piece = false
			
			if plus_index2<squares.size()  and id_on_left_edge == false and attacking_own_piece == false:
				squares[plus_index2].set_color(attacking_color)
			
			if plus_index2%get_grid_columns() == 0:  # whenever the square goes off the edge the loop will stop
				break
			if plus_index2<squares.size()and id_on_left_edge == false:
				attacking_piece_color= squares[plus_index2].get_sprite_name().get_slice("_",0)
				if attacking_piece_color != current_piece_color and attacking_piece_color != "nothing": # breaks if attacking the other color piece
					break
	for i in range(1,get_grid_columns()): # top right diagnol

			minus_index2 = int_id - i*bishop_offsets2
			if minus_index2>=0:
				attacking_piece_color= get_piece_color(minus_index2)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
				break
			else: 
				
				attacking_own_piece = false
			if minus_index2%get_grid_columns() == 0:  # whenever the square goes off the edge the loop will stop
				break
			
			
			if minus_index2>=0  and attacking_own_piece == false:
				squares[minus_index2].set_color(attacking_color)
			if minus_index2>=0  :
				attacking_piece_color= squares[minus_index2].get_sprite_name().get_slice("_",0)
				if attacking_piece_color != current_piece_color and attacking_piece_color != "nothing": # breaks if attacking the other color piece
					break
func rook(int_id):# moveset for rook
	var rook_offset = get_grid_columns()
	var index # square that is going to be colored next
	var row = int_id/get_grid_columns() # gets row rook is on starts at 0
	var attacking_own_piece = false
	var current_piece_color = squares[int_id].get_sprite_name().get_slice("_",0)
	var attacking_piece_color
	var over_edge
	for i in get_grid_columns():
		index = int_id + i*rook_offset
		
		if index>=0 and index<squares.size() and index != int_id :
			attacking_piece_color= squares[index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true

				break
			else: 
				
				attacking_own_piece = false
				
		if index<squares.size() and index != int_id and index>=0 and attacking_own_piece == false:

			squares[index].set_color(attacking_color)
		if index>=0 and index<squares.size() and index != int_id:
			attacking_piece_color= squares[index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color != current_piece_color and attacking_piece_color != "nothing": # breaks if attacking the other color piece
				break

	for i in get_grid_columns():
		index = int_id - i*rook_offset
		
		if index>=0 and index<squares.size() and index != int_id :
			attacking_piece_color= squares[index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
				print(attacking_piece_color)
				break
			else: 
				
				attacking_own_piece = false
				
		if index>=0 and index<squares.size() and index != int_id and attacking_own_piece == false:
			squares[index].set_color(attacking_color)
			print(index)
			
		if index>=0 and index<squares.size() and index != int_id:
			attacking_piece_color= squares[index].get_sprite_name().get_slice("_",0)

			if attacking_piece_color != current_piece_color and attacking_piece_color != "nothing": # breaks if attacking the other color piece
				
				break
				
	for i in get_grid_columns():
		index = int_id+i+1
		if index>=0 and index<squares.size() and index != int_id :
			attacking_piece_color= squares[index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
				break
			else: 
				
				attacking_own_piece = false
		if index%get_grid_columns()==0:
			over_edge = true
			break
		else:
			over_edge = false
				
		if index<squares.size() and index != int_id and over_edge == false and attacking_own_piece == false:
			squares[index].set_color(attacking_color)
		if index>=0 and index<squares.size() and index != int_id :
			attacking_piece_color= squares[index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color != current_piece_color and attacking_piece_color != "nothing": # breaks if attacking the other color piece
				break
	for i in get_grid_columns():
		index = int_id-i-1
		if index>=0 and index<squares.size() and index != int_id :
			attacking_piece_color= squares[index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
				break
			else: 
				
				attacking_own_piece = false
		if index%get_grid_columns()==get_grid_columns()-1:
			print(index)
			over_edge = true
			break
		else:
			over_edge = false
				
		if index<squares.size() and index != int_id and over_edge == false and attacking_own_piece == false and index>=0:
			squares[index].set_color(attacking_color)
		if index>=0 and index<squares.size() and index != int_id :
			attacking_piece_color= squares[index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color != current_piece_color and attacking_piece_color != "nothing": # breaks if attacking the other color piece
				break		
func knight(int_id):# moveset for knight
	var knight_offset =[2*get_grid_columns()+1,2*get_grid_columns()-1,2+get_grid_columns(),2-get_grid_columns()]
	for i in knight_offset.size():
		# need these because if any squares go over the edge it wont apply the offset
		# took alot of trial and error
		var plus_off_edge = false
		var minus_off_edge = false
		var piece_on_l_edge = false
		var piece_on_l2_edge = false
		var piece_on_l3_edge = false
		var piece_on_r_edge = false
		var piece_on_r2_edge = false
		var piece_on_r3_edge = false
		var plus_index:int = int_id+knight_offset[i]
		var minus_index:int = int_id-knight_offset[i]
		var attacking_own_piece = false
		var attacking_piece_color
		var current_piece_color = squares[int_id].get_sprite_name().get_slice("_",0)
		
		if int_id%get_grid_columns() == 1:
			if minus_index%get_grid_columns()==get_grid_columns()-1:
				plus_off_edge = true
		if int_id%get_grid_columns() == get_grid_columns()-2:
			if plus_index%get_grid_columns()==0:
				minus_off_edge = true
		if int_id%get_grid_columns() == 0:
			if minus_index%get_grid_columns()==get_grid_columns()-2 :
				piece_on_l_edge = true
		if int_id%get_grid_columns() == 0:
			if plus_index%get_grid_columns()==get_grid_columns()-1 :
				piece_on_l2_edge = true
		if int_id%get_grid_columns() == 0:
			if  minus_index%get_grid_columns()==get_grid_columns()-1 :
				piece_on_l3_edge = true
		if int_id%get_grid_columns() == get_grid_columns()-1:
			if plus_index%get_grid_columns()==1 :
				piece_on_r_edge = true
		if int_id%get_grid_columns() == get_grid_columns()-1:
			if minus_index%get_grid_columns()==0 :
				piece_on_r2_edge = true
		if int_id%get_grid_columns() == get_grid_columns()-1:
			if  plus_index%get_grid_columns()==0 :
				piece_on_r3_edge = true
		 
		if plus_index>=0 and plus_index<squares.size():
			attacking_piece_color= squares[plus_index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
			else: 
				attacking_own_piece = false



		if plus_index<squares.size() and plus_index>=0 and minus_off_edge == false and piece_on_l2_edge==false and piece_on_r_edge == false and piece_on_r3_edge== false and attacking_own_piece == false:
			squares[plus_index].set_color(attacking_color) 
		
		if minus_index>=0 and minus_index<squares.size():
			attacking_piece_color= squares[minus_index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
			else: 
				attacking_own_piece = false
		if minus_index>=0 and minus_index< squares.size() and plus_off_edge == false and piece_on_l_edge == false and piece_on_l3_edge == false and piece_on_r2_edge == false and attacking_own_piece == false:
			squares[minus_index].set_color(attacking_color)
func king(int_id):# moveset for king and castling
	var king_offset = [get_grid_columns(), get_grid_columns()-1, get_grid_columns()+1,1]
	for i in king_offset.size():
		var plus_index = int_id + king_offset[i]
		var minus_index = int_id - king_offset[i]
		var off_edge_l = false
		var off_edge_l2 = false
		var off_edge_r = false
		var off_edge_r2 = false
		var attacking_own_piece = true
		var current_piece_color = get_piece_color(int_id)
		var attacking_piece_color
		var can_castle = false
		if int_id%get_grid_columns() == 0:
			if minus_index%get_grid_columns() ==get_grid_columns()-1:
				off_edge_l = true
			if plus_index%get_grid_columns()== get_grid_columns()-1:
				off_edge_l2 = true
		if int_id%get_grid_columns() == get_grid_columns()-1:
			if plus_index%get_grid_columns()==0:
				off_edge_r = true
			if minus_index %get_grid_columns() ==0:
				off_edge_r2 = true
		
		if plus_index>=0 and plus_index<squares.size():
			attacking_piece_color= get_piece_color(plus_index)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
			else: 
				attacking_own_piece = false
		if plus_index>=0 and plus_index<squares.size() and off_edge_r == false and off_edge_l2 == false and attacking_own_piece == false:
			squares[plus_index].set_color(attacking_color)
		if minus_index>=0 and minus_index<squares.size():
			attacking_piece_color= squares[minus_index].get_sprite_name().get_slice("_",0)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
			else: 
				attacking_own_piece = false
		if minus_index>=0 and minus_index<squares.size() and off_edge_l == false and off_edge_r2 == false and attacking_own_piece == false:
			squares[minus_index].set_color(attacking_color)
		
		if int_id-2>=0 and int_id-2<squares.size() :# castling code
			
			if get_piece_color(int_id-2) == "nothing" and get_piece_color(int_id-3) == "nothing":
				can_castle = true
			else: 
				can_castle = false
		if int_id-1>=0 and int_id-1<squares.size() :# castling code
			attacking_piece_color = get_piece_color(int_id-1)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
			else: 
				attacking_own_piece = false		
		if squares[int_id].get_has_moved() == false and squares[int_id-4].get_has_moved()== false and get_piece_color(int_id-4) == get_piece_color(int_id) and attacking_own_piece == false and can_castle == true:
			squares[int_id-2].set_color(attacking_color)
			
			
		if int_id+2>=0 and int_id+2<squares.size() :# castling code
			
			if get_piece_color(int_id+2) == "nothing":
				can_castle = true
			else: 
				can_castle = false
		if int_id+1>=0 and int_id+1<squares.size() :# castling code
			attacking_piece_color = get_piece_color(int_id+1)
			if attacking_piece_color == current_piece_color:
				attacking_own_piece = true
			else: 
				attacking_own_piece = false		
		if squares[int_id].get_has_moved() == false and squares[int_id+3].get_has_moved()== false and get_piece_color(int_id+3) == get_piece_color(int_id) and attacking_own_piece == false and can_castle == true:
			squares[int_id+2].set_color(attacking_color)
				
func pawn(int_id,piece_name):# moveset for black and white pawn
	var on_left_edge = false # so attacks don't go over left edge
	var on_right_edge = false # so attack don't go over right edge
	if int_id%get_grid_columns()==0:
		on_left_edge = true
	elif int_id%get_grid_columns()==get_grid_columns()-1:
		on_right_edge = true
	if piece_name.contains("B_pawn"):
		var piece_infront = false
		
		var pawn_offset =int_id + get_grid_columns()

		var pawn_attack1 = int_id + get_grid_columns()+1
		var pawn_attack2 = int_id + get_grid_columns()-1
		if pawn_offset<squares.size() and squares[pawn_offset].get_sprite_name() != "nothing":
			piece_infront = true
			
		if pawn_offset<squares.size() and piece_infront == false:
			squares[pawn_offset].set_color(attacking_color)
		if pawn_attack1<squares.size():
			if squares[pawn_attack1].get_sprite_name().begins_with("W") and on_right_edge == false:
				squares[pawn_attack1].set_color(attacking_color)
				print("attack")
			if squares[pawn_attack2].get_sprite_name().begins_with("W") and on_left_edge == false:
				squares[pawn_attack2].set_color(attacking_color)
				print("attack")
		if squares[int_id].get_has_moved() == false:
			pawn_offset =int_id + (2*get_grid_columns())
			if pawn_offset<squares.size() and squares[pawn_offset].get_sprite_name() != "nothing":
				piece_infront = true
				
			if pawn_offset<squares.size() and piece_infront == false:
				squares[pawn_offset].set_color(attacking_color)
		# code below is enpassant code
		if  on_left_edge == false and get_piece_color(int_id-1)=="W" and squares[int_id-1].get_moved_twice() == true:
			squares[int_id-1+get_grid_columns()].set_color(attacking_color)
		if on_right_edge == false and get_piece_color(int_id+1)=="W" and squares[int_id+1].get_moved_twice() == true :
			squares[int_id+1+get_grid_columns()].set_color(attacking_color)
	elif piece_name.contains("W_pawn"):
		var piece_infront = false
		
		var pawn_offset =int_id - get_grid_columns()


		var pawn_attack1 = int_id - get_grid_columns()+1
		var pawn_attack2 = int_id - get_grid_columns()-1
		if squares[pawn_offset].get_sprite_name() != "nothing":
			piece_infront = true
		if pawn_offset>=0 and piece_infront == false:
			squares[pawn_offset].set_color(attacking_color)	
		if pawn_attack1>0 :
			if squares[pawn_attack1].get_sprite_name().begins_with("B") and on_right_edge == false:
				squares[pawn_attack1].set_color(attacking_color)

			if squares[pawn_attack2].get_sprite_name().begins_with("B") and on_left_edge == false:
				squares[pawn_attack2].set_color(attacking_color)

				
		if squares[int_id].get_has_moved() == false:
			pawn_offset =int_id - (2*get_grid_columns())
			if pawn_offset>=0 and squares[pawn_offset].get_sprite_name() != "nothing":
				piece_infront = true
			
			if pawn_offset<squares.size() and piece_infront == false:
				squares[pawn_offset].set_color(attacking_color)
		if on_left_edge == false and get_piece_color(int_id-1)=="B" and squares[int_id-1].get_moved_twice() == true:
			squares[int_id-1-get_grid_columns()].set_color(attacking_color)
		if on_right_edge == false and get_piece_color(int_id+1)=="B" and squares[int_id+1].get_moved_twice() == true:
			squares[int_id+1-get_grid_columns()].set_color(attacking_color)
var player_turn = "W" # player turn starts as white
func take_piece(int_id, piece_id):# takes pieces from piece_id to int_id
	var piece_color = get_piece_color(piece_id)
	reset_moved_twice()
	if piece_color == player_turn:
		if player_turn == "W": # player turn switches every turn
			player_turn = "B"
		elif player_turn == "B":
			player_turn = "W"
		var id = str(piece_id)
		var piece_name = get_piece_from_id(id)  # stores name of the piece clicked
		print("moved ", piece_name," id:",piece_id, " to ", int_id)
		var swap_texture = squares[piece_id].get_texture()
		var swap_piece_name = squares[piece_id].get_sprite_name()
		var piece_taken = squares[int_id].get_sprite_name()
		squares[int_id].set_has_moved(true)
		squares[int_id].set_texture(swap_texture)
		squares[int_id].set_sprite_name(swap_piece_name)
		make_square_empty(piece_id)
		color_squares()
		if swap_piece_name.contains("pawn") and abs(int_id-piece_id)%(get_grid_columns()*2) == 0:
			print("pawn moved twice")

			squares[int_id].set_moved_twice(true)
			
			# en passent code
		if piece_taken =="nothing" and swap_piece_name.contains("pawn") and piece_id%int_id == get_grid_columns()-1 :
			print("you just en passented as white")
			make_square_empty(int_id+get_grid_columns())
		if piece_taken =="nothing" and swap_piece_name.contains("pawn") and piece_id%int_id == get_grid_columns()+1 :
			print("you just en passented as white")
			make_square_empty(int_id+get_grid_columns())
		if piece_taken =="nothing" and swap_piece_name.contains("pawn") and int_id%piece_id == get_grid_columns()-1 :
			print("you just en passented as black")
			make_square_empty(int_id-get_grid_columns())
		if piece_taken =="nothing" and swap_piece_name.contains("pawn") and int_id%piece_id == get_grid_columns()+1 :
			print("you just en passented as black")
			make_square_empty(int_id-get_grid_columns())
		# code below is castling code	
		if swap_piece_name.contains("king") and abs(piece_id - int_id)==2: # 
			print("castle")
			if get_piece_from_id(str(int_id+1)).contains("rook"):
				swap_texture = squares[int_id+1].get_texture()
				swap_piece_name = squares[int_id+1].get_sprite_name()
				squares[piece_id+1].set_has_moved(true)
				squares[piece_id+1].set_texture(swap_texture)
				squares[piece_id+1].set_sprite_name(swap_piece_name)
				make_square_empty(int_id+1)
				color_squares()
			elif get_piece_from_id(str(int_id-2)).contains("rook"):
				swap_texture = squares[int_id-2].get_texture()
				swap_piece_name = squares[int_id-2].get_sprite_name()
				squares[piece_id-1].set_has_moved(true)
				squares[piece_id-1].set_texture(swap_texture)
				squares[piece_id-1].set_sprite_name(swap_piece_name)
				make_square_empty(int_id-2)
				color_squares()

	
	int_id = -1 # need this so function after don't run
	return int_id

func get_piece_color(int_id):# gets the piece color of the square soecified. return "W" for whit and "B" for black
	var current_piece_color = squares[int_id].get_sprite_name().get_slice("_",0)
	return current_piece_color
func reset_moved_twice(): # makes sure enpassant lasts for one turn
	for square in  squares:
		square.set_moved_twice(false)
		
func make_square_empty(int_id):
	squares[int_id].set_has_moved(false)
	squares[int_id].set_texture(null)
	squares[int_id].set_sprite_name("nothing")
func set_grid_columns(size = 8):
	grid_container.set("columns",size)
	
	


func _on_h_slider_value_changed(value):
	player_turn = "W"
	set_grid_columns(value)
	clear_inst()
	inst(value) 
	squares = get_squares() # creates an array of all squares
	color_squares()# colores the squares
	preset_to_board(preset) # puts the pieces on the board
	check_for_square_clicks()
	pass # Replace with function body.
