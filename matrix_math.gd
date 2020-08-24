extends Node

# math matrix lib that contains:
# matrix contstructor, nxm and diagonal 
# matrix operations, add, dot, T, determinante, inverse, solving Ax = b for x, matrix to string


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass




########################################## Matrix library
class Matrix:
	var row_d = 1
	var col_d = 1
	var coeffs = []
	
	func get_coeff(row, col):
		return coeffs[row*col_d+col]
	
	func set_coeff(row, col, value):
		self.coeffs[row*col_d+col] = value

func matrix_create(row_d, col_d, coeffs):
	# coeffs has to be floats !
	var matrix = Matrix.new()
	matrix.row_d = row_d
	matrix.col_d = col_d
	matrix.coeffs = coeffs
	return matrix

func matrix_create_diagonal(dim, value = 1.0):
	var coeffs = []
	for row in range(dim):
		for col in range(dim):
			if row == col:
				coeffs.append(value)
			else:
				coeffs.append(0.0)
	return matrix_create(dim, dim, coeffs)

func matrix_add(matrixA, matrixB):
	
	var coeffs_added = []
	for i in range(matrixA.coeffs.size()):
		coeffs_added.append(matrixA.coeffs[i] + matrixB.coeffs[i])
	
	return matrix_create(matrixA.row_d, matrixA.col_d, coeffs_added)

func matrix_dot(matrixA, matrixB):
	if matrixA.col_d != matrixB.row_d:
		print('matrix column and row dimension don\'t fit')
		print(matrix_to_string(matrixA))
		print(matrix_to_string(matrixB))
		return null
	
	var transposed = matrix_transpose(matrixB)
	
	var result_coeffs = []
	var koeff_count = matrixA.row_d * matrixA.col_d
	var coeff = 0.0
	
	for row in range(matrixA.row_d):
		for col in range(matrixB.col_d):
			coeff = 0.0
			for i in range(matrixA.col_d):
				coeff += matrixA.get_coeff(row, i) * transposed.get_coeff(col, i)
			result_coeffs.append(coeff)
	
	return matrix_create(matrixA.row_d, matrixB.col_d, result_coeffs)

func matrix_transpose(matrix):
	
	var coeffs_T = []
	
	for col in range(matrix.col_d):
		for row in range(0, matrix.row_d):
			coeffs_T.append(matrix.get_coeff(row, col))
	
	return matrix_create(matrix.col_d, matrix.row_d, coeffs_T)

func matrix_determinante(matrix):
	# seems not numerical stable ...
	var matrixL = matrix_create_diagonal(matrix.row_d)
	var matrixU = matrix_create(matrix.row_d, matrix.col_d, Array(matrix.coeffs))
	
	# create lower triangle matrix with u, and put coeffs into matrixL, using gaussian jordan alg
	for col in range(matrixU.col_d):
		var row = col+1
		var dia_coeff = matrixU.get_coeff(col, col)
		while row < matrixU.row_d:
			# calc factor for each row, how many times the first is subtracted from the current row
			var row_factor = matrixU.get_coeff(row, col) / dia_coeff
			matrixL.set_coeff(row, col, row_factor)
			# subtract row
			for col_s in range(0, matrixU.col_d):
				var value = 0.0
				if col_s > col:
					value = matrixU.get_coeff(row, col_s) -(row_factor * matrixU.get_coeff(col, col_s))
				
				matrixU.set_coeff(row, col_s, value)
			row += 1
	
	var det_L = 1.0
	var det_U = 1.0
	
	for col in range(matrix.row_d):
		det_L *= matrixL.get_coeff(col, col)
		det_U *= matrixU.get_coeff(col, col)
	
	# det matrix = det L* det U
	return det_L * det_U

func matrix_inverse(matrix):
	# Gauss Jordan Method
	var matrixI = matrix_create_diagonal(matrix.row_d)
	var matrixA = matrix_create(matrix.row_d, matrix.col_d, Array(matrix.coeffs))
	
	# create zeros in lower half of matrix
	for col in range(matrixA.col_d):
		var row = col+1
		var dia_coeff = matrixA.get_coeff(col, col)
		while row < matrixA.row_d:
			# calc factor for each row, how many times the first is subtracted from the current row
			var row_factor = matrixA.get_coeff(row, col) / dia_coeff
			# subtract row
			for col_s in range(0, matrixA.col_d):
				var value = 0.0
				if col_s > col:
					value = matrixA.get_coeff(row, col_s) -(row_factor * matrixA.get_coeff(col, col_s))
				matrixA.set_coeff(row, col_s, value)
				value = matrixI.get_coeff(row, col_s) -(row_factor * matrixI.get_coeff(col, col_s))
				matrixI.set_coeff(row, col_s, value)
			row += 1
	
	# create zeros in upper half
	for col in range(matrixA.col_d-1, -1, -1):
		var row = col - 1
		var dia_coeff = matrixA.get_coeff(col, col)
		
		while row > -1:
			var row_factor = matrixA.get_coeff(row, col) / dia_coeff
			
			for col_s in range(matrixA.col_d-1, -1, -1):
				var value = 0.0
				if col_s < col:
					value = matrixA.get_coeff(row, col_s) - (row_factor * matrixA.get_coeff(col, col_s))
				matrixA.set_coeff(row, col_s, value)
				value = matrixI.get_coeff(row, col_s) - (row_factor * matrixI.get_coeff(col, col_s))
				matrixI.set_coeff(row, col_s, value)
			row -= 1
	
	# divide through
	for row in range(matrix.row_d):
		
		var divide_factor = matrixA.get_coeff(row, row)
		for col_s in range(matrix.col_d):
			var value = matrixI.get_coeff(row, col_s) / divide_factor
			matrixI.set_coeff(row, col_s, value)
	
	return matrixI

func matrix_lu_decomposition_solver(matrixA, b):
	# solves x for Ax = b
	var matrixL = matrix_create_diagonal(matrixA.row_d)
	var matrixU = matrix_create(matrixA.row_d, matrixA.col_d, Array(matrixA.coeffs))
	var vec = []
	for i in range(matrixA.row_d):
		vec.append(0.0)
	var y = matrix_create(matrixA.row_d, 1, Array(vec))
	var x = matrix_create(matrixA.row_d, 1, vec)
	
	# create lower triangle matrix with u, and put coeffs into matrixL, using gaussian jordan alg
	for col in range(matrixU.col_d):
		var row = col+1
		var dia_coeff = matrixU.get_coeff(col, col)
		while row < matrixU.row_d:
			# calc factor for each row, how many times the first is subtracted from the current row
			var row_factor = matrixU.get_coeff(row, col) / dia_coeff
			matrixL.set_coeff(row, col, row_factor)
			# subtract row
			for col_s in range(0, matrixU.col_d):
				var value = 0.0
				if col_s > col:
					value = matrixU.get_coeff(row, col_s) -(row_factor * matrixU.get_coeff(col, col_s))
				
				matrixU.set_coeff(row, col_s, value)
			row += 1
	
	# solve LY = b for vector Y
	var y_c = 0.0
	for row in range(matrixL.row_d):
		y_c = b.coeffs[row]
		for col_s in range(row):
			y_c -= y.coeffs[col_s] * matrixL.get_coeff(row, col_s)
		y.set_coeff(row, 0, y_c)
	
	# solve UX = Y for vector X return X
	var x_c = 0.0
	for row in range(matrixU.row_d-1, -1, -1):
		x_c = y.coeffs[row]
		for col_s in range(matrixU.col_d-1, row, -1): # all quadratic matrice
			x_c -= matrixU.get_coeff(row, col_s) * x.get_coeff(col_s, 0)
		x_c /= matrixU.get_coeff(row, row)
		x.set_coeff(row, 0, x_c)
	return x

func matrix_to_string(matrix):
	return str(matrix.row_d) + 'x' + str(matrix.col_d) + ' matrix with coeffs: ' + str(matrix.coeffs)

