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
			GameManager.add_profit_rpc.rpc(10)
		_:
			pass
