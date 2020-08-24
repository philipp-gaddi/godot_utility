extends Node

# this file contains some graph methods
# ref was wikipedia



class Vertex: 
	var visited
	var value
	
	func _init(init_value=""):
		self.value = init_value
		visited = false
	
	func _to_string():
		
		return str(value)


class Graph: # no edge weight
	
	# implementation as adjacency list
	var nodes:Dictionary # Vertex:Array of Vertex
	
	func _init():
		nodes = {}
	
	func adjacent(vertex_a:Vertex, vertex_b:Vertex)->bool:
		
		return vertex_b in neighbours(vertex_a) and vertex_a in neighbours(vertex_b)
	
	func neighbours(vertex:Vertex):
		return nodes.get(vertex)
	
	func add_vertex(new_vertex:Vertex):
		if nodes.get(new_vertex) == null:
			
			nodes[new_vertex] = []
		else:
			print("vertex already exists in graph")
	
	func remove_vertex(vertex:Vertex):
		if nodes.get(vertex) == null:
			
			return
		
		for n in neighbours(vertex):
			nodes.get(n).erase(vertex)
		
		nodes.erase(vertex)
		# free vertex? look up gdscript gc
	
	func add_edge(vertex_a:Vertex, vertex_b:Vertex):
		
		nodes.get(vertex_b).append(vertex_a)
		nodes.get(vertex_a).append(vertex_b)
	
	func remove_edge(vertex_a:Vertex, vertex_b:Vertex):
		
		if not adjacent(vertex_a, vertex_b):
			return
		
		nodes.get(vertex_a).erase(vertex_b)
		nodes.get(vertex_b).erase(vertex_a)
	
	func reset_visit():
		
		for k in nodes.keys():
			k.visited = false
	
	func depth_first_search(value, start_vertex=null):
		if start_vertex == null:
			start_vertex = nodes.keys()[1]
		
		var vertex_stack = [start_vertex]
		
		while not vertex_stack.empty():
			var vertex = vertex_stack.pop_front()
			
			if vertex.value == value:
				reset_visit()
				return vertex
			
			if not vertex.visited:
				vertex.visited = true
				for n in neighbours(vertex):
					vertex_stack.push_front(n)
		
		return null
	
	func breadth_first_search(value, start_vertex=null):
		if start_vertex == null:
			start_vertex = nodes.keys()[1]
		
		start_vertex.visited = true
		var vertex_queue = [start_vertex]
		
		while not vertex_queue.empty():
			var vertex = vertex_queue.pop_back()
			
			if vertex.value == value:
				reset_visit()
				return vertex
			
			for n in neighbours(vertex):
				if not n.visited:
					n.visited = true
					vertex_queue.push_front(n)
		
		return null
	
	func basic_alg():
		
		
		pass
	
	func mating_alg():
		
		
		pass
	
	func spanning_tree():
		
		
		pass
	
	func save_graph(path="user://saves/graph.json"):
		
		var json = JSON.print(nodes)
		
		var file = File.new()
		file.open(path, File.WRITE)
		file.store_string(json)
		file.close()
	
	
	func load_graph(path="user://saves/graph.json"):
		
		var file = File.new()
		file.open(path, File.READ)
		var json = file.get_as_text()
		file.close()
		
		nodes = JSON.parse(json).result
	
	func get_adjacency_matrix_representation():
		
		pass
































