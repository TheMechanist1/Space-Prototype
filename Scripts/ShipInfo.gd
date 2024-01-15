extends Node3D

var last_profit = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	last_profit = GameManager.current_profit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if last_profit != GameManager.current_profit:
		%ShipUI.get_node("Label2").text = str(GameManager.current_profit)
		last_profit = GameManager.current_profit
