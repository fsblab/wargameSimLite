class_name TaskHandler extends Node


var nextTask: Task:
	get: return nextTask
var taskQueue: Array:
	get: return taskQueue

var currentTask: Callable
var args: Array
var hasDelta: bool

var taskFinished: bool:
	get: return taskFinished


func _init():
	args = []
	hasDelta = false
	taskFinished = true
	taskQueue = []


func pushTask(t: Task) -> Task:
	if not Input.is_key_pressed(KEY_SHIFT):
		clearTaskQueue()
	taskQueue.push_back(t)
	return t


func push(t: Callable, a: Array, d: bool) -> Task:
	if not Input.is_key_pressed(KEY_SHIFT):
		clearTaskQueue()
	var tmp = Task.new(t, a, d)
	taskQueue.push_back(tmp)
	return tmp


func pushMultipleTasks(tasks: Array) -> Array:
	if not Input.is_key_pressed(KEY_SHIFT):
		clearTaskQueue()
	for t in tasks:
		taskQueue.push_back(t)
	return tasks


func pop(d = null) -> Task:
	nextTask = taskQueue.pop_front()
	currentTask = nextTask.task
	args = nextTask.args
	hasDelta = nextTask.hasDelta
	taskFinished = false
	if hasDelta:
		args.push_back(d)
	return nextTask


func callTask() -> bool:
	taskFinished = currentTask.callv(args)
	return taskFinished


func isEmpty() -> bool:
	if taskQueue.is_empty() and taskFinished:
		return true
	else:
		return false


func clearTaskQueue() -> void:
	taskFinished = true
	hasDelta = false
	taskQueue.clear()
