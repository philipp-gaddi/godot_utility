extends Object
class_name Vertex

var data:Dictionary
var visited:bool
var id:int # set by graph, don't use it

func _init(init_data = {}):
	
	data = init_data
	visited = false
	id = -1

func _to_string():
	
	return "Vertex Id: %d" % id

func equals_in_value(key, vertex:Vertex):
	
	return self.data[key] == vertex.data[key]

func equals(vertex:Vertex):
	
	return self.id == vertex.id
