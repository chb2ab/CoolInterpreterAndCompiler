import genblocks

# do the box-unbox optimization
def eliminate_redundant_blocks(blocks):
	for block in blocks:
		code = []
		# if a box value is followed immediately by an unbox that value, remove it
		# or if a unbox value is followed immediately by a box that value remove it
		for instruction in block.code:
			if isinstance(instruction, genblocks.TACBoxInt):
				previous_instr = code.pop()
				if isinstance(previous_instr, genblocks.TACUnbox):
					if previous_instr.assignee == instruction.op:
						code.append(genblocks.TACAssign(instruction.assignee, previous_instr.op))
					else:
						code.append(previous_instr)
						code.append(instruction)
				else:
					code.append(previous_instr)
					code.append(instruction)

			elif isinstance(instruction, genblocks.TACBoxBool):
				previous_instr = code.pop()
				if isinstance(previous_instr, genblocks.TACUnbox):
					if previous_instr.assignee == instruction.op:
						code.append(genblocks.TACAssign(instruction.assignee, previous_instr.op))
					else:
						code.append(previous_instr)
						code.append(instruction)
				else:
					code.append(previous_instr)
					code.append(instruction)

			elif isinstance(instruction, genblocks.TACUnbox):
				previous_instr = code.pop()
				if isinstance(previous_instr, genblocks.TACBoxInt) or isinstance(previous_instr, genblocks.TACBoxBool):
					if previous_instr.assignee == instruction.op:
						code.append(genblocks.TACAssign(instruction.assignee, previous_instr.op))
					else:
						code.append(previous_instr)
						code.append(instruction)
				else:
					code.append(previous_instr)
					code.append(instruction)
			else:
				code.append(instruction)
		block.code = code