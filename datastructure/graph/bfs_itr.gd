extends Object

class_name BFS_itr


signal bfs_run

var result:Vertex
var done:bool
var started:bool
var graph:Graph
var start_vertex:Vertex
var key:String
var value

func _init(graph_:Graph, start_vertex_:Vertex, key_:String, value_):
	self.start_vertex = start_vertex_
	self.graph = graph_
	self.done = false
	self.started = false
	self.result = null
	self.key = key_
	self.value = value_

func next():
	if not started:
		started = true
		run()
	elif not done:
		emit_signal("bfs_run")

# G has to be unmarked
func run():
	
	var queue = [start_vertex]
	var vertex = null
	start_vertex.visited = true
	
	while not queue.empty():
		vertex = queue.pop_back()
		
		if vertex.data[key] == value:
			result = vertex
			yield(self, "bfs_run")
		
		for n in graph.neighbours(vertex):
			if not n.visited:
				n.visited = true
				queue.push_front(n)
	
	result = null
	done = true
