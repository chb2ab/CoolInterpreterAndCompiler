import genX86

instrs = []
# do the peephole optimization
def peephole_opt_aux():
	global instrs
	code = []
	changes = 0
	for instruction in instrs:
		# remove jmp's that jump to the very next instruction
		if isinstance(instruction, genX86.X86Label):
			if len(code) > 0:
				previous_instr = code.pop()
				if isinstance(previous_instr, genX86.X86Jmp):
					if previous_instr.label == instruction.label:
						changes += 1
						code.append(instruction)
					else:
						code.append(previous_instr)
						code.append(instruction)
				else:
					code.append(previous_instr)
					code.append(instruction)
			else:
				code.append(instruction)

		# remove a push followed by a pop of the same variable
		elif isinstance(instruction, genX86.X86Pop):
			previous_instr = code.pop()
			if isinstance(previous_instr, genX86.X86Push):
				if instruction.var == previous_instr.var:
					changes += 1
					pass
				else:
					code.append(previous_instr)
					code.append(instruction)
			else:
				code.append(previous_instr)
				code.append(instruction)
		else:
			code.append(instruction)
	instrs = code
	return changes

# Perform basic peephole optimization
def peephole_opt(x86instrs):
	global instrs
	instrs = x86instrs
	changes = peephole_opt_aux()
	while changes != 0:
		changes = peephole_opt_aux()
	return instrs
