extends Node3D
# Create a bunch of nodes with a boolean that lets us know if they are occupied or not
# Once we find that out, add the node to the graph
# Once all nodes are in graph, go through graph and add adjaceny nodes

@export var grid_height : int = 16
@export var grid_width : int = 16
@export var grid_depth : int = 32

@export var node_size_min : Vector3 = Vector3(1, 1, 1)
@export var node_size_max : Vector3 = Vector3(8, 8, 8)

@onready var collision_detector : Area3D = $Area3D
@onready var collision_shape : CollisionShape3D = $Area3D/CollisionShape3D
@onready var debug_timer : Timer = $Timer

var is_occupied = false

var collision_detectors : Array
var marked_for_removal : Array

var mesh_generated : bool = false

func node_occupied(body : Node3D):
	is_occupied = true
	
func node_clear(body : Node3D):
	is_occupied = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape.shape.size = Vector3(10, 10, 10)
	print(collision_shape.shape.size)
	await grid_generator()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!mesh_generated):
		for detector : Area3D in collision_detectors:
			if(detector.get_overlapping_bodies().size() > 0):
				var mesh = MeshInstance3D.new()
				var shape = BoxMesh.new()
				shape.size = node_size_max
				mesh.mesh = shape
				mesh.global_position = detector.global_position
				add_child(mesh)
				print("DETECTED ", mesh.global_position)
			detector.queue_free()
		mesh_generated = true
		
# When generating grid, we want to do 
func grid_generator():
	var detections = 0
	for z in range(-grid_depth/2, grid_depth/2):
		for y in range(-grid_height/2, grid_height/2):
			for x in range(-grid_width/2, grid_width/2):
				var area = Area3D.new()
				var col = CollisionShape3D.new()
				var shape = BoxShape3D.new()
				
				shape.size = node_size_max
				col.shape = shape
				
				area.add_child(col)
				area.global_position = Vector3(x * node_size_max.x, y * node_size_max.y, z * node_size_max.z)
				add_child(area)
				collision_detectors.append(area)
	return true
