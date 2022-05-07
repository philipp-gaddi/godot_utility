extends Object
class_name Graph

# mostly based on the interface described here:
# https://en.wikipedia.org/wiki/Graph_(abstract_data_type)

var in_vertices:Dictionary
var out_vertices:Dictionary
var vertices:Array
var edge_weights:Dictionary
var vertex_id_counter:int

func _init():
	
	in_vertices = {}
	out_vertices = {}
	vertices = []
	edge_weights = {}
	vertex_id_counter = 0

func adjacent(vertex_A:Vertex, vertex_B:Vertex):
	
	return vertex_A in neighbours(vertex_B)

func neighbours(vertex:Vertex):

	return in_vertices.get(vertex, []) + out_vertices.get(vertex, [])

func non_neighbours(vertex:Vertex):
	var non_neighbours = []
	var neighbours = neighbours(vertex)
	
	for v in vertices:
		if v!=vertex and not v in neighbours:
			non_neighbours.append(v)
	
	return non_neighbours

func incoming_neighbours(vertex:Vertex):
	
	return in_vertices[vertex]

func outgoing_neighbours(vertex:Vertex):
	
	return out_vertices[vertex]

func add_vertex(vertex:Vertex):
	
	if vertex in vertices:
		print('vertex already exists in graph')
		return
	
	vertex.id = vertex_id_counter
	vertex_id_counter += 1
	
#	if vertex_id_counter > 9e18: # full
#		return
	
	in_vertices[vertex] = []
	out_vertices[vertex] = []
	vertices.append(vertex)

func remove_vertex(vertex:Vertex):
	
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
	

func add_edge(vertex_A:Vertex, vertex_B:Vertex):
	
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

func remove_edge(vertex_A:Vertex, vertex_B:Vertex):
	
	out_vertices[vertex_A].erase(vertex_B)
	in_vertices[vertex_B].erase(vertex_A)
	edge_weights.erase([vertex_A, vertex_B])

func reset_visited():
	
	for v in vertices:
		v.visited = false

func _to_string():
	# todo find something meaningful to post here, vertex, edge count or so
	return str(vertices)
