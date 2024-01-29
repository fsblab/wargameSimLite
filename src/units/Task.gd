class_name Task extends Node


var args: Array:
	get: return args
var hasDelta: bool:
	get: return hasDelta
var task: Callable:
	get: return task


func _init(t: Callable, a: Array, d: bool):
	task = t
	args = a
	hasDelta = d
