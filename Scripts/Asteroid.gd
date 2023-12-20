extends RigidBody3D

@export var asteroid_type = "stone"
var asteroid_state = 3
var ore_amount = 0
var update_flag = false

@onready var collider = $CollisionShape3D
@onready var model = $Icosphere

func _ready():
	ore_amount = randf_range(10, 25)
	asteroid_state = randi_range(1, 3)
	update_flag = true

func _process(delta):
	#If we have newer information, update it.
	#Flag allows us to save performance by only updating when we have new info
	if update_flag:
		update_scale()
		self.mass = asteroid_state * asteroid_state * asteroid_state
		
		update_flag = false
		
func update_scale():
	match(asteroid_state):
		1:
			model.scale = Vector3(1, 1, 1)
			collider.scale = Vector3(1, 1, 1)
		2:
			model.scale = Vector3(3, 3, 3)
			collider.scale = Vector3(3, 3, 3)
		3:
			model.scale = Vector3(5, 5, 5)
			collider.scale = Vector3(5, 5, 5)
		_:
			print("Bro what?")
