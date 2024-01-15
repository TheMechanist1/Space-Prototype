extends Node

var version = "2024.01.08-1"
var Players = {}
var current_profit = 0

func _ready():
	pass
	
func add_profit(profit):
	current_profit += profit
	
@rpc("any_peer")
func add_profit_rpc(profit):
	add_profit(profit)
