class_name Set extends Node


var _data: Dictionary


func _init() -> void:
    _data = {}


func add(v: Variant) -> void:
    if not has(v):
        _data[v] = null


func has(v: Variant) -> bool:
    return _data.has(v)


func length() -> int:
    return len(getData())


func remove(v: Variant) -> void:
    if not has(v):
        return
    _data.erase(v)


func clear() -> void:
    _data = {}


func getData() -> Array:
    return _data.keys()


func isEmpty() -> bool:
    return length() == 0