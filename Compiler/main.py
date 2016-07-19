import sys

import ast
import genTAC
import genblocks
import tacpeep
import eliminatedc
import registergraph
import genX86
import peephole

if __name__ == "__main__":
	# Deserialize the annotated AST into the 4 maps
	maps = ast.maps_from_type_file(sys.argv[1])
	the_class_map = maps[0]
	the_impl_map = maps[1]
	the_par_map = maps[2]
	the_ast = maps[3]
	x86 = []
	# Generate the VTables for each class using the implementation map
	x86VTables = genX86.getVTables(the_impl_map)
	x86.append(x86VTables)
	# Generate the "new" methods for each type in the class map
	x86NewMethods = genX86.newMethods(the_class_map)
	x86.append(x86NewMethods)
	# Generate code for each method and each attribute
	for (imclass, cmclass) in zip(the_impl_map, the_class_map):
		for attr in cmclass.attributes:
			# Generate initialization method for an attribute that is initialized
			if isinstance(attr, ast.ASTInit):
				# Generate attribute initializer in the same way methods are generated 
				# 1: generate TAC for the initializer
				taclist = genTAC.genAttr(attr, cmclass, the_par_map)
				# 2: convert TAC into basic blocks
				blocks = genblocks.getblocks(taclist)
				# 3: eliminate dead code
				tacpeep.eliminate_redundant_blocks(blocks)
				eliminatedc.eliminatedc(blocks, ["attr"+str(num) for (num, attr) in enumerate(cmclass.attributes)])
				# 4: register allocation
				graph = registergraph.make_graph(blocks, 0)
				max_off = registergraph.assign(graph, blocks)
				# 5: generate x86 code
				x86attr = genX86.gen(blocks, max_off)
				x86attr = peephole.peephole_opt(x86attr)
				x86.append(x86attr)
		for immethod in imclass.methods:
			if immethod.definer == imclass.name:
				# Geberate code for method
				# 1: generate TAC for the method
				taclist = genTAC.genmethod(immethod, cmclass, the_par_map)
				# 2: convert TAC into basic blocks
				blocks = genblocks.getblocks(taclist)
				# 3: eliminate dead code
				tacpeep.eliminate_redundant_blocks(blocks)
				eliminatedc.eliminatedc(blocks, ["attr"+str(num) for (num, attr) in enumerate(cmclass.attributes)])
				# 4: register allocation
				graph = registergraph.make_graph(blocks, 0)
				max_off = registergraph.assign(graph, blocks)
				# 5: generate x86 code
				x86meth = genX86.gen(blocks, max_off)
				x86meth = peephole.peephole_opt(x86meth)
				x86.append(x86meth)
	# generate main method and error reporting method
	x86.append(genX86.genmain())
	x86.append(genX86.generror())
	# output to file
	filename = sys.argv[1]
	f = open(filename[0:len(filename)-7]+"s", 'w')
	for method in x86:
		for instr in method:
			f.write(str(instr))