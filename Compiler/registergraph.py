import genblocks
import random
import itertools
import sys 

# brute force graph coloring
def color_graph(nodes, index, graph, colors):
	if index == len(nodes):
		return True
	colors_to_give = [0,1,2,3,4,5,6,7,8,9,10,11,12,13]
	random.shuffle(colors_to_give)
	node = nodes[index]
	neighbors = graph[node]
	for color in colors_to_give:
		can_color = True
		for neighbor in neighbors:
			if colors[neighbor] == color:
				can_color = False
				break
		if can_color:
			colors[node] = color
			finish = color_graph(nodes, index+1, graph, colors)
			if finish:
				return True
	colors[node] = -1
	return False

# spill nodes in the graph that have more then 13 edges in the interference graph
def spill_node(graph, total_nodes, colors):
	sys.setrecursionlimit(10000) # need more recursion
	if total_nodes == []:
		return
	node_to_spill = total_nodes[0]
	nodes_lives = graph[node_to_spill]
	spill_reg = 14
	# while the node with the most edges has more then 13 edges
	while len(nodes_lives) > 13:
		# spill that edge by giving it a color greater then 13
		# and removing it from all other nodes interference graphs
		# and resorting by number of edges in interference graph
		colors[node_to_spill] = spill_reg
		spill_reg += 1
		del graph[node_to_spill]
		for node in nodes_lives:
			graph[node].discard(node_to_spill)
		total_nodes = total_nodes[1:]
		list.sort(total_nodes, key=lambda x: -len(graph[x]))
		node_to_spill = total_nodes[0]
		nodes_lives = graph[node_to_spill]

# Give all the temporary registers a color
def make_graph(blocks, vr):
	# get a list of all temporary registesrs
	sets = []
	for block in blocks:
		for instruction in block.code:
			sets.append(list(itertools.ifilter(lambda x: x[0:2] == "t$", instruction.living)))
	total_nodes = list(itertools.chain.from_iterable(sets))
	graph = {} # mapping from temporary register to its interference edges
	colors = {} # mapping from a temporary register to its color
	total_nodes = list(set(total_nodes))
	# initialize all temporary registers with an empty interference set and a color of -1
	color = 0
	for nd in total_nodes:
		graph[nd] = set()
		colors[nd] = -1
	# populate the interference graph for each node
	for liveset in sets:
		for nd in liveset:
			graph[nd].update(liveset)
	# remove each node from its own interference graph
	for node in graph.keys():
		graph[node].discard(node)
	# sort the interference graphs by their length
	list.sort(total_nodes, key=lambda x: -len(graph[x]))
	spill_node(graph, total_nodes, colors)
	# will always be able to color the graph because we removed all nodes with more then 13 edges
	can_color = color_graph(graph.keys(), 0, graph, colors)
	if not can_color:
		print "couldn't color" # should never happen
	return colors


#########################################################
### Replace temporary registers with actual registers ###
#########################################################

num_to_offset = {} # holds temporary registers that live in offsets from ebp
max_offset = 0 # number to subtract from ebp to hold locals
# translate temporary register and its color to an actual regiser
def get_sym(ident, colors):
	if ident[0:4] == "self":
		return "16(%rbp)"
	if ident[0:5] == "param":
		return str(ident[5:])+"(%rbp)"
	if ident[0:3] == "ret":
		return "%rax"
	if not ident in colors:
		return ident
	return get_color_reg(colors[ident])

# each color maps to some register
def get_color_reg(color):
	global max_offset
	global num_to_offset
	if color == 0:
		return "%rdx"
	elif color == 1:
		return "%rax"
	elif color == 2:
		return "%rsi"
	elif color == 3:
		return "%rdi"
	elif color == 4:
		return "%rbx"
	elif color == 5:
		return "%rcx"
	elif color == 6:
		return "%r8"
	elif color == 7:
		return "%r9"
	elif color == 8:
		return "%r10"
	elif color == 9:
		return "%r11"
	elif color == 10:
		return "%r12"
	elif color == 11:
		return "%r13"
	elif color == 12:
		return "%r14"
	elif color == 13:
		return "%r15"
	else:
		# temporary register will live in an offset under ebp
		if color in num_to_offset:
			offset = num_to_offset[color]
		else:
			offset = max_offset-8
			num_to_offset[color] = offset
		if offset < max_offset:
			max_offset = offset
		return str(offset)+"(%rbp)"

# for each instruction replace temporary registers with actual regisers
def assign(colors, blocks):
	global max_offset
	global num_to_offset
	num_to_offset = {}
	max_offset = -8
	for block in blocks:
		for instruction in block.code:
			if isinstance(instruction, genblocks.TACAssign):
				instruction.assignment = get_sym(instruction.assignment, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
			elif  ( isinstance(instruction, genblocks.TACPlus) or
					isinstance(instruction, genblocks.TACMinus) or
					isinstance(instruction, genblocks.TACMult) or
					isinstance(instruction, genblocks.TACDiv) or
					isinstance(instruction, genblocks.TACLt) or
					isinstance(instruction, genblocks.TACLte) or
					isinstance(instruction, genblocks.TACEq) ):
				instruction.op1 = get_sym(instruction.op1, colors)
				instruction.op2 = get_sym(instruction.op2, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
			elif isinstance(instruction, genblocks.TACTypeCheck):
				instruction.op = get_sym(instruction.op, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
			elif isinstance(instruction, genblocks.TACInt):
				instruction.assignee = get_sym(instruction.assignee, colors)
			elif isinstance(instruction, genblocks.TACBool):
				instruction.assignee = get_sym(instruction.assignee, colors)
			elif isinstance(instruction, genblocks.TACStr):
				instruction.assignee = get_sym(instruction.assignee, colors)
				instruction.living = [get_sym(var, colors) for var in instruction.living]
			elif isinstance(instruction, genblocks.TACBneg):
				instruction.op = get_sym(instruction.op, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
			elif isinstance(instruction, genblocks.TACAneg):
				instruction.op = get_sym(instruction.op, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
			elif isinstance(instruction, genblocks.TACAlloc):
				instruction.assignee = get_sym(instruction.assignee, colors)
				instruction.living = [get_sym(var, colors) for var in instruction.living]
			elif isinstance(instruction, genblocks.TACDef):
				instruction.assignee = get_sym(instruction.assignee, colors)
				instruction.living = [get_sym(var, colors) for var in instruction.living]
			elif isinstance(instruction, genblocks.TACIv):
				instruction.op = get_sym(instruction.op, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
			elif isinstance(instruction, genblocks.TACCall):
				instruction.ops = [get_sym(op, colors) for op in instruction.ops]
				instruction.assignee = get_sym(instruction.assignee, colors)
				instruction.living = [get_sym(var, colors) for var in instruction.living]
			elif isinstance(instruction, genblocks.TACJmp):
				pass
			elif isinstance(instruction, genblocks.TACLabel):
				pass
			elif isinstance(instruction, genblocks.TACRet):
				instruction.op = get_sym(instruction.op, colors)
			elif isinstance(instruction, genblocks.TACBt):
				instruction.boolean = get_sym(instruction.boolean, colors)
			elif isinstance(instruction, genblocks.TACBoxInt):
				instruction.op = get_sym(instruction.op, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
				instruction.living = [get_sym(var, colors) for var in instruction.living]
			elif isinstance(instruction, genblocks.TACBoxBool):
				instruction.op = get_sym(instruction.op, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
				instruction.living = [get_sym(var, colors) for var in instruction.living]
			elif isinstance(instruction, genblocks.TACUnbox):
				instruction.op = get_sym(instruction.op, colors)
				instruction.assignee = get_sym(instruction.assignee, colors)
	return -max_offset # return how many temporary registers are needed