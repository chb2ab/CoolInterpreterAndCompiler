import genblocks
import ast

# Helper functions for making valid x86
def double_mem_check(reg1,reg2):
	if reg1[0] == "%" or reg2[0] == "%" or reg1[0] == "$" or reg2[0] == "$":
		return False
	else:
		return True

def mem_check(reg):
	if reg[0] == "%" or reg[0] == "$":
		return False
	else:
		return True

def to_suffix(suffix, register):
	# registers default to full 64 bits
	if suffix == "q":
		return register
	elif suffix == "l":
		if register == "%rax":
			return "%eax"
		elif register == "%rbx":
			return "%ebx"
		elif register == "%rcx":
			return "%ecx"
		elif register == "%rdx":
			return "%edx"
		elif register == "%rsi":
			return "%esi"
		elif register == "%rdi":
			return "%edi"
		elif register == "%r8":
			return "%r8d"
		elif register == "%r9":
			return "%r9d"
		elif register == "%r10":
			return "%r10d"
		elif register == "%r11":
			return "%r11d"
		elif register == "%r12":
			return "%r12d"
		elif register == "%r13":
			return "%r13d"
		elif register == "%r14":
			return "%r14d"
		elif register == "%r15":
			return "%r15d"
		# If the input was not a register return it unchanged
		else:
			return register
	elif suffix == "b":
		if register == "%rax":
			return "%al"
		elif register == "%rbx":
			return "%bl"
		elif register == "%rcx":
			return "%cl"
		elif register == "%rdx":
			return "%dl"
		elif register == "%rsi":
			return "%sil"
		elif register == "%rdi":
			return "%dil"
		elif register == "%r8":
			return "%r8b"
		elif register == "%r9":
			return "%r9b"
		elif register == "%r10":
			return "%r10b"
		elif register == "%r11":
			return "%r11b"
		elif register == "%r12":
			return "%r12b"
		elif register == "%r13":
			return "%r13b"
		elif register == "%r14":
			return "%r14b"
		elif register == "%r15":
			return "%r15b"
		else:
			return register

# classes for each x86 instruction
class X86Directive:
	def __init__(self, string):
		self.string = string
	def __str__(self):
		return str(self.string) + "\n"

class X86Cfi:
	def __init__(self, string):
		self.string = string
	def __str__(self):
		return "\t" + str(self.string) + "\n"

class X86Label:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return str(self.label) + ":" + "\n"

class X86Push:
	def __init__(self, var, size):
		self.var = to_suffix(size, var)
		self.size = size
	def __str__(self):
		return "\tpush" + str(self.size) + "\t" + str(self.var) + "\n"

class X86Pop:
	def __init__(self, var, size):
		self.var = to_suffix(size, var)
		self.size = size
	def __str__(self):
		return "\tpop" + str(self.size) + "\t" + str(self.var) + "\n"

class X86Mov_actual:
	def __init__(self, assignment, assignee, size):
		self.assignee = to_suffix(size, assignee)
		self.assignment = to_suffix(size, assignment)
		self.size = size
	def __str__(self):
		return "\tmov" + str(self.size) + "\t" + str(self.assignment) + "," + str(self.assignee) + "\n"

class X86Mov:
	def __init__(self, assignment, assignee, size):
		self.instr = []
		if double_mem_check(assignment, assignee):
			self.instr.append(X86Push("%rcx", "q"))
			self.instr.append(X86Mov_actual(assignment, "%rcx", size))
			self.instr.append(X86Mov("%rcx", assignee, size))
			self.instr.append(X86Pop("%rcx", "q"))
		else:
			self.instr.append(X86Mov_actual(assignment, assignee, size))
	def __str__(self):
		print_val = ""
		for line in self.instr:
			print_val += str(line)
		return print_val
		
class X86Add_actual:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\tadd" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"

class X86Add:
	def __init__(self, op1, op2, size):
		self.instr = []
		if double_mem_check(op1, op2):
			self.instr.append(X86Push("%rcx", "q"))
			self.instr.append(X86Mov(op1, "%rcx", size))
			self.instr.append(X86Add_actual("%rcx", op2, size))
			self.instr.append(X86Pop("%rcx", "q"))
		else:
			self.instr.append(X86Add_actual(op1, op2, size))
	def __str__(self):
		print_val = ""
		for line in self.instr:
			print_val += str(line)
		return print_val

class X86Sub_actual:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\tsub" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"

class X86Sub:
	def __init__(self, op1, op2, size):
		self.instr = []
		if double_mem_check(op1, op2):
			self.instr.append(X86Push("%rcx", "q"))
			self.instr.append(X86Mov(op1, "%rcx", size))
			self.instr.append(X86Sub_actual("%rcx", op2, size))
			self.instr.append(X86Pop("%rcx", "q"))
		else:
			self.instr.append(X86Sub_actual(op1, op2, size))
	def __str__(self):
		print_val = ""
		for line in self.instr:
			print_val += str(line)
		return print_val

class X86Imul_actual:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\timul" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"

class X86Imul:
	def __init__(self, op1, op2, size):
		self.instr = []
		if mem_check(op2):
			self.instr.append(X86Push("%rcx", "q"))
			self.instr.append(X86Mov(op2, "%rcx", size))
			self.instr.append(X86Imul_actual(op1, "%rcx", size))
			self.instr.append(X86Mov("%rcx", op2, size))
			self.instr.append(X86Pop("%rcx", "q"))
		else:
			self.instr.append(X86Imul_actual(op1, op2, size))
	def __str__(self):
		print_val = ""
		for line in self.instr:
			print_val += str(line)
		return print_val

class X86Cmp_actual:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\tcmp" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"

class X86Cmp:
	def __init__(self, op1, op2, size):
		self.instr = []
		if double_mem_check(op1, op2):
			self.instr.append(X86Push("%rcx", "q"))
			self.instr.append(X86Mov(op2, "%rcx", size))
			self.instr.append(X86Cmp_actual(op1, "%rcx", size))
			self.instr.append(X86Pop("%rcx", "q"))
		else:
			self.instr.append(X86Cmp_actual(op1, op2, size))
	def __str__(self):
		print_val = ""
		for line in self.instr:
			print_val += str(line)
		return print_val

class X86Cmovl:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\tcmovl" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"

class X86Cmovg:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\tcmovg" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"

class X86Jl:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return "\tjl\t" + str(self.label) + "\n"

class X86Jge:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return "\tjge\t" + str(self.label) + "\n"

class X86Jg:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return "\tjg\t" + str(self.label) + "\n"

class X86Jne:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return "\tjne\t" + str(self.label) + "\n"

class X86Jmp:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return "\tjmp\t" + str(self.label) + "\n"

class X86Jle:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return "\tjle\t" + str(self.label) + "\n"

class X86Je:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return "\tje\t" + str(self.label) + "\n"

class X86Js:
	def __init__(self, label):
		self.label = label
	def __str__(self):
		return "\tjs\t" + str(self.label) + "\n"

class X86Xor:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\txor" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"

class X86And:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\tand" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"

class X86Shr:
	def __init__(self, shift_length, assignee, size):
		self.shift_length = to_suffix(size, shift_length)
		self.assignee = to_suffix(size, assignee)
		self.size = size
	def __str__(self):
		return "\tshr" + str(self.size) + "\t" + str(self.shift_length) + ',' + str(self.assignee) + "\n"

class X86Neg:
	def __init__(self, op, size):
		self.op = to_suffix(size, op)
		self.size = size
	def __str__(self):
		return "\tneg" + str(self.size) + "\t" + str(self.op) + "\n"

class X86Call:
	def __init__(self, func):
		self.func = func
	def __str__(self):
		return "\tcall\t" + str(self.func) + "\n"

class X86Ret:
	def __init__(self):
		pass
	def __str__(self):
		return "\tret\n"

class X86Lea:
	def __init__(self, assignment, assignee, size):
		self.assignment = to_suffix(size, assignment)
		self.assignee = to_suffix(size, assignee)
		self.size = size
	def __str__(self):
		return "\tlea" + str(self.size) + "\t"+ str(self.assignment) + "," + str(self.assignee) + "\n"

class X86Leave:
	def __init__(self):
		pass
	def __str__(self):
		return "\tleave\n"

class X86Cltd:
	def __init__(self):
		pass
	def __str__(self):
		return "\tcltd\n"

class X86Test:
	def __init__(self, op1, op2, size):
		self.op1 = to_suffix(size, op1)
		self.op2 = to_suffix(size, op2)
		self.size = size
	def __str__(self):
		return "\ttest" + str(self.size) + "\t" + str(self.op1) + ',' + str(self.op2) + "\n"


class X86Idiv:
	def __init__(self, op, size):
		self.op = to_suffix(size, op)
		self.size = size
	def __str__(self):
		return "\tidiv" + str(self.size) + "\t" + str(self.op) + "\n"

# generates labels
label_counter = -1
def nl():
    global label_counter
    label_counter += 1
    return "nlabel_" + str(label_counter)

# get vtable from it's offset in an object
def get_vtable(location):
	x86instr = []
	x86instr.append(X86Mov(location, "%rax", "q"))
	x86instr.append(X86Mov("16(%rax)", "%rax", "q"))
	return x86instr

# generate a new integer from a given constant
def new_int_const(assignee, integer, living):
	x86instr = []
	x86instr += caller_save_regs_living(assignee, living)
	x86instr.append(X86Call("Int.new"))
	x86instr.append(X86Mov("$" + str(integer), "24(%rax)", "l"))
	x86instr.append(X86Mov("%rax", assignee, "q"))
	x86instr += restore_caller_save_regs_living(assignee, living)
	return x86instr

# generate a new integer from the value in a given register
def new_int_generator(assignee, reg, living):
	x86instr = []
	x86instr += caller_save_regs_living(assignee, living)
	if assignee != "%rbx":
		x86instr.append(X86Push("%rbx", "q"))
	if reg != "%rbx":
		x86instr.append(X86Mov(reg, "%rbx", "q"))
	x86instr.append(X86Call("Int.new"))
	x86instr.append(X86Mov("%rbx", "24(%rax)", "l"))
	x86instr.append(X86Mov("%rax", assignee, "q"))
	if assignee != "%rbx":
		x86instr.append(X86Pop("%rbx", "q"))
	x86instr += restore_caller_save_regs_living(assignee, living)
	return x86instr

# generate a new boolean from a given constant
def new_bool_const(assignee, boool):
	x86instr = []
	x86instr += caller_save_regs(assignee)
	x86instr.append(X86Call("Bool.new"))
	x86instr.append(X86Mov("$" + str(boool), "24(%rax)", "l"))
	x86instr.append(X86Mov("%rax", assignee, "q"))
	x86instr += restore_caller_save_regs(assignee)
	return x86instr

# generate a new boolean from the value in a given register
def new_bool_generator(assignee, reg):
	x86instr = []
	x86instr += caller_save_regs(assignee)
	if assignee != "%rbx":
		x86instr.append(X86Push("%rbx", "q"))
	if reg != "%rbx":
		x86instr.append(X86Mov(reg, "%rbx", "q"))
	x86instr.append(X86Call("Bool.new"))
	x86instr.append(X86Mov("%rbx", "24(%rax)", "l"))
	x86instr.append(X86Mov("%rax", assignee, "q"))
	if assignee != "%rbx":
		x86instr.append(X86Pop("%rbx", "q"))
	x86instr += restore_caller_save_regs(assignee)
	return x86instr

# generate a new string from a given constant
def new_string_glob(assignee, string, living):
	global string_count
	x86instr = []
	x86instr += caller_save_regs_living(assignee, living)
	x86instr.append(X86Call("String.new"))
	x86instr.append(X86Mov("$.GLOB.STR"+str(string_count), "24(%rax)", "q"))
	x86instr.append(X86Mov("$"+str(len(string)), "32(%rax)", "l"))
	x86instr.append(X86Mov("%rax", assignee, "q"))
	x86instr += restore_caller_save_regs_living(assignee, living)
	return x86instr

# compare objects based on their object pointers
def compare_objects(instruction, comp):
	x86instr = []
	false_label = nl()
	true_label = nl()
	end_label = nl()
	x86instr.append(X86Cmp(instruction.op1, instruction.op2, "q"))
	if comp == "l":
		x86instr.append(X86Jmp(false_label))
	elif comp == "le":
		x86instr.append(X86Je(true_label))
	elif comp == "e":
		x86instr.append(X86Je(true_label))
	x86instr.append(X86Label(false_label))
	x86instr.append(X86Mov("$0", instruction.assignee, "l"))
	x86instr.append(X86Jmp(end_label))
	x86instr.append(X86Label(true_label))
	x86instr.append(X86Mov("$1", instruction.assignee, "l"))
	x86instr.append(X86Label(end_label))
	return x86instr

# compare integers and booleans using their actual values
def compare_intorbool(instruction, comp):
	x86instr = []
	false_label = nl()
	true_label = nl()
	end_label = nl()
	op1 = instruction.op1
	op2 = instruction.op2
	if instruction.assignee != "%rax":
		x86instr.append(X86Push("%rax", "q"))
	if instruction.assignee != "%rbx":
		x86instr.append(X86Push("%rbx", "q"))
	if op1 == "%rbx" and op2 == "%rax":
		x86instr.append(X86Push("%rax", "q"))
		x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
		x86instr.append(X86Pop("%rbx", "q"))
	elif op1 != "%rbx" and op2 == "%rax":
		x86instr.append(X86Mov(instruction.op2, "%rbx", "q"))
		x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
	elif op1 == "%rbx" and op2 != "%rax":
		x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
		x86instr.append(X86Mov(instruction.op2, "%rbx", "q"))
	else:
		x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
		x86instr.append(X86Mov(instruction.op2, "%rbx", "q"))
	x86instr.append(X86Mov("24(%rax)", "%rax", "q"))
	x86instr.append(X86Mov("24(%rbx)", "%rbx", "q"))
	x86instr.append(X86Cmp("%rbx", "%rax", "l"))
	if comp == "l":
		x86instr.append(X86Jl(true_label))
	elif comp == "le":
		x86instr.append(X86Jle(true_label))
	elif comp == "e":
		x86instr.append(X86Je(true_label))
	x86instr.append(X86Label(false_label))
	new_bool = new_bool_const(instruction.assignee, 0)
	x86instr += new_bool
	x86instr.append(X86Jmp(end_label))
	x86instr.append(X86Label(true_label))
	new_bool = new_bool_const(instruction.assignee, 1)
	x86instr += new_bool
	x86instr.append(X86Label(end_label))
	if instruction.assignee != "%rbx":
		x86instr.append(X86Pop("%rbx", "q"))
	if instruction.assignee != "%rax":
		x86instr.append(X86Pop("%rax", "q"))
	return x86instr

# compare strings lexigraphically
def compare_strings(instruction, comp):
	x86instr = []
	start_loop = nl()
	end_loop = nl()
	less_than = nl()
	greater_than = nl()
	equal_to = nl()
	false_label = nl()
	true_label = nl()
	end_label = nl()
	op1 = instruction.op1
	op2 = instruction.op2
	if instruction.assignee != "%rax":
		x86instr.append(X86Push("%rax", "q"))
	if instruction.assignee != "%rbx":
		x86instr.append(X86Push("%rbx", "q"))
	if instruction.assignee != "%rsi":
		x86instr.append(X86Push("%rsi", "q"))
	if instruction.assignee != "%rdi":
		x86instr.append(X86Push("%rdi", "q"))
	if instruction.assignee != "%rcx":
		x86instr.append(X86Push("%rcx", "q"))
	if op1 == "%rbx" and op2 == "%rax":
		x86instr.append(X86Push("%rax", "q"))
		x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
		x86instr.append(X86Pop("%rbx", "q"))
	elif op1 != "%rbx" and op2 == "%rax":
		x86instr.append(X86Mov(instruction.op2, "%rbx", "q"))
		x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
	elif op1 == "%rbx" and op2 != "%rax":
		x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
		x86instr.append(X86Mov(instruction.op2, "%rbx", "q"))
	else:
		x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
		x86instr.append(X86Mov(instruction.op2, "%rbx", "q"))
	x86instr.append(X86Mov("$0", "%rcx", "q"))
	x86instr.append(X86Mov("24(%rax)", "%rax", "q"))
	x86instr.append(X86Mov("24(%rbx)", "%rbx", "q"))
	x86instr.append(X86Label(start_loop))
	# compare char a[x] to b[x]
	x86instr.append(X86Mov("%rax", "%rdi", "q"))
	x86instr.append(X86Add("%rcx", "%rdi", "q"))
	x86instr.append(X86Mov("(%rdi)", "%rdi", "b"))
	x86instr.append(X86Mov("%rbx", "%rsi", "q"))
	x86instr.append(X86Add("%rcx", "%rsi", "q"))
	x86instr.append(X86Mov("(%rsi)", "%rsi", "b"))
	x86instr.append(X86Cmp("%rsi", "%rdi", "b"))
	x86instr.append(X86Jl(less_than))
	x86instr.append(X86Jg(greater_than))
	# if equal, and not null characters, keep looping
	x86instr.append(X86Cmp("$0", "%rdi", "b"))
	x86instr.append(X86Je(equal_to))
	x86instr.append(X86Cmp("$0", "%rsi", "b"))
	x86instr.append(X86Je(equal_to))
	x86instr.append(X86Add("$1", "%rcx", "q"))
	x86instr.append(X86Jmp(start_loop))
	x86instr.append(X86Label(less_than))
	# TODO: if b[x] < a[x] go to false case directly
	x86instr.append(X86Mov("$-1", "%rdi", "l"))
	x86instr.append(X86Jmp(end_loop))
	# if a[x] < b[x] move -1 into rdi, jump to end of loop
	x86instr.append(X86Label(greater_than))
	x86instr.append(X86Mov("$1", "%rdi", "l"))
	x86instr.append(X86Jmp(end_loop))
	x86instr.append(X86Label(equal_to))
	x86instr.append(X86Mov("$0", "%rdi", "l"))
	x86instr.append(X86Jmp(end_loop))
	x86instr.append(X86Label(end_loop))
	x86instr.append(X86Cmp("$0", "%rdi", "l"))
	if comp == "l":
		x86instr.append(X86Jl(true_label))
	elif comp == "le":
		x86instr.append(X86Jle(true_label))
	elif comp == "e":
		x86instr.append(X86Je(true_label))
	# false case, create false bool and assign
	x86instr.append(X86Label(false_label))
	x86instr.append(X86Mov("$0", instruction.assignee, "l"))
	x86instr.append(X86Jmp(end_label))
	# true case, create true bool and assign
	x86instr.append(X86Label(true_label))
	x86instr.append(X86Mov("$1", instruction.assignee, "l"))
	x86instr.append(X86Label(end_label))
	if instruction.assignee != "%rcx":
		x86instr.append(X86Pop("%rcx", "q"))
	if instruction.assignee != "%rdi":
		x86instr.append(X86Pop("%rdi", "q"))
	if instruction.assignee != "%rsi":
		x86instr.append(X86Pop("%rsi", "q"))
	if instruction.assignee != "%rbx":
		x86instr.append(X86Pop("%rbx", "q"))
	if instruction.assignee != "%rax":
		x86instr.append(X86Pop("%rax", "q"))

	return x86instr

# push the callee save regsiters
def callee_save_regs():
	x86instr = []
	x86instr.append(X86Push("%rbx", "q"))
	x86instr.append(X86Push("%rdi", "q"))
	x86instr.append(X86Push("%rsi", "q"))
	x86instr.append(X86Push("%r12", "q"))
	x86instr.append(X86Push("%r13", "q"))
	x86instr.append(X86Push("%r14", "q"))
	x86instr.append(X86Push("%r15", "q"))
	return x86instr

# pop the calle save regsiters
def restore_callee_save_regs():
	x86instr = []
	x86instr.append(X86Pop("%r15", "q"))
	x86instr.append(X86Pop("%r14", "q"))
	x86instr.append(X86Pop("%r13", "q"))
	x86instr.append(X86Pop("%r12", "q"))
	x86instr.append(X86Pop("%rsi", "q"))
	x86instr.append(X86Pop("%rdi", "q"))
	x86instr.append(X86Pop("%rbx", "q"))
	return x86instr

# push the caller save regsiters that are not the assignee
def caller_save_regs(assignee):
	x86instr = []
	if assignee != "%rcx":
		x86instr.append(X86Push("%rcx", "q"))
	if assignee != "%rdx":
		x86instr.append(X86Push("%rdx", "q"))
	if assignee != "%rax":
		x86instr.append(X86Push("%rax", "q"))
	if assignee != "%r8":
		x86instr.append(X86Push("%r8", "q"))
	if assignee != "%r9":
		x86instr.append(X86Push("%r9", "q"))
	if assignee != "%r10":
		x86instr.append(X86Push("%r10", "q"))
	if assignee != "%r11":
		x86instr.append(X86Push("%r11", "q"))
	return x86instr

# pop the caller save regsiters that are not the assignee
def restore_caller_save_regs(assignee):
	x86instr = []
	if assignee != "%r11":
		x86instr.append(X86Pop("%r11", "q"))
	if assignee != "%r10":
		x86instr.append(X86Pop("%r10", "q"))
	if assignee != "%r9":
		x86instr.append(X86Pop("%r9", "q"))
	if assignee != "%r8":
		x86instr.append(X86Pop("%r8", "q"))
	if assignee != "%rax":
		x86instr.append(X86Pop("%rax", "q"))
	if assignee != "%rdx":
		x86instr.append(X86Pop("%rdx", "q"))
	if assignee != "%rcx":
		x86instr.append(X86Pop("%rcx", "q"))
	return x86instr

# push the caller save regsiters that are live and not the assignee
def caller_save_regs_living(assignee, living):
	x86instr = []
	if assignee != "%rcx" and "%rcx" in living:
		x86instr.append(X86Push("%rcx", "q"))
	if assignee != "%rdx" and "%rdx" in living:
		x86instr.append(X86Push("%rdx", "q"))
	if assignee != "%rax" and "%rax" in living:
		x86instr.append(X86Push("%rax", "q"))
	if assignee != "%r8" and "%r8" in living:
		x86instr.append(X86Push("%r8", "q"))
	if assignee != "%r9" and "%r9" in living:
		x86instr.append(X86Push("%r9", "q"))
	if assignee != "%r10" and "%r10" in living:
		x86instr.append(X86Push("%r10", "q"))
	if assignee != "%r11" and "%r11" in living:
		x86instr.append(X86Push("%r11", "q"))
	return x86instr

# pop the caller save regsiters that are live and not the assignee
def restore_caller_save_regs_living(assignee, living):
	x86instr = []
	if assignee != "%r11" and "%r11" in living:
		x86instr.append(X86Pop("%r11", "q"))
	if assignee != "%r10" and "%r10" in living:
		x86instr.append(X86Pop("%r10", "q"))
	if assignee != "%r9" and "%r9" in living:
		x86instr.append(X86Pop("%r9", "q"))
	if assignee != "%r8" and "%r8" in living:
		x86instr.append(X86Pop("%r8", "q"))
	if assignee != "%rax" and "%rax" in living:
		x86instr.append(X86Pop("%rax", "q"))
	if assignee != "%rdx" and "%rdx" in living:
		x86instr.append(X86Pop("%rdx", "q"))
	if assignee != "%rcx" and "%rcx" in living:
		x86instr.append(X86Pop("%rcx", "q"))
	return x86instr

string_count = 0
# generate x86 code
def gen(blocks, max_off):
	global vtable
	global string_count
	# make maximum offset divisible by 16
	if (max_off/16)*16 != max_off:
		max_off += 8
	max_off += 16
	# internal methods have their own custom definitions
	function = blocks[0].code.pop(0)
	if function.label == "IO.in_int":
		return gen_io_inint()
	elif function.label == "IO.in_string":
		return gen_io_instring()
	elif function.label == "IO.out_int":
		return gen_io_outint()
	elif function.label == "IO.out_string":
		return gen_io_outstring()
	elif function.label == "Object.abort":
		return gen_obj_abort()
	elif function.label == "Object.copy":
		return gen_obj_copy()
	elif function.label == "Object.type_name":
		return gen_obj_typename()
	elif function.label == "String.concat":
		return gen_str_concat()
	elif function.label == "String.length":
		return gen_str_length()
	elif function.label == "String.substr":
		return gen_str_substr()

	strings = []
	x86instr = []
	# prologue
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\t"+function.label))
	x86instr.append(X86Directive("\t.type\t"+function.label+", @function"))
	x86instr.append(X86Label(function.label))
	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	x86instr.append(X86Sub("$"+str(max_off), "%rsp", "q"))
	x86instr += callee_save_regs()
	for block in blocks:
		for instruction in block.code:
			if isinstance(instruction, genblocks.TACAssign):
				if instruction.assignment == "Void": # Void assignment is the constant 0
					x86instr.append(X86Mov("$0", instruction.assignee, "q"))
				elif instruction.assignment[0:4] == "attr": # Attributes need to be specially loaded from the object
					offset = str(int(instruction.assignment[4:])*8+24)
					if instruction.assignee != "%rax":
						x86instr.append(X86Push("%rax", "q"))
					x86instr.append(X86Mov("16(%rbp)", "%rax", "q"))
					x86instr.append(X86Mov(offset+"(%rax)", "%rax", "q"))
					x86instr.append(X86Mov("%rax", instruction.assignee, "q"))
					if instruction.assignee != "%rax":
						x86instr.append(X86Pop("%rax", "q"))
				elif instruction.assignee[0:4] == "attr": # Attributes need to be specially loaded from the object
					offset = str(int(instruction.assignee[4:])*8+24)
					assignment = instruction.assignment
					if assignment == "%rax":
						x86instr.append(X86Push("%rcx", "q"))
						x86instr.append(X86Mov("16(%rbp)", "%rcx", "q"))
						x86instr.append(X86Mov(instruction.assignment, offset+"(%rcx)", "q"))
						x86instr.append(X86Pop("%rcx", "q"))
					else:
						x86instr.append(X86Push("%rax", "q"))
						x86instr.append(X86Mov("16(%rbp)", "%rax", "q"))
						x86instr.append(X86Mov(instruction.assignment, offset+"(%rax)", "q"))
						x86instr.append(X86Pop("%rax", "q"))
				else:
					x86instr.append(X86Mov(instruction.assignment, instruction.assignee, "q"))

			elif isinstance(instruction, genblocks.TACPlus):
				if instruction.assignee != instruction.op2:
					x86instr.append(X86Push(instruction.op2, "q"))
				x86instr.append(X86Add(instruction.op1, instruction.op2, "l"))
				if instruction.assignee != instruction.op2:
					x86instr.append(X86Mov(instruction.op2, instruction.assignee, "l"))
					x86instr.append(X86Pop(instruction.op2, "q"))

			elif isinstance(instruction, genblocks.TACMinus):
				if instruction.assignee != instruction.op1:
					x86instr.append(X86Push(instruction.op1, "q"))
				x86instr.append(X86Sub(instruction.op2, instruction.op1, "l"))
				if instruction.assignee != instruction.op1:
					x86instr.append(X86Mov(instruction.op1, instruction.assignee, "l"))
					x86instr.append(X86Pop(instruction.op1, "q"))

			elif isinstance(instruction, genblocks.TACMult):
				if instruction.assignee != instruction.op2:
					x86instr.append(X86Push(instruction.op2, "q"))
				x86instr.append(X86Imul(instruction.op1, instruction.op2, "l"))
				if instruction.assignee != instruction.op2:
					x86instr.append(X86Mov(instruction.op2, instruction.assignee, "l"))
					x86instr.append(X86Pop(instruction.op2, "q"))

			elif isinstance(instruction, genblocks.TACDiv):
				if instruction.assignee != "%rax":
					x86instr.append(X86Push("%rax", "q"))
				if instruction.op2 == "%rax" and instruction.op1 != "%rbx" and instruction.assignee != "%rbx":
					x86instr.append(X86Push("%rbx", "q"))
				elif instruction.op2 == "%rax" and instruction.op1 == "%rbx" and instruction.assignee != "%rcx":
					x86instr.append(X86Push("%rcx", "q"))
				# always save rdx, because it will be overwritten by the cltd instruction
				x86instr.append(X86Push("%rdx", "q"))
				if instruction.op2 == "%rax" and instruction.op1 != "%rbx":
					x86instr.append(X86Mov(instruction.op2, "%rbx", "q"))
				elif instruction.op2 == "%rax" and instruction.op1 == "%rbx":
					x86instr.append(X86Mov(instruction.op2, "%rcx", "q"))
				x86instr.append(X86Mov(instruction.op1, "%rax", "q"))
				# cltd extends eax into edx
				x86instr.append(X86Cltd())
				# if we are dividing with rdx, we want to use the saved version which is at the top of the stack
				if instruction.op2 == "%rdx":
					x86instr.append(X86Idiv("(%rsp)", "l"))
				elif instruction.op2 == "%rax" and instruction.op1 != "%rbx":
					x86instr.append(X86Idiv("%rbx", "l"))
				elif instruction.op2 == "%rax" and instruction.op1 == "%rbx":
					x86instr.append(X86Idiv("%rcx", "l"))
				else:
					x86instr.append(X86Idiv(instruction.op2, "l"))
				# restore rdx to preserve stack, if it was the assignee it will be overwritten.
				x86instr.append(X86Pop("%rdx", "q"))
				x86instr.append(X86Mov("%rax", instruction.assignee, "q"))
				if instruction.op2 == "%rax" and instruction.op1 != "%rbx" and instruction.assignee != "%rbx":
					x86instr.append(X86Pop("%rbx", "q"))
				elif instruction.op2 == "%rax" and instruction.op1 == "%rbx" and instruction.assignee != "%rcx":
					x86instr.append(X86Pop("%rcx", "q"))
				if instruction.assignee != "%rax":
					x86instr.append(X86Pop("%rax", "q"))

			elif isinstance(instruction, genblocks.TACLt): # if op1 < op2, the jump will be taken and assignee will get 1, else it gets 0
 				if instruction.typ == "String":
 					comp = compare_strings(instruction, "l")
 					x86instr += comp
 				elif instruction.typ == "Int" or instruction.typ == "Bool":
 					false_label = nl()
 					true_label = nl()
 					end_label = nl()
 					x86instr.append(X86Cmp(instruction.op2, instruction.op1, "l"))
 					x86instr.append(X86Jl(true_label))
					x86instr.append(X86Label(false_label))
					x86instr.append(X86Mov("$0", instruction.assignee, "l"))
					x86instr.append(X86Jmp(end_label))
					x86instr.append(X86Label(true_label))
					x86instr.append(X86Mov("$1", instruction.assignee, "l"))
					x86instr.append(X86Label(end_label))
				else:
					comp = compare_objects(instruction, "l")
					x86instr += comp

			elif isinstance(instruction, genblocks.TACLte):
				if instruction.typ == "String":
					comp = compare_strings(instruction, "le")
					x86instr += comp
				elif instruction.typ == "Int" or instruction.typ == "Bool":
					false_label = nl()
					true_label = nl()
					end_label = nl()
					x86instr.append(X86Cmp(instruction.op2, instruction.op1, "l"))
					x86instr.append(X86Jle(true_label))
					x86instr.append(X86Label(false_label))
					x86instr.append(X86Mov("$0", instruction.assignee, "l"))
					x86instr.append(X86Jmp(end_label))
					x86instr.append(X86Label(true_label))
					x86instr.append(X86Mov("$1", instruction.assignee, "l"))
					x86instr.append(X86Label(end_label))
				else:
					comp = compare_objects(instruction, "le")
					x86instr += comp

			elif isinstance(instruction, genblocks.TACEq):
				if instruction.typ == "String":
					comp = compare_strings(instruction, "e")
					x86instr += comp
				elif instruction.typ == "Int" or instruction.typ == "Bool":
					false_label = nl()
					true_label = nl()
					end_label = nl()
					x86instr.append(X86Cmp(instruction.op2, instruction.op1, "l"))
					x86instr.append(X86Je(true_label))
					x86instr.append(X86Label(false_label))
					x86instr.append(X86Mov("$0", instruction.assignee, "l"))
					x86instr.append(X86Jmp(end_label))
					x86instr.append(X86Label(true_label))
					x86instr.append(X86Mov("$1", instruction.assignee, "l"))
					x86instr.append(X86Label(end_label))
				else:
					comp = compare_objects(instruction, "e")
					x86instr += comp

			# TYPECHECK occurs in case statements. In this case the type string of an object is compared to the predefined type string for that type to see what type it is
			elif isinstance(instruction, genblocks.TACTypeCheck):
				false_label = nl()
				true_label = nl()
				end_label = nl()
				typ = instruction.typ
				if instruction.assignee != "%rax":
					x86instr.append(X86Push("%rax", "q"))
				if instruction.assignee != "%rbx":
					x86instr.append(X86Push("%rbx", "q"))
				x86instr.append(X86Mov(instruction.op, "%rax", "q"))
				x86instr.append(X86Mov("(%rax)", "%rax", "q"))
				x86instr.append(X86Mov("$."+typ+".type_string_obj", "%rbx", "q"))
				x86instr.append(X86Cmp("%rax", "%rbx", "q"))
				x86instr.append(X86Je(true_label))
				x86instr.append(X86Label(false_label))
				x86instr.append(X86Mov("$0", instruction.assignee, "l"))
				x86instr.append(X86Jmp(end_label))
				x86instr.append(X86Label(true_label))
				x86instr.append(X86Mov("$1", instruction.assignee, "l"))
				x86instr.append(X86Label(end_label))
				if instruction.assignee != "%rbx":
					x86instr.append(X86Pop("%rbx", "q"))
				if instruction.assignee != "%rax":
					x86instr.append(X86Pop("%rax", "q"))

			elif isinstance(instruction, genblocks.TACInt):
				x86instr.append(X86Mov("$" + str(instruction.integer), instruction.assignee, "l"))

			elif isinstance(instruction, genblocks.TACBool):
				if instruction.boolean == "true":
					x86instr.append(X86Mov("$1", instruction.assignee, "l"))
				else:
					x86instr.append(X86Mov("$0", instruction.assignee, "l"))

			elif isinstance(instruction, genblocks.TACStr):
				string_count += 1
				strings.append((instruction.string, string_count))
				new_str = new_string_glob(instruction.assignee, instruction.string, instruction.living)
				x86instr += new_str

			elif isinstance(instruction, genblocks.TACBneg):
				if instruction.assignee != instruction.op:
					x86instr.append(X86Push(instruction.op, "q"))
				x86instr.append(X86Xor("$1", instruction.op, "l"))
				x86instr.append(X86Mov(instruction.op, instruction.assignee, "l"))
				if instruction.assignee != instruction.op:
					x86instr.append(X86Pop(instruction.op, "q"))

			elif isinstance(instruction, genblocks.TACAneg):
				if instruction.assignee != instruction.op:
					x86instr.append(X86Push(instruction.op, "q"))
				x86instr.append(X86Neg(instruction.op, "q"))
				x86instr.append(X86Mov(instruction.op, instruction.assignee, "l"))
				if instruction.assignee != instruction.op:
					x86instr.append(X86Pop(instruction.op, "q"))

			elif isinstance(instruction, genblocks.TACAlloc):
				x86instr += caller_save_regs_living(instruction.assignee, instruction.living)
				if instruction.ttype == "SELF_TYPE":
					getvt = get_vtable("16(%rbp)")
					x86instr += getvt
					x86instr.append(X86Call("*(%rax)"))
				else:
					x86instr.append(X86Call(instruction.ttype+".new"))
				x86instr.append(X86Mov("%rax", instruction.assignee, "q"))
				x86instr += restore_caller_save_regs_living(instruction.assignee, instruction.living)

			elif isinstance(instruction, genblocks.TACDef):
				if instruction.ttype == "Int" or instruction.ttype == "String" or instruction.ttype == "Bool":
					x86instr += caller_save_regs_living(instruction.assignee, instruction.living)
					x86instr.append(X86Call(instruction.ttype+".new"))
					x86instr.append(X86Mov("%rax", instruction.assignee, "q"))
					x86instr += restore_caller_save_regs_living(instruction.assignee, instruction.living)
				else:
					x86instr.append(X86Mov("$0", instruction.assignee, "q"))

			elif isinstance(instruction, genblocks.TACCall):
				x86instr += caller_save_regs_living(instruction.assignee, instruction.living)
				for op in reversed(instruction.ops):
					x86instr.append(X86Push(op, "q"))
				# last thing pushed should be a self parameter
				if instruction.clas[0:5] == "stat.":
					# Dispatch on the vtable of the given static type
					offset = vtable[instruction.clas[5:]][instruction.meth]*8
					x86instr.append(X86Mov("$"+str(instruction.clas[5:])+"..vtable", "%rax", "q"))
					x86instr.append(X86Add("$"+str(offset), "%rax", "q"))
					x86instr.append(X86Call("*(%rax)"))
				else:
					getvt = get_vtable(instruction.ops[0])
					x86instr += getvt
					offset = vtable[instruction.clas][instruction.meth]*8
					x86instr.append(X86Add("$"+str(offset), "%rax", "q"))
					x86instr.append(X86Call("*(%rax)"))
				x86instr.append(X86Add("$"+str(8*len(instruction.ops)), "%rsp", "q"))
				if instruction.assignee != "_dead_":
					x86instr.append(X86Mov("%rax", instruction.assignee, "q"))
				x86instr += restore_caller_save_regs_living(instruction.assignee, instruction.living)

			elif isinstance(instruction, genblocks.TACJmp):
				x86instr.append(X86Jmp(instruction.label))

			elif isinstance(instruction, genblocks.TACLabel):
				x86instr.append(X86Label(instruction.label))

			elif isinstance(instruction, genblocks.TACRet):
				x86instr.append(X86Mov(instruction.op, "%rax", "q"))
				x86instr += restore_callee_save_regs()
				x86instr.append(X86Leave())
				x86instr.append(X86Ret())

			elif isinstance(instruction, genblocks.TACComment):
				pass

			elif isinstance(instruction, genblocks.TACBt):	# branch if boolean is true, cmp will be true if boolean == 1
				x86instr.append(X86Cmp("$1", instruction.boolean, "l"))
				x86instr.append(X86Je(instruction.label))

			elif isinstance(instruction, genblocks.TACIv):
				false_label = nl()
				true_label = nl()
				end_label = nl()
				x86instr.append(X86Cmp("$0", instruction.op, "q"))
				x86instr.append(X86Je(true_label))
				x86instr.append(X86Label(false_label))
				x86instr.append(X86Mov("$0", instruction.assignee, "l"))
				x86instr.append(X86Jmp(end_label))
				x86instr.append(X86Label(true_label))
				x86instr.append(X86Mov("$1", instruction.assignee, "l"))
				x86instr.append(X86Label(end_label))

			elif isinstance(instruction, genblocks.TACError):
				string = instruction.code
				string_count += 1
				strings.append((string, string_count))
				x86instr.append(X86Push("$.GLOB.STR"+str(string_count), "q"))
				x86instr.append(X86Call("error.error"))

			elif isinstance(instruction, genblocks.TACBoxInt):
				x86instr += new_int_generator(instruction.assignee, instruction.op, instruction.living)

			elif isinstance(instruction, genblocks.TACBoxBool):
				x86instr += new_bool_generator(instruction.assignee, instruction.op)

			elif isinstance(instruction, genblocks.TACUnbox):
				# unboxes both ints and bools
				if instruction.assignee != "%rax":
					x86instr.append(X86Push("%rax", "q"))
				x86instr.append(X86Mov(instruction.op, "%rax", "q"))
				x86instr.append(X86Mov("24(%rax)", instruction.assignee, "l"))
				if instruction.assignee != "%rax":
					x86instr.append(X86Pop("%rax", "q"))

	# epilogue
	x86instr.append(X86Cfi(".cfi_endproc"))
	for s in strings: # generate the string constants, 1 character at a time
		x86instr.append(X86Directive(".globl .GLOB.STR"+str(s[1])))
		x86instr.append(X86Directive(".GLOB.STR"+str(s[1])+":"))
		for char in s[0]:
			x86instr.append(X86Directive(".byte\t"+str(ord(char))+"\t#"+str(char)))
		x86instr.append(X86Directive(".byte\t0"))
	return x86instr

# Generate virtual method tables from the implementation map
vtable = {}
def getVTables(the_impl_map):
	global vtable
	x86instr = []
	for clas in the_impl_map:
		vtable[clas.name] = {}
		x86instr.append(X86Directive(".globl "+clas.name+"..vtable"))
		x86instr.append(X86Directive(clas.name+"..vtable:"))
		x86instr.append(X86Directive("\t.quad "+clas.name+".new"))
		vtable[clas.name]["new"] = 0
		offset = 1
		for method in clas.methods:
			vtable[clas.name][method.name] = offset
			x86instr.append(X86Directive("\t.quad "+method.definer+"."+method.name))
			offset += 1
		x86instr.append(X86Directive(""))
	return x86instr

# Generate methods for creating new objects
def newMethods(the_class_map):
	x86instr = []
	for clas in the_class_map:

		clas_type = clas.name
		clas_size = len(clas.attributes)*8+24
		if clas_type == "Int" or clas_type == "Bool": # ints, bools, and strings have implicit attributes
			clas_size += 8
		if clas_type == "String":
			clas_size += 16
		clas_vt = clas.name+"..vtable"
		x86instr.append(X86Directive("\t.section\t.rodata"))

		# create type string
		x86instr.append(X86Label("."+clas.name+".type_string"))
		x86instr.append(X86Directive("\t.string \""+clas.name+"\""))

		# create a string object that holds type string
		x86instr.append(X86Directive(".globl ."+clas.name+".type_string_obj"))
		x86instr.append(X86Directive("."+clas.name+".type_string_obj:"))
		x86instr.append(X86Directive("\t.quad .String.type_string"))
		x86instr.append(X86Directive("\t.quad 40"))
		x86instr.append(X86Directive("\t.quad String..vtable"))
		x86instr.append(X86Directive("\t.quad ."+clas.name+".type_string"))
		x86instr.append(X86Directive("\t.quad "+str(len(clas.name))))
		x86instr.append(X86Directive("\t.text"))
		x86instr.append(X86Directive("\t.globl\t"+clas.name+".new"))
		x86instr.append(X86Directive("\t.type\t"+clas.name+".new, @function"))
		x86instr.append(X86Label(clas.name+".new"))
		x86instr.append(X86Cfi(".cfi_startproc"))
		x86instr.append(X86Push("%rbp", "q"))
		x86instr.append(X86Mov("%rsp", "%rbp", "q"))
		x86instr += callee_save_regs()
		# initialize the object to 0's
		x86instr.append(X86Mov("$1", "%rsi", "q"))
		x86instr.append(X86Mov("$"+str(clas_size), "%rdi", "q"))
		x86instr.append(X86Mov("$0", "%rax", "q"))
		x86instr.append(X86Call("calloc"))
		# string object as first parameter
		x86instr.append(X86Mov("$."+clas.name+".type_string_obj", "(%rax)", "q"))
		# class object as second parameter
		x86instr.append(X86Mov("$"+str(clas_size), "8(%rax)", "q"))
		# vtable as third parameter
		x86instr.append(X86Mov("$"+clas.name+"..vtable", "16(%rax)", "q"))
		x86instr.append(X86Mov("%rax", "%rbx", "q"))
		x86instr.append(X86Push("%rax", "q"))
		attr_loc = 24
		if clas_type == "String":
				x86instr.append(X86Mov("$.NULLSTR", str(attr_loc)+"(%rbx)", "q"))
		# initialize all ints, strings, and bools
		for attr in clas.attributes:
			if attr.typ == "Int" or attr.typ == "String" or attr.typ == "Bool":
				x86instr.append(X86Call(attr.typ+".new"))
				x86instr.append(X86Mov("%rax", str(attr_loc)+"(%rbx)", "q"))
			attr_loc += 8
		attr_loc = 24
		# initialize all attributes
		for attr in clas.attributes:
			if isinstance(attr, ast.ASTInit):
				x86instr.append(X86Call(clas_type+".attr."+attr.name))
				x86instr.append(X86Mov("%rax", str(attr_loc)+"(%rbx)", "q"))
			attr_loc += 8
		x86instr.append(X86Pop("%rax", "q"))
		x86instr += restore_callee_save_regs()
		x86instr.append(X86Leave())
		x86instr.append(X86Ret())
		x86instr.append(X86Cfi(".cfi_endproc"))
	return x86instr

# predefined main function. Create a main object and call main on it
def genmain():
	x86instr = []
	x86instr.append(X86Directive("\t.file\t \"out\""))
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Label(".FORMOFINT"))
	x86instr.append(X86Directive("\t.string \"%d\""))
	x86instr.append(X86Label(".FORMOFLONGINT"))
	x86instr.append(X86Directive("\t.string \"%ld\""))
	x86instr.append(X86Label(".ABORT"))
	x86instr.append(X86Directive("\t.string \"abort\\n\""))
	x86instr.append(X86Label(".NULLSTR"))
	x86instr.append(X86Directive("\t.string \"\""))
	x86instr.append(X86Label(".FORMOFSTRING"))
	x86instr.append(X86Directive("\t.string \"%s\""))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.align 16"))
	x86instr.append(X86Directive("\t.globl\tmain"))
	x86instr.append(X86Directive("\t.type\tmain, @function"))
	x86instr.append(X86Label("main"))
	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	x86instr.append(X86Call("Main.new"))
	x86instr.append(X86Push("%rax", "q"))
	x86instr.append(X86Mov("16(%rax)", "%rax", "q"))
	offset = vtable["Main"]["main"]*8
	x86instr.append(X86Add("$"+str(offset), "%rax", "q"))
	x86instr.append(X86Call("*(%rax)"))
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))
	return x86instr

# error function. Output a given error message and exit
def generror():
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.align 16"))
	x86instr.append(X86Directive("\t.globl\terror.error"))
	x86instr.append(X86Directive("\t.type\terror.error, @function"))
	x86instr.append(X86Label("error.error"))
	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Mov("8(%rsp)", "%rdi", "q"))
	x86instr.append(X86Call("printf"))
	x86instr.append(X86Call("exit"))
	x86instr.append(X86Cfi(".cfi_endproc"))
	return x86instr


###################################################
### HARDCODED X86 FOR THE 10 INTERNAL FUNCTIONS ###
###################################################

# Predefined in_int function. Return input integer object
def gen_io_inint():
	succesful_read = nl()
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tIO.in_int"))
	x86instr.append(X86Directive("\t.type\tIO.in_int, @function"))
	x86instr.append(X86Label("IO.in_int"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	x86instr.append(X86Sub("$8", "%rsp", "q"))
	x86instr += callee_save_regs()
	x86instr.append(X86Mov("$1", "%rsi", "q"))
	x86instr.append(X86Mov("$256", "%rdi", "q")) # read in integer string
	x86instr.append(X86Call("malloc"))
	x86instr.append(X86Push("%rax", "q"))
	x86instr.append(X86Mov("%rax", "%rdi", "q"))
	x86instr.append(X86Mov("$256", "%rsi", "q"))
	x86instr.append(X86Mov("stdin(%rip)", "%rdx", "q"))
	x86instr.append(X86Call("fgets"))
	x86instr.append(X86Pop("%rdi", "q"))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Push("%rax", "q"))
	x86instr.append(X86Mov("%rsp", "%rdx", "q"))
	x86instr.append(X86Mov("$.FORMOFLONGINT", "%rsi", "q"))
	x86instr.append(X86Call("sscanf"))
	x86instr.append(X86Pop("%rax", "q"))
	x86instr.append(X86Mov("$0", "%rsi", "q"))
	# if integer is outside 32-bit integer bounds, return 0
	x86instr.append(X86Cmp("$2147483647", "%rax", "q"))
	x86instr.append(X86Cmovg("%rsi", "%rax", "q"))
	x86instr.append(X86Cmp("$-2147483648", "%rax", "q"))
	x86instr.append(X86Cmovl("%rsi", "%rax", "q"))
	x86instr.append(X86Mov("%rax", "-8(%rbp)", "q"))
	x86instr.append(X86Call("Int.new"))
	x86instr.append(X86Mov("-8(%rbp)", "24(%rax)", "l"))
	x86instr += restore_callee_save_regs()
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined function for reading in strings
def gen_io_instring():
	read_label = nl()
	eof_nl_char = nl()
	nul_char = nl()
	end_label = nl()
	consume_label = nl()

	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tIO.in_string"))
	x86instr.append(X86Directive("\t.type\tIO.in_string, @function"))
	x86instr.append(X86Label("IO.in_string"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	# locals, -8(%rbp) is iterator
	x86instr.append(X86Sub("$32", "%rsp", "q"))
	x86instr += callee_save_regs()
	# allocate memory for string
	x86instr.append(X86Mov("$2048", "%rdi", "q"))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Call("malloc"))
	x86instr.append(X86Mov("%rax", "-16(%rbp)", "q"))
	# initialize length to 0
	x86instr.append(X86Mov("$0", "-8(%rbp)", "q"))
	x86instr.append(X86Label(read_label))
	# read in a character and check to see if it is an eof or nl character
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Mov("stdin(%rip)", "%rdi", "q"))
	x86instr.append(X86Call("fgetc"))
	x86instr.append(X86Cmp("$-1", "%rax", "l"))
	x86instr.append(X86Je(eof_nl_char))
	x86instr.append(X86Cmp("$10", "%rax", "l"))
	x86instr.append(X86Je(eof_nl_char))
	x86instr.append(X86Cmp("$0", "%rax", "l"))
	x86instr.append(X86Je(nul_char))
	x86instr.append(X86Mov("-8(%rbp)", "%rsi", "q"))
	x86instr.append(X86Mov("-16(%rbp)", "%rbx", "q"))
	x86instr.append(X86Add("%rsi", "%rbx", "q"))
	x86instr.append(X86Mov("%rax", "(%rbx)", "b"))
	x86instr.append(X86Add("$1", "-8(%rbp)", "q"))
	x86instr.append(X86Jmp(read_label))
	# if character is eof or newline, append 0 and return
	x86instr.append(X86Label(eof_nl_char))
	x86instr.append(X86Mov("-8(%rbp)", "%rsi", "q"))
	x86instr.append(X86Mov("-16(%rbp)", "%rbx", "q"))
	x86instr.append(X86Add("%rsi", "%rbx", "q"))
	x86instr.append(X86Mov("$0", "(%rbx)", "b"))
	x86instr.append(X86Jmp(end_label))
	# if character is null, read in the rest and return empty string
	x86instr.append(X86Label(nul_char))
	x86instr.append(X86Mov("$.NULLSTR", "-16(%rbp)", "q"))
	x86instr.append(X86Mov("$0", "-8(%rbp)", "q"))
	x86instr.append(X86Label(consume_label))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Call("getchar"))
	x86instr.append(X86Cmp("$-1", "%rax", "l"))
	x86instr.append(X86Je(end_label))
	x86instr.append(X86Cmp("$10", "%rax", "l"))
	x86instr.append(X86Je(end_label))
	x86instr.append(X86Jmp(consume_label))

	x86instr.append(X86Jmp(end_label))
	x86instr.append(X86Label(end_label))
	x86instr.append(X86Call("String.new"))
	x86instr.append(X86Mov("-16(%rbp)", "24(%rax)", "q"))
	x86instr.append(X86Mov("-8(%rbp)", "32(%rax)", "l"))
	x86instr += restore_callee_save_regs()
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined function for outputting ints
def gen_io_outint():
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tIO.out_int"))
	x86instr.append(X86Directive("\t.type\tIO.out_int, @function"))
	x86instr.append(X86Label("IO.out_int"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	x86instr += callee_save_regs()
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Mov("24(%rbp)", "%rsi", "q"))
	x86instr.append(X86Mov("24(%rsi)", "%rsi", "q"))
	x86instr.append(X86Mov("$.FORMOFINT", "%rdi", "q"))
	x86instr.append(X86Call("printf"))
	x86instr.append(X86Mov("16(%rbp)", "%rax", "q"))
	x86instr += restore_callee_save_regs()
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined function for outputting strings
def gen_io_outstring():
	loop_label = nl()
	backslash = nl()
	newline = nl()
	tab = nl()
	end_label = nl()
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tIO.out_string"))
	x86instr.append(X86Directive("\t.type\tIO.out_string, @function"))
	x86instr.append(X86Label("IO.out_string"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	# locals, 16(%rbp) iterator initialized to 0
	x86instr.append(X86Sub("$2048", "%rsp", "q"))
	#x86instr.append(X86Sub("$32", "%rsp", "q"))
	x86instr += callee_save_regs()
	x86instr.append(X86Mov("%rbp", "%r12", "q"))
	x86instr.append(X86Mov("%rbp", "%r13", "q"))
	x86instr.append(X86Sub("$2048", "%r12", "q")) # r12 iterates through the buffer
	x86instr.append(X86Sub("$2048", "%r13", "q")) # r13 holds the base of the buffer
	x86instr.append(X86Mov("$0", "-16(%rbp)", "q"))
	x86instr.append(X86Mov("24(%rbp)", "%rbx", "q"))
	x86instr.append(X86Mov("24(%rbx)", "%rbx", "q"))
	# loop over string putting characters to stdout
	x86instr.append(X86Label(loop_label))
	x86instr.append(X86Mov("-16(%rbp)", "%rdi", "q"))
	x86instr.append(X86Mov("%rbx", "%rax", "q"))
	x86instr.append(X86Add("%rdi", "%rax", "q"))
	x86instr.append(X86Mov("(%rax)", "%rax", "b"))
	x86instr.append(X86Cmp("$92", "%rax", "b"))
	x86instr.append(X86Je(backslash))
	x86instr.append(X86Cmp("$0", "%rax", "b"))
	x86instr.append(X86Je(end_label))
	x86instr.append(X86Mov("%rax", "(%r12)", "b")) # append character to the string
	x86instr.append(X86Add("$1", "%r12", "q"))
	x86instr.append(X86Add("$1", "-16(%rbp)", "q"))
	x86instr.append(X86Jmp(loop_label))
	# if it is a backslash, check the next character
	x86instr.append(X86Label(backslash))
	x86instr.append(X86Mov("-16(%rbp)", "%rdi", "q"))
	x86instr.append(X86Mov("%rbx", "%rax", "q"))
	x86instr.append(X86Add("%rdi", "%rax", "q"))
	x86instr.append(X86Add("$1", "%rax", "q"))
	x86instr.append(X86Mov("(%rax)", "%rax", "b"))
	x86instr.append(X86Cmp("$110", "%rax", "b"))
	x86instr.append(X86Je(newline))
	x86instr.append(X86Cmp("$116", "%rax", "b"))
	x86instr.append(X86Je(tab))
	# if it is not a newline or tab, output backslash, increment iterator by 1, and keep looping
	x86instr.append(X86Mov("$92", "(%r12)", "b")) # append character to the string
	x86instr.append(X86Add("$1", "%r12", "q"))
	x86instr.append(X86Add("$1", "-16(%rbp)", "q"))
	x86instr.append(X86Jmp(loop_label))
	# if it is a newline, print newline and increment array iterator by 2
	x86instr.append(X86Label(newline))
	x86instr.append(X86Mov("$10", "(%r12)", "b")) # append character to the string
	x86instr.append(X86Add("$1", "%r12", "q"))
	x86instr.append(X86Add("$2", "-16(%rbp)", "q"))
	x86instr.append(X86Jmp(loop_label))
	# if it is a tab, print tab and increment array iterator by 2
	x86instr.append(X86Label(tab))
	x86instr.append(X86Mov("$9", "(%r12)", "b")) # append character to the string
	x86instr.append(X86Add("$1", "%r12", "q"))
	x86instr.append(X86Add("$2", "-16(%rbp)", "q"))
	x86instr.append(X86Jmp(loop_label))
	x86instr.append(X86Label(end_label))
	# print the string at the end
	x86instr.append(X86Mov("$0", "(%r12)", "b")) # null terminated
	x86instr.append(X86Mov("%r13", "%rsi", "q"))
	x86instr.append(X86Mov("$.FORMOFSTRING", "%rdi", "q"))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Call("printf")) # print the string

	x86instr.append(X86Mov("16(%rbp)", "%rax", "q"))
	x86instr += restore_callee_save_regs()
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined abort function
def gen_obj_abort():
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tObject.abort"))
	x86instr.append(X86Directive("\t.type\tObject.abort, @function"))
	x86instr.append(X86Label("Object.abort"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Mov("$.ABORT", "%rdi", "q"))
	x86instr.append(X86Call("printf"))
	x86instr.append(X86Call("exit"))
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined copy function
def gen_obj_copy():
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tObject.copy"))
	x86instr.append(X86Directive("\t.type\tObject.copy, @function"))
	x86instr.append(X86Label("Object.copy"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	x86instr += callee_save_regs()
	# allocate the same number of space and do memcopy
	x86instr.append(X86Mov("16(%rbp)", "%rax", "q"))
	x86instr.append(X86Mov("8(%rax)", "%rax", "q"))
	x86instr.append(X86Mov("%rax", "%rdi", "q"))
	x86instr.append(X86Push("%rdi", "q"))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Call("malloc"))
	x86instr.append(X86Pop("%rdx", "q"))
	x86instr.append(X86Mov("16(%rbp)", "%rsi", "q"))
	x86instr.append(X86Mov("%rax", "%rdi", "q"))
	x86instr.append(X86Call("memcpy"))
	x86instr += restore_callee_save_regs()
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined typename function
def gen_obj_typename():
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tObject.type_name"))
	x86instr.append(X86Directive("\t.type\tObject.type_name, @function"))
	x86instr.append(X86Label("Object.type_name"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	# typename is the first attribute in an object
	x86instr.append(X86Mov("16(%rbp)", "%rax", "q"))
	x86instr.append(X86Mov("(%rax)", "%rax", "q"))
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined string concatenation function
def gen_str_concat():
	copy_str1 = nl()
	copy_str2 = nl()
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tString.concat"))
	x86instr.append(X86Directive("\t.type\tString.concat, @function"))
	x86instr.append(X86Label("String.concat"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	# locals
	x86instr.append(X86Sub("$32", "%rsp", "q"))
	x86instr += callee_save_regs()
	# allocate enough space to fit both strings
	x86instr.append(X86Mov("16(%rbp)", "%rbx", "q"))
	x86instr.append(X86Mov("24(%rbp)", "%rsi", "q"))
	x86instr.append(X86Push("%rsi", "q"))
	x86instr.append(X86Mov("32(%rbx)", "%rdi", "q"))
	x86instr.append(X86Add("32(%rsi)", "%rdi", "l"))
	x86instr.append(X86Mov("%rdi", "-8(%rbp)", "q"))
	x86instr.append(X86Add("$1", "%rdi", "l"))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Call("malloc"))
	x86instr.append(X86Mov("%rax", "-16(%rbp)", "q"))
	# copy first string into new string
	x86instr.append(X86Mov("32(%rbx)", "%rdx", "q"))
	x86instr.append(X86Mov("24(%rbx)", "%rsi", "q"))
	x86instr.append(X86Mov("%rax", "%rdi", "q"))
	x86instr.append(X86Call("memcpy"))
	x86instr.append(X86Pop("%rsi", "q"))
	# copy second string into new string at an offset
	x86instr.append(X86Mov("32(%rsi)", "%rdx", "q"))
	x86instr.append(X86Add("$1", "%rdx", "q"))
	x86instr.append(X86Mov("24(%rsi)", "%rsi", "q"))
	x86instr.append(X86Mov("-16(%rbp)", "%rdi", "q"))
	x86instr.append(X86Add("32(%rbx)", "%rdi", "q"))
	x86instr.append(X86Call("memcpy"))
	# return new string
	x86instr.append(X86Call("String.new"))
	x86instr.append(X86Mov("-16(%rbp)", "24(%rax)", "q"))
	x86instr.append(X86Mov("-8(%rbp)", "32(%rax)", "l"))
	x86instr += restore_callee_save_regs()
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined string length function
def gen_str_length():
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tString.length"))
	x86instr.append(X86Directive("\t.type\tString.length, @function"))
	x86instr.append(X86Label("String.length"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	x86instr += callee_save_regs()
	x86instr.append(X86Mov("16(%rbp)", "%rbx", "q"))
	x86instr.append(X86Mov("32(%rbx)", "%rbx", "q"))
	x86instr.append(X86Push("%rbx", "q"))
	# return an integer containing the length attribute of the given string
	x86instr.append(X86Call("Int.new"))
	x86instr.append(X86Pop("%rbx", "q"))
	x86instr.append(X86Mov("%rbx", "24(%rax)", "l"))
	x86instr += restore_callee_save_regs()
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr

# predefined substring function
def gen_str_substr():
	out_of_range = nl()
	end_label = nl()
	error_label = nl()
	no_error_label = nl()
	x86instr = []
	x86instr.append(X86Directive("\t.section\t.rodata"))
	x86instr.append(X86Label(".substr_error"))
	x86instr.append(X86Directive("\t.string \"ERROR: 0: no\""))
	x86instr.append(X86Directive("\t.text"))
	x86instr.append(X86Directive("\t.globl\tString.substr"))
	x86instr.append(X86Directive("\t.type\tString.substr, @function"))
	x86instr.append(X86Label("String.substr"))

	x86instr.append(X86Cfi(".cfi_startproc"))
	x86instr.append(X86Push("%rbp", "q"))
	x86instr.append(X86Mov("%rsp", "%rbp", "q"))
	# locals
	x86instr.append(X86Sub("$32", "%rsp", "q"))
	x86instr += callee_save_regs()
	# move the two integer parameters into locals
	# base of substr is in -24(%rbp)
	# leng of substr is in -32(%rbp)
	x86instr.append(X86Mov("16(%rbp)", "%rbx", "q"))
	x86instr.append(X86Mov("24(%rbp)", "%rdi", "q"))
	x86instr.append(X86Mov("24(%rdi)", "%rdi", "q"))
	x86instr.append(X86Mov("%rdi", "-24(%rbp)", "q"))
	x86instr.append(X86Mov("32(%rbp)", "%rdi", "q"))
	x86instr.append(X86Mov("24(%rdi)", "%rdi", "q"))
	x86instr.append(X86Test("%rdi", "%rdi", "l"))
	x86instr.append(X86Js(error_label))
	x86instr.append(X86Mov("%rdi", "-32(%rbp)", "q"))
	x86instr.append(X86Add("-24(%rbp)", "%rdi", "l"))
	x86instr.append(X86Cmp("32(%rbx)", "%rdi", "l"))
	x86instr.append(X86Jg(error_label))
	x86instr.append(X86Jmp(no_error_label))
	x86instr.append(X86Label(error_label))
	x86instr.append(X86Push("$.substr_error", "q"))
	x86instr.append(X86Call("error.error"))
	x86instr.append(X86Label(no_error_label))
	# malloc space for new string
	x86instr.append(X86Mov("-32(%rbp)", "%rdi", "q"))
	x86instr.append(X86Add("$1", "%rdi", "q"))
	x86instr.append(X86Mov("$0", "%rax", "q"))
	x86instr.append(X86Call("malloc"))
	# copy old string into new string
	x86instr.append(X86Mov("%rax", "-16(%rbp)", "q"))
	x86instr.append(X86Mov("-32(%rbp)", "%rdx", "q"))
	x86instr.append(X86Mov("24(%rbx)", "%rsi", "q"))
	x86instr.append(X86Add("-24(%rbp)", "%rsi", "l"))
	x86instr.append(X86Mov("%rax", "%rdi", "q"))
	x86instr.append(X86Call("memcpy"))
	# return new string
	x86instr.append(X86Call("String.new"))
	x86instr.append(X86Mov("-16(%rbp)", "24(%rax)", "q"))
	x86instr.append(X86Mov("-32(%rbp)", "32(%rax)", "l"))
	x86instr.append(X86Mov("-16(%rbp)", "%rbx", "q"))
	x86instr.append(X86Mov("-32(%rbp)", "%rdi", "q"))
	x86instr.append(X86Add("%rdi", "%rbx", "q"))
	x86instr.append(X86Mov("$0", "(%rbx)", "b"))
	x86instr += restore_callee_save_regs()
	x86instr.append(X86Leave())
	x86instr.append(X86Ret())
	x86instr.append(X86Cfi(".cfi_endproc"))

	return x86instr