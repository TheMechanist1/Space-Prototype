extends Node3D

enum State {IDIL, SEARCHING, STEALING, SHOOTING, FLEEING}

@onready var root_node = get_parent_node_3d()
@onready var agent = %Agent

var target_randomizer
var current_target
var current_state : State = State.IDIL

# Called when the node enters the scene tree for the first time.
func _ready():
	target_randomizer = Utility.random_from_dict(GameManager.Players)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for player in get_tree().get_nodes_in_group("Players"):
		if(player.name == str(target_randomizer.id)):
			current_target = player
			Utility.look_at_node(root_node, player.head)

	match current_state:
		State.IDIL:
			root_node.position = Utility.move_toward_vector3(root_node.position, current_target.position, delta * 10)
