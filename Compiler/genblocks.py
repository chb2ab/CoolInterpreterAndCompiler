# Basic block class for handling a basic block of code
class BasicBlock:
	def __init__(self, code):
		self.code = code
		self.label = self.code[0].label
		self.children = []
		self.parents = []
		self.livein = []
		self.liveout = []
		self.changed = False
		self.visited = False
	def __str__(self):
		s = 'Label : ' + str(self.label) + '\n'
		s += 'Parents : ' + str([parent.label for parent in self.parents]) + '\n'
		for idx, item in enumerate(self.code):
			s += str(idx) + '. ' + str(item) + '\n'
		s += 'Children : ' + str([child.label for child in self.children]) + '\n'
		return s
	def printCode(self):
		for instruction in self.code:
			print(instruction)

# classes for each TAC instruction
class TACAssign:
	def __init__(self, assignee, assignment):
		self.assignee = assignee
		self.assignment = assignment
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- ' + str(self.assignment)
		
class TACPlus:
	def __init__(self, assignee, op1, op2):
		self.assignee = assignee
		self.op1 = op1
		self.op2 = op2
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- + ' + str(self.op1) + ' ' + str(self.op2)

class TACMinus:
	def __init__(self, assignee, op1, op2):
		self.assignee = assignee
		self.op1 = op1
		self.op2 = op2
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- - ' + str(self.op1) + ' ' + str(self.op2)

class TACMult:
	def __init__(self, assignee, op1, op2):
		self.assignee = assignee
		self.op1 = op1
		self.op2 = op2
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- * ' + str(self.op1) + ' ' + str(self.op2)

class TACDiv:
	def __init__(self, assignee, op1, op2):
		self.assignee = assignee
		self.op1 = op1
		self.op2 = op2
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- / ' + str(self.op1) + ' ' + str(self.op2)

class TACLt:
	def __init__(self, assignee, op1, op2, typ):
		self.assignee = assignee
		self.op1 = op1
		self.op2 = op2
		self.typ = typ
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- < ' + str(self.op1) + ' ' + str(self.op2) + ' ' + str(self.typ)

class TACLte:
	def __init__(self, assignee, op1, op2, typ):
		self.assignee = assignee
		self.op1 = op1
		self.op2 = op2
		self.typ = typ
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- <= ' + str(self.op1) + ' ' + str(self.op2) + ' ' + str(self.typ)

class TACEq:
	def __init__(self, assignee, op1, op2, typ):
		self.assignee = assignee
		self.op1 = op1
		self.op2 = op2
		self.typ = typ
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- = ' + str(self.op1) + ' ' + str(self.op2) + ' ' + str(self.typ)

class TACTypeCheck:
	def __init__(self, assignee, op, typ):
		self.assignee = assignee
		self.op = op
		self.typ = typ
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- typecheck ' + str(self.op) + ' ' + str(self.typ)

class TACInt:
	def __init__(self, assignee, integer):
		self.assignee = assignee
		self.integer = integer
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- int ' + str(self.integer)

class TACBool:
	def __init__(self, assignee, boolean):
		self.assignee = assignee
		self.boolean = boolean
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- bool ' + str(self.boolean)

class TACStr:
	def __init__(self, assignee, string):
		self.assignee = assignee
		self.string = string
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- string\n' + str(self.string)

class TACBneg:
	def __init__(self, assignee, op):
		self.assignee = assignee
		self.op = op
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- not ' + str(self.op)

class TACAneg:
	def __init__(self, assignee, op):
		self.assignee = assignee
		self.op = op
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- ~ ' + str(self.op)

class TACAlloc:
	def __init__(self, assignee, ttype):
		self.assignee = assignee
		self.ttype = ttype
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- new ' + str(self.ttype)

class TACDef:
	def __init__(self, assignee, ttype):
		self.assignee = assignee
		self.ttype = ttype
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- default ' + str(self.ttype)

class TACIv:
	def __init__(self, assignee, op):
		self.assignee = assignee
		self.op = op
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- isvoid ' + str(self.op)

class TACCall:
	def __init__(self, assignee, meth, clas, ops):
		self.assignee = assignee
		self.clas = clas
		self.meth = meth
		self.ops = ops
		self.living = []
	def __str__(self):
		pstr = ""
		for op in self.ops:
			pstr += " " + str(op)
		return str(self.assignee) + ' <- call ' + str(self.meth) + " " + str(self.clas) + pstr

class TACJmp:
	def __init__(self, label):
		self.label = label
		self.living = []
	def __str__(self):
		return 'jmp ' + str(self.label)

class TACLabel:
	def __init__(self, label):
		self.label = label
		self.living = []
	def __str__(self):
		return 'label ' + str(self.label)

class TACRet:
	def __init__(self, op):
		self.op = op
		self.living = []
	def __str__(self):
		return 'return ' + str(self.op)

class TACComment:
	def __init__(self):
		pass

class TACBt:
	def __init__(self, boolean, label):
		self.boolean = boolean
		self.label = label
		self.living = []
	def __str__(self):
		return 'bt ' + str(self.boolean) + ' ' + str(self.label)

class TACError:
	def __init__(self, code):
		self.code = code
		self.living = []
	def __str__(self):
		return 'error ' + self.code

class TACUnbox:
	def __init__(self, assignee, op):
		self.assignee = assignee
		self.op = op
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- unbox ' + str(self.op)

class TACBoxInt:
	def __init__(self, assignee, op):
		self.assignee = assignee
		self.op = op
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- boxint ' + str(self.op)

class TACBoxBool:
	def __init__(self, assignee, op):
		self.assignee = assignee
		self.op = op
		self.living = []
	def __str__(self):
		return str(self.assignee) + ' <- boxbool ' + str(self.op)

# Generate basic blocks from a list of TAC objects
def getblocks(instr):
	blocks = []
	block_instr = []
	for instruction in instr:
		if isinstance(instruction, TACLabel):
			block_instr.append([])
		block_instr[len(block_instr)-1].append(instruction)
	block_dict = {}
	for block in block_instr:
		newblock = BasicBlock(block)
		blocks.append(newblock)
		block_dict[newblock.label] = newblock
	for block in blocks:
		child_labels = [ins.label for ins in block.code if isinstance(ins, TACJmp) or isinstance(ins, TACBt)]
		for child_label in child_labels:
			block.children.append(block_dict[child_label])
			block_dict[child_label].parents.append(block)
	return blocks