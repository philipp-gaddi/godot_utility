extends Node


class Vertex:
	
	var type:String
	var data:Dictionary
	var visited
	var position:Vector2
	var id # set by graph
	
	func _init(init_type="", init_position=Vector2(), init_data={}):
		
		type = init_type
		position = init_position
		data = init_data
		visited = false
	
	func _to_string():
		
		return str(id)
	

class Graph:
	
	var in_vertices
	var out_vertices
	var vertices
	var edge_weights
	var vertex_id_counter
	
	func _init():
		in_vertices = {}
		out_vertices = {}
		vertices = []
		edge_weights = {}
		vertex_id_counter = 0
	
	func adjacent(vertex_A, vertex_B):
		
		return vertex_A in neighbours(vertex_B)
	
	func neighbours(vertex):
	
		return in_vertices.get(vertex, []) + out_vertices.get(vertex, [])
	
	func non_neighbours(vertex):
		var non_neighbours = []
		var neighbours = neighbours(vertex)
		
		for v in vertices:
			if v!=vertex and not v in neighbours:
				non_neighbours.append(v)
		
		return non_neighbours
	
	func incoming_neighbours(vertex):
		
		return in_vertices[vertex]
	
	func outgoing_neighbours(vertex):
		
		return out_vertices[vertex]
	
	func add_vertex(vertex):
		
		if vertex in vertices:
			print('vertex already exists in graph')
			return
		
		vertex.id = vertex_id_counter
		vertex_id_counter += 1
		in_vertices[vertex] = []
		out_vertices[vertex] = []
		vertices.append(vertex)
	
	func remove_vertex(vertex):
		
		in_vertices.erase(vertex)
		out_vertices.erase(vertex)
		vertices.erase(vertex)
		
		# todo check deleting while traversing
		for v in in_vertices.keys():
			in_vertices[v].erase(vertex)
		
		for v in out_vertices.keys():
			out_vertices[v].erase(vertex)
		
		for e in edge_weights:
			if vertex in e:
				edge_weights.erase(e)
		
	
	func add_edge(vertex_A, vertex_B):
		
		if not vertex_A in vertices or not vertex_B in vertices:
			print('vertices don\'t exist')
			return
		
		if vertex_B in out_vertices[vertex_A] or \
			vertex_A in in_vertices[vertex_B]:
				print('edge exists')
				return
		
		out_vertices[vertex_A].append(vertex_B)
		in_vertices[vertex_B].append(vertex_A)
		edge_weights[[vertex_A, vertex_B]] = 1.0
	
	func remove_edge(vertex_A, vertex_B):
		
		out_vertices[vertex_A].erase(vertex_B)
		in_vertices[vertex_B].erase(vertex_A)
		edge_weights.erase([vertex_A, vertex_B])
	
	func reset_visited():
		
		for v in vertices:
			v.visited = false
	
	func _to_string():
		
		return str(in_vertices) + str(out_vertices)

static func save_graph(G:Graph, path="user://saves/graph"):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_var(G)
	file.close()

static func load_graph(path="user://saves/graph"):
	var file = File.new()
	file.open(path, File.READ)
	var G = file.get_var()
	file.close()
	return G

class GraphPatternMatch:
	# VF2
	var sub_graph:Graph
	
	func _init(init_sub_graph:Graph):
		
		sub_graph = init_sub_graph
	
	func match_pattern():
		
		
		return []

class DFS_itr:
	# can continue searches after founding a matching vertex
	signal dfs_run
	
	var result
	var done
	var started
	var graph
	var start_vertex
	var type
	
	func _init(G:Graph, init_type, vertex:Vertex):
		
		start_vertex = vertex
		self.graph = G
		self.type = init_type
		self.done = false
		self.started = false
		self.result = null
	
	func next():
		if not started:
			started = true
			run()
		elif not done:
			emit_signal("dfs_run")
	
	# G has to be unmarked
	func run():
		
		var stack = [start_vertex]
		while not stack.empty():
			
			var vertex = stack.pop_front()
			
			vertex.visited = true
			
			if vertex.type == type:
				result = vertex
				yield(self, "dfs_run")
			
			for n in graph.neighbours(vertex):
				if not n.visited:
					stack.push_front(n)
		
		done = true

class BFS_itr:
	
	signal bfs_run
	
	var result
	var done
	var started
	var graph
	var start_vertex
	var type
	
	func _init(G:Graph, init_type, vertex:Vertex):
		start_vertex = vertex
		self.graph = G
		self.type = init_type
		self.done = false
		self.started = false
		self.result = null
	
	func next():
		if not started:
			started = true
			run()
		elif not done:
			emit_signal("bfs_run")
	
	# G has to be unmarked
	func run():
		
		var queue = [start_vertex]
		start_vertex.visited = true
		
		while not queue.empty():
			var vertex = queue.pop_back()
			
			if vertex.type == type:
				result = vertex
				yield(self, "bfs_run")
			
			for n in graph.neighbours(vertex):
				if not n.visited:
					n.visited = true
					queue.push_front(n)
		
		done = true

class SpringEmbedder:
	
	var graph:Graph
	var start_vertex:Vertex
	
	func _init(init_graph:Graph, init_start_vertex:Vertex):
		
		graph = init_graph
		start_vertex = init_start_vertex
	
	func initial_placement():
		
		# idea: place a vertex, place it's neighbours spreaded in fron (right) of it
		
		var queue = [start_vertex]
		start_vertex.visited=true
		
		while not queue.empty():
			var delta = Vector2(0,-180)
			var vertex = queue.pop_back()
			var neighbours = graph.neighbours(vertex)
			var unvisited_neighbours = 0
			
			if neighbours.empty():
				continue
			
			for n in neighbours:
				if not n.visited:
					unvisited_neighbours += 1
			
			var angle_delta = PI / (unvisited_neighbours + 1)
			var angle = 0
			
			for n in neighbours:
				if not n.visited:
					angle += angle_delta
					delta = delta.rotated(angle)
					n.position = vertex.position + delta
					n.visited = true
					queue.push_front(n)
		graph.reset_visited()
	
	func spring_sum(v):
		# factor, bigger means stronger
		var c_spring = .03
		# optimal length of an edge in px
		var l = 50
		var sum = Vector2()
		
		for u in graph.neighbours(v):
			var uv = (u.position - v.position).normalized()
			sum = c_spring * log(v.position.distance_to(u.position) / l) * uv
		
		return sum
	
	func rep_sum(v):
		# factor, bigger means bigger force for repulsion
		var c_rep = 2
		# edges to non neighbours
		var sum = Vector2()
		for u in graph.non_neighbours(v):
			var uv = (u.position - v.position).normalized()
			sum += c_rep / v.position.distance_squared_to(u.position) * uv
		
		return sum
	
	# spring embedder after eades 1984
	func run(K = 100, epsilon = .05, delta = 1.3):
		# K number of iterations
		# epsilon number of forcetreshold, if there's only weak forces stop
		# delta factor for applying force to vertex
		
		graph.reset_visited()
		
		initial_placement()
		
		# F dictionary with forces for each vertex
		var F = {}
		# interation index
		var t = 1
		# max Force currently
		var max_F = Vector2(1,0)
		
		while t < K and max_F.length() > epsilon:
			for v in graph.vertices:
				var f = spring_sum(v) + rep_sum(v)
				if f.length() > max_F.length():
					max_F = f
				F[v] = f
			
			for v in graph.vertices:
				v.position = v.position + delta * F[v]
				
			t += 1


































































