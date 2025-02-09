class_name Player
extends CharacterBody2D

var control_id: int
var nickname: String
var skin: String

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var nick_field: Label = $Nickname
@onready var sprite: Sprite2D = $Sprite2D

const ACCELERATION = 1500.0
const AIR_ACCELERATION = 500.0
const MAX_SPEED = 150.0
const JUMP_VELOCITY = 250.0
const GRAVITY = 1000.0
const MAX_FALL_SPEED = 500.0
const SLIDE_ACCELERATION = 1300.0
const SLIDE_SPEED = 60.0
const PASSIVE_FRICTION = 1000.0
const JUMP_BUFFER_LENGTH = 0.1

var jump_counter_oldest := 0
var jump_counter_newest := 0
var coyote_time := -1.0
var wall_coyote := -1.0
var last_wall_normal := Vector2.LEFT


func can_jump() -> bool:
	return jump_counter_oldest < jump_counter_newest


func _ready() -> void:
	multiplayer_synchronizer.set_multiplayer_authority(control_id)
	if control_id == multiplayer.get_unique_id():
		nick_field.visible = false
	else:
		nick_field.text = nickname
	
	if skin != "":
		var skin_data := Marshalls.base64_to_raw(skin)
		var skin_image := Image.create_from_data(14, 14, false, Image.FORMAT_RGBA8, skin_data)
		sprite.texture = ImageTexture.create_from_image(skin_image)
		sprite.scale = Vector2(1, 1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_counter_newest += 1
		var jump_number := jump_counter_newest
		get_tree().create_timer(0.1, false).timeout.connect(
			func () -> void:
				if jump_counter_oldest < jump_number:
					jump_counter_oldest += 1
		)


func _physics_process(delta: float) -> void:
	if (not multiplayer.has_multiplayer_peer()
			or not multiplayer.multiplayer_peer.get_connection_status() == 2
			or control_id != multiplayer.get_unique_id()):
		return
	
	var direction := Input.get_axis("left", "right")
	
	coyote_time -= delta
	if is_on_floor():
		coyote_time = 0.1
	wall_coyote -= delta
	if is_on_wall() and direction * get_wall_normal().x < 0:
		wall_coyote = 0.2
		last_wall_normal = get_wall_normal()
	
	if direction:
		var acc: float = ACCELERATION if is_on_floor() else AIR_ACCELERATION
		if velocity.x / direction < MAX_SPEED:
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED, acc * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, PASSIVE_FRICTION * delta)
	
	# Jump
	if can_jump():
		# Off the floor
		if coyote_time > 0:
			var jump_factor := (absf(velocity.x) / MAX_SPEED) * 0.2 + 0.8
			velocity.y = -JUMP_VELOCITY * jump_factor
			jump_counter_oldest += 1
			coyote_time = -1
		# Walljump
		elif wall_coyote > 0:
			var jump_impulse: Vector2 = (up_direction + last_wall_normal).normalized() * JUMP_VELOCITY
			velocity.x = jump_impulse.x
			velocity.y = jump_impulse.y + minf(velocity.y, 0)
			jump_counter_oldest += 1
			wall_coyote = -1
	
	# Gravity
	if not is_on_floor():
		# Wall slide
		if wall_coyote > 0 and velocity.y > SLIDE_SPEED:
			velocity.y = move_toward(velocity.y, SLIDE_SPEED, SLIDE_ACCELERATION * delta)
		# Normal gravity
		else:
			var gmult := 1.0
			if Input.is_action_pressed("jump") and velocity.y < 0:
				gmult *= 0.5
			velocity.y += GRAVITY * gmult * delta
	
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
	
	move_and_slide()
