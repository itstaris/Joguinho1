extends Node

@export var obstaculo_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 6
var screen_size : Vector2i
var ground_height : int
var obs_array : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	
	ground_height = $Chao.get_node("Sprite2D").texture.get_height()
	
	new_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	
	obs_array.clear()
	gerar_obstaculos()
	
	$CharacterBody2D.reset()
	
func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $CharacterBody2D.flying:
						$CharacterBody2D.flap()
						check_top()
						
func start_game():
	game_running = true
	$CharacterBody2D.flying = true
	$CharacterBody2D.flap()
	
	$TimerdoObstaculo.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		
		if scroll >= screen_size.x:
			scroll = 0
			
		$Chao.position.x = -scroll
		
		for obstaculo in obs_array:
			obstaculo.position.x -= SCROLL_SPEED
		
		
	
func gerar_obstaculos():
	var obstaculo = obstaculo_scene.instantiate()
	obstaculo.position.x = screen_size.x + PIPE_DELAY
	obstaculo.position.y = (screen_size.y - ground_height)/2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	obstaculo.hit.connect(pingo_hit)
	add_child(obstaculo)
	obs_array.append(obstaculo)
	
func check_top():
	if $CharacterBody2D.position.y < 0:
		$CharacterBody2D.falling = true
		stop_game()
	
func stop_game():
	$TimerdoObstaculo.stop()
	$CharacterBody2D.flying = false
	game_running = false
	game_over = false
	
func pingo_hit():
	$CharacterBody2D.falling = true
	stop_game()

func _on_chao_hit():
	$CharacterBody2D.falling = false
	stop_game()
	


func _on_timerdo_obstaculo_timeout() -> void:
	gerar_obstaculos()
