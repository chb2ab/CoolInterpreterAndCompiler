import genblocks

# Perform global live variable analysis and eliminate dead code, iterating until no changes occur between iterations
def eliminatedc(blocks, attributes):
	populate(blocks, attributes)
	pop = True
	while pop:
		for block in blocks:
			block.visited = False
		cleanup(blocks[0])

		pop = populate(blocks, attributes)

		reset(blocks, attributes)

# Reset the live variables in each block to empty, done after each iteration of the global live variable analysis
def reset(blocks, attributes):
	for block in blocks:
		block.livein = []
		block.liveout = []
		for instruction in block.code:
			instruction.living = []
	populate(blocks, attributes)

# Global live variable analysis is done by performing local analysis in an in-order traversal of the blocks, repeating until no changes occur between iterations
def populate(blocks, attributes):
	count = 0
	redo = True
	while redo:
		count += 1
		for block in blocks:
			block.visited = False
		iterate(blocks[0], attributes)

		redo = False
		for block in blocks:
			if block.changed:
				redo = True
	if count == 1:
		return False
	else:
		return True

# In-order traversal of the blocks performing local live variable analysis on each block. Results from the children are propogated upwards
def iterate(block, attributes):
	block.visited = True
	block.changed = False
	livevars = {}
	for key in block.liveout:
		livevars[key] = 0
	for instruction in reversed(block.code):
		if not sorted(livevars.keys()) == sorted(instruction.living):
			block.changed = True
		instruction.living = [key for key in livevars.keys()]
		if isinstance(instruction, genblocks.TACAssign):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.assignment] = 0
		elif isinstance(instruction, genblocks.TACPlus):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op1] = 0
			livevars[instruction.op2] = 0
		elif isinstance(instruction, genblocks.TACMinus):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op1] = 0
			livevars[instruction.op2] = 0
		elif isinstance(instruction, genblocks.TACMult):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op1] = 0
			livevars[instruction.op2] = 0
		elif isinstance(instruction, genblocks.TACDiv):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op1] = 0
			livevars[instruction.op2] = 0
		elif isinstance(instruction, genblocks.TACLt):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op1] = 0
			livevars[instruction.op2] = 0
		elif isinstance(instruction, genblocks.TACLte):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op1] = 0
			livevars[instruction.op2] = 0
		elif isinstance(instruction, genblocks.TACEq):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op1] = 0
			livevars[instruction.op2] = 0
		elif isinstance(instruction, genblocks.TACTypeCheck):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op] = 0
		elif isinstance(instruction, genblocks.TACInt):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
		elif isinstance(instruction, genblocks.TACBool):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
		elif isinstance(instruction, genblocks.TACStr):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
		elif isinstance(instruction, genblocks.TACBneg):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op] = 0
		elif isinstance(instruction, genblocks.TACAneg):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op] = 0
		elif isinstance(instruction, genblocks.TACAlloc):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
		elif isinstance(instruction, genblocks.TACDef):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
		elif isinstance(instruction, genblocks.TACIv):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op] = 0
		elif isinstance(instruction, genblocks.TACCall):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			for op in instruction.ops:
				livevars[op] = 0
			for attr in attributes:
				livevars[attr] = 0
		elif isinstance(instruction, genblocks.TACRet):
			livevars[instruction.op] = 0
			for attr in attributes:
				livevars[attr] = 0
		elif isinstance(instruction, genblocks.TACBt):
			livevars[instruction.boolean] = 0
		elif isinstance(instruction, genblocks.TACUnbox):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op] = 0
		elif isinstance(instruction, genblocks.TACBoxInt):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op] = 0
		elif isinstance(instruction, genblocks.TACBoxBool):
			if livevars.has_key(instruction.assignee):
				livevars.pop(instruction.assignee, 0)
			livevars[instruction.op] = 0

	if not sorted(livevars.keys()) == sorted(block.livein):
		block.changed = True
	block.livein = [key for key in livevars.keys()]

	livevars = {}
	for child in block.children:
		if child.visited == False:
			iterate(child, attributes)
		for key in child.livein:
			livevars[key] = 0

	if not sorted(livevars.keys()) == sorted(block.liveout):
		block.changed = True
	block.liveout = [key for key in livevars.keys()]

# Remove dead code by checking if the killed variable is alive at that instruction
def cleanup(block):
	block.visited = True
	code = []
	for instruction in block.code:
		livevars = instruction.living
		if isinstance(instruction, genblocks.TACAssign):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACPlus):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACMinus):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACMult):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACDiv):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACLt):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACLte):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACEq):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACTypeCheck):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACInt):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACBool):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACStr):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACBneg):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACAneg):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACAlloc):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACDef):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACIv):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACCall):
			if instruction.assignee in livevars:
				code.append(instruction)
			else:
				instruction.assignee = "_dead_"
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACJmp):
			code.append(instruction)
		elif isinstance(instruction, genblocks.TACLabel):
			code.append(instruction)
		elif isinstance(instruction, genblocks.TACRet):
			code.append(instruction)
		elif isinstance(instruction, genblocks.TACComment):
			code.append(instruction)
		elif isinstance(instruction, genblocks.TACBt):
			code.append(instruction)
		elif isinstance(instruction, genblocks.TACError):
			code.append(instruction)
		elif isinstance(instruction, genblocks.TACUnbox):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACBoxInt):
			if instruction.assignee in livevars:
				code.append(instruction)
		elif isinstance(instruction, genblocks.TACBoxBool):
			if instruction.assignee in livevars:
				code.append(instruction)
	block.code = code

	for child in block.children:
		if child.visited == False:
			cleanup(child)