class_name Player extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 25 # m/s
@export_range(10, 400, 1) var acceleration: float = 25 # m/s^2
@export var SENSITIVITY: float = 1 # m/s^2


@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
		
@export var move_dir: Vector2 # Input direction for movement
@export var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity
var updown_vel: Vector3

@onready var camera: Camera3D = $Head/Camera
@onready var head = $Head
@onready var model = $Model
@onready var RayCast = $Head/RayCast3D

	
func _on_enter_tree():
	camera.current = false
	
func _ready() -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	print("Name:", name, " Auth:", $MultiplayerSynchronizer.get_multiplayer_authority(), " id:", multiplayer.get_unique_id())
	$Label3D.text = str(name)
	capture_mouse()
	
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		model.visible = false
		camera.current = true
	else:
		model.visible = true
		camera.current = false

func _unhandled_input(event: InputEvent) -> void:	
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		if event is InputEventMouseMotion:
			look_dir = event.relative * 0.001
			#if mouse_captured: _rotate_camera()
			head.rotate_y(-event.relative.x * SENSITIVITY)
			model.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			
			$Head/RayCast3D.rotation.x = camera.rotation.x + deg_to_rad(90)
		
		if event is InputEventMouseButton and event.is_pressed():
			if(RayCast.is_colliding() && RayCast.get_collider()):
				var collider = RayCast.get_collider()
				var script_node = collider.get_node("ScriptNode") if collider.has_node("ScriptNode") else null
				if(script_node is Activatable):
					script_node.activate(event.as_text())
					script_node.activate_rpc.rpc(event.as_text())
		
		if Input.is_action_just_pressed("exit"):
			Lobby.server_disconnected.emit()
			get_tree().quit()
			
		print(camera.rotation_degrees)
		camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))	
		camera.rotation.y = 0
		camera.rotation.z = 0

func _physics_process(delta: float) -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		velocity = _walk(delta) + _gravity(delta) + _jump(delta)
		move_and_slide()
		
		var collision = move_and_slide()
		if collision and get_slide_collision(0).get_collider() is RigidBody3D:
			var push_direction = velocity.normalized()
			var push_strength = 1
			get_slide_collision(0).get_collider().apply_central_impulse(push_direction * push_strength)
			
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("left", "right", "forward", "backward")
	if(!move_dir.is_zero_approx()):
		var move_dir_norm = move_dir.normalized()
		var rotation_angle = atan2(-move_dir_norm.y, move_dir_norm.x) + deg_to_rad(-90)
	
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(velocity.x, velocity.y - gravity, velocity.z) + up_direction, gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	var dir = 0
	
	if Input.is_action_pressed("up"):
		dir = -1
	if Input.is_action_pressed("down"):
		dir = 1
		
	jump_vel = Vector3(0, dir*speed, 0)
	
	jump_vel = jump_vel.move_toward(Vector3.ZERO, acceleration * delta)
	return jump_vel
