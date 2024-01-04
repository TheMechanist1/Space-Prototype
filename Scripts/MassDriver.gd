extends Activatable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func activate(type) -> void:
	match(type):
		"Left Mouse Button":
			%AnimationPlayer1.play("FireAction")
			print(multiplayer.get_unique_id(), " ", "FIRE")
		_:
			pass
