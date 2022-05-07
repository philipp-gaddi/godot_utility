extends Object
class_name DFS_itr


signal dfs_run

var result
var done
var started
var graph
var start_vertex
var key
var value

func _init(graph_:Graph, start_vertex_:Vertex, key_:String, value):
	
	self.start_vertex = start_vertex_
	self.graph = graph_
	self.done = false
	self.started = false
	self.result = null
	self.key = key_
	self.value = value

func next():
	if not started:
		started = true
		run()
	elif not done:
		emit_signal("dfs_run")

# G has to be unmarked
func run():
	
	var stack = [start_vertex]
	var vertex = null
	while not stack.empty():
		
		vertex = stack.pop_front()
		vertex.visited = true
		print(vertex.data[key])
		if vertex.data[key] == value:
			result = vertex
			yield(self, "dfs_run")
		
		for n in graph.neighbours(vertex):
			if not n.visited:
				stack.push_front(n)
	
	result = null
	done = true
