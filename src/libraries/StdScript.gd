class_name StdScript extends Object


static var editableNodes: Array[String] = ["LineEdit", "TextEdit", "SpinBox"]
static var disableableNodes: Array[String] = ["BaseButton"]


static func any(arrayOfBool: Array) -> bool:
	for i in arrayOfBool:
		if i:
			return true
	return false


static func all(arrayOfBool: Array) -> bool:
	for i in arrayOfBool:
		if not i:
			return false
	return true


static func filter(someArray: Array, condition: Callable) -> Array:
	var filteredArray: Array = []
	for i in someArray:
		if condition.call(i):
			filteredArray.append(i)
	return filteredArray


static func map(someArray: Array, someFunc: Callable) -> Array:
	var mappedArray: Array = []
	for i in someArray:
		mappedArray.append(someFunc.call(i))
	return mappedArray


static func dmap(someDict: Dictionary, someFunc: Callable) -> Dictionary:
	var mappedDict: Dictionary
	for key in someDict.keys():
		mappedDict[key] = someFunc.call(someDict[key])
	return mappedDict


static func mapOverLeaveNodes(node: Node, mapper: Callable, condition: Callable) -> void:
	if node.get_child_count() == 0:
		if condition.call(node):
			mapper.call(node)
		return
	for child in node.get_children():
		mapOverLeaveNodes(child, mapper, condition)


static func mapOverAllChildNodes(node: Node, mapper: Callable, condition: Callable) -> void:
	if condition.call(node):
		mapper.call(node)
		return
	for child in node.get_children():
		mapOverAllChildNodes(child, mapper, condition)


static func getFileNameByExtension(mapDir: String, ext: String) -> String:
	var re: RegEx = RegEx.new()
	re.compile(".+\\.(" + ext + ")$")
	
	var dir: DirAccess = DirAccess.open(mapDir)
	
	if dir.get_files().is_empty():
		return ""
	
	#get name of first file that ends in given extension
	for file in dir.get_files():
		if (re.search(file)):
			return file
	
	return ""


@warning_ignore("confusable_local_declaration")
static func enableDisableLeaves(node: Node, id: int) -> void:
	if id != 1:
		mapOverLeaveNodes(node, func(node: Node): node.disabled = true, func(node): return any(map(disableableNodes, func(item): return node.is_class(item))))
		mapOverLeaveNodes(node, func(node: Node): node.editable = false, func(node): return any(map(editableNodes, func(item): return node.is_class(item))))
	else:
		mapOverLeaveNodes(node, func(node: Node): node.disabled = false, func(node): return any(map(disableableNodes, func(item): return node.is_class(item))))
		mapOverLeaveNodes(node, func(node: Node): node.editable = true, func(node): return any(map(editableNodes, func(item): return node.is_class(item))))
