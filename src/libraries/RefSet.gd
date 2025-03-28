class_name RefSet extends Node


var _data: Dictionary


func _init() -> void:
    _data = {}


func add(v: Variant, ref: Variant) -> void:
    if not has(v):
        _data[v] = Set.new()
    _data[v].add(ref)


func has(v: Variant) -> bool:
    return _data.has(v)


func length() -> int:
    return len(getData())


func remove(v: Variant, ref: Variant) -> void:
    if not has(v):
        return
    
    _data[v].remove(ref)

    if _data[v].isEmpty():
        _data.erase(v)


func getData() -> Array:
    return _data.keys()