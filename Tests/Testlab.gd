extends Control

# ideas: maybe log into a file

onready var graph = load("res://graph.gd")

func _ready():
	
	if test_adjacency():
		print('adjacency test passed')
	else:
		print('adjacency test failed')
	
	if test_neighbours():
		print('neighbours test passed')
	else:
		print('neighbours test failed')
	
	if test_add_vertex():
		print('add_vertex passed')
	else:
		print('add_vertex failed')
	
	if test_remove_vertex():
		print('remove_vertex passed')
	else:
		print('remove_vertex failed')
	
	if test_add_edge():
		print('add_edge passed')
	else:
		print('add_edge failed')
	
	if test_remove_edge():
		print('remove_edge passed')
	else:
		print('remove_edge failed')
	
	if test_reset_visit():
		print('reset_visit passed')
	else:
		print('reset_visit failed')
	
	if test_depth_first_search():
		print('depth_first_search passed')
	else:
		print('depth_first_search failed')
	
	if test_breadth_first_search():
		print('breadth_first_search passed')
	else:
		print('breadth_first_search failed')
	
	var g = make_test_graph()
#	g[index.G].save_graph()
#	g[index.G].nodes = {}
#	g[index.G].load_graph()
	
	get_tree().quit()

func make_graph():
	return graph.Graph.new()

func make_vertex(value=""):
	return graph.Vertex.new(value)

enum index {
	G, A, B, C, D, E, F
}

func make_test_graph():
	# the test graph looks like
	# A:[B]
	# B:[A, C, D]
	# C:[B, E]
	# D:[B, E]
	# E:[C, D, F]
	# F:[E]
	
	var G = make_graph()
	var A = make_vertex('A')
	var B = make_vertex('B')
	var C = make_vertex('C')
	var D = make_vertex('D')
	var E = make_vertex('E')
	var F = make_vertex('F')
	
	G.add_vertex(A)
	G.add_vertex(B)
	G.add_vertex(C)
	G.add_vertex(D)
	G.add_vertex(E)
	G.add_vertex(F)
	
	G.add_edge(A, B)
	G.add_edge(B, C)
	G.add_edge(B, D)
	G.add_edge(C, E)
	G.add_edge(D, E)
	G.add_edge(E, F)
	
	return [G, A, B, C, D, E, F]

func test_adjacency():
	
	var test_assets = make_test_graph()
	
	var G = test_assets[index.G]
	
	if not G.adjacent(test_assets[index.A], test_assets[index.B]):
		print("A adjacent to B")
		return false
	
	if G.adjacent(test_assets[index.A], test_assets[index.C]):
		print("A adjacent to C")
		return false
	
	if not G.adjacent(test_assets[index.F], test_assets[index.E]):
		print("F adjacent to E")
		return false
	
	if G.adjacent(test_assets[index.F], test_assets[index.B]):
		print("F adjacent B failed")
		return false
	
	if G.adjacent(test_assets[index.B], test_assets[index.E]):
		print("B adjacent to E")
		return false
	
	if not G.adjacent(test_assets[index.B], test_assets[index.C]):
		print("B adjacent to C")
		return false
	
	return true

func contains_same_elements(set_of_vertices_A, set_of_vertices_B):
	
	if set_of_vertices_A.size() != set_of_vertices_B.size():
		return false
	
	for v in set_of_vertices_A:
		if not v in set_of_vertices_B:
			return false
	
	return true

func test_neighbours():
	
	var test_assets = make_test_graph()
	var G = test_assets[index.G]
	
	var neighbours_of_A = [test_assets[index.B]]
	var neighbours_of_B = [test_assets[index.A], test_assets[index.C], test_assets[index.D]]
	var neighbours_of_C = [test_assets[index.B], test_assets[index.E]]
	var neighbours_of_D = [test_assets[index.B], test_assets[index.E]]
	var neighbours_of_E = [test_assets[index.C], test_assets[index.D], test_assets[index.F]]
	var neighbours_of_F = [test_assets[index.E]]
	
	if not contains_same_elements(G.neighbours(test_assets[index.A]), neighbours_of_A):
		print("neighbours of A")
		return false
	
	if not contains_same_elements(G.neighbours(test_assets[index.B]), neighbours_of_B):
		print("neighbours of B")
		return false
	
	if not contains_same_elements(G.neighbours(test_assets[index.C]), neighbours_of_C):
		print("neighbours of C")
		return false
	
	if not contains_same_elements(G.neighbours(test_assets[index.D]), neighbours_of_D):
		print("neighbours of D")
		return false
	
	if not contains_same_elements(G.neighbours(test_assets[index.E]), neighbours_of_E):
		print("neighbours of E")
		return false
	
	if not contains_same_elements(G.neighbours(test_assets[index.F]), neighbours_of_F):
		print("neighbours of F")
		return false
	
	return true

func test_add_vertex():
	
	var test_assets = make_test_graph()
	var G = test_assets[index.G]
	var vertex = make_vertex("G")
	
	G.add_vertex(vertex)
	if not vertex in G.nodes.keys():
		print('adding vertex failed')
		return false
	
	var node_count = G.nodes.keys().size()
	G.add_vertex(vertex)
	if node_count > G.nodes.keys().size():
		print('add vertex twice failed')
		return false
	
	return true

func test_remove_vertex():
	
	var test_assets = make_test_graph()
	var G = test_assets[index.G]
	
	# remove F
	G.remove_vertex(test_assets[index.F])
	
	if test_assets[index.F] in G.nodes.keys():
		print('remove F failed')
		return false
	
	if test_assets[index.F] in G.neighbours(test_assets[index.E]):
		print('remove F from neighbour E failed')
		return false
	
	# remove B
	G.remove_vertex(test_assets[index.B])
	
	if test_assets[index.B] in G.nodes.keys():
		print('remove B failed')
		return false
	
	if test_assets[index.B] in G.neighbours(test_assets[index.A]):
		print('remove B from neighbour A failed')
		return false
	
	if test_assets[index.B] in G.neighbours(test_assets[index.C]):
		print('remove B from neighbour C failed')
		return false
	
	if test_assets[index.B] in G.neighbours(test_assets[index.D]):
		print('remove B from neighbour D failed')
		return false
	
	# remove A
	G.remove_vertex(test_assets[index.A])
	
	if test_assets[index.A] in G.nodes.keys():
		print('remove A failed')
		return false
	
	# remove C
	G.remove_vertex(test_assets[index.C])
	
	if test_assets[index.C] in G.nodes.keys():
		print('remove C failed')
		return false
	
	if test_assets[index.C] in G.neighbours(test_assets[index.E]):
		print('remove C from neighbour E failed')
		return false
	
	return true

func test_add_edge():
	
	var test_assets = make_test_graph()
	var G = test_assets[index.G]
	
	# add edge A - C
	G.add_edge(test_assets[index.A], test_assets[index.C])
	
	if not test_assets[index.A] in G.neighbours(test_assets[index.C]):
		print('Adding edge A-C failed')
		return false
	
	if not test_assets[index.C] in G.neighbours(test_assets[index.A]):
		print('Adding edge A-C failed')
		return false
	
	# add edge B-E
	G.add_edge(test_assets[index.B], test_assets[index.E])
	
	if not test_assets[index.B] in G.neighbours(test_assets[index.E]):
		print('Adding B-E failed')
		return false
	
	if not test_assets[index.E] in G.neighbours(test_assets[index.B]):
		print('Adding B-E failed')
		return false
	
	return true

func test_remove_edge():
	
	var test_assets = make_test_graph()
	var G = test_assets[index.G]
	
	# remove E-F
	G.remove_edge(test_assets[index.E], test_assets[index.F])
	
	if test_assets[index.E] in G.neighbours(test_assets[index.F]):
		print('failed to remove E-F')
		return false
	
	if test_assets[index.F] in G.neighbours(test_assets[index.E]):
		print('failed to remove E-F')
		return false
	
	# remove B-E doesn't exist
	var neighbours_B_count = G.neighbours(test_assets[index.B]).size()
	var neighbours_E_count = G.neighbours(test_assets[index.E]).size()
	G.remove_edge(test_assets[index.B], test_assets[index.E])
	
	if neighbours_B_count != G.neighbours(test_assets[index.B]).size():
		print('Remove non existing edge failed')
		return false
	
	if neighbours_E_count != G.neighbours(test_assets[index.E]).size():
		print('Remove non existing edge failed')
		return false
	
	# remove B-D
	G.remove_edge(test_assets[index.B], test_assets[index.D])
	if test_assets[index.B] in G.neighbours(test_assets[index.D]):
		print('failed to remove B-D')
		return false
	
	if test_assets[index.D] in G.neighbours(test_assets[index.B]):
		print('failed to remove B-D')
		return false
	
	
	return true

func test_reset_visit():
	
	var test_assets = make_test_graph()
	var G = test_assets[index.G]
	
	test_assets[index.A].visited = true
	test_assets[index.E].visited = true
	
	var count_visited = 0
	for vertex in G.nodes.keys():
		if vertex.visited:
			count_visited+=1
	
	if count_visited != 2:
		print("counting visited failed")
		return false
	
	G.reset_visit()
	count_visited = 0
	for vertex in G.nodes.keys():
		if vertex.visited:
			count_visited+=1
	
	if count_visited != 0:
		print('reset_visited failed')
		return false
	
	return true

func test_depth_first_search():
	
	var test_assets = make_test_graph()
	var G = test_assets[index.G]
	
	# find A
	if not G.depth_first_search("A") == test_assets[index.A]:
		print('finding A failed')
		return false
	
	# findA from F
	if not G.depth_first_search("A", test_assets[index.F]) == test_assets[index.A]:
		print('finding A, starting at F failed')
		return false
	
	# delete A-B, try to find A
	G.remove_edge(test_assets[index.A], test_assets[index.B])
	if not G.depth_first_search("A", test_assets[index.C]) == null:
		print('finding A island, failed')
		# todo does not terminate check?
		return false
	
	# find B starting from B
	if not G.depth_first_search("B", test_assets[index.B]) == test_assets[index.B]:
		print('finding B, starting from B failed')
		return false
	
	
	return true

func test_breadth_first_search():
	
	var test_assets = make_test_graph()
	var G = test_assets[index.G]
	
	# find A
	if not G.breadth_first_search("A") == test_assets[index.A]:
		print('finding A failed')
		return false
	
	# findA from F
	if not G.breadth_first_search("A", test_assets[index.F]) == test_assets[index.A]:
		print('finding A, starting at F failed')
		return false
	
	# delete A-B, try to find A
	G.remove_edge(test_assets[index.A], test_assets[index.B])
	if not G.breadth_first_search("A", test_assets[index.C]) == null:
		print('finding A island, failed')
		# todo does not terminate check?
		return false
	
	# find B starting from B
	if not G.breadth_first_search("B", test_assets[index.B]) == test_assets[index.B]:
		print('finding B, starting from B failed')
		return false
	
	
	
	return true




