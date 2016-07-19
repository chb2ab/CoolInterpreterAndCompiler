# Write a string and linenumber
def write_as_identifier(linenumber, identifier, f):
	f.write(str(linenumber) + "\n")
	f.write(identifier + "\n")

# In order traversal of the AST. For each node check the type, write, and recursively call on the children
# Rules for output structure taken from the problem description.
def output(node, f):
	if node.type == "PROGRAM":
		f.write(str(len(node.children))+"\n")
		for child in node.children:
			output(child, f)

	elif node.type == "CLASS":
		write_as_identifier(node.name[1], node.name[0], f)
		if node.inherits == "":
			f.write("no_inherits\n")
		else:
			f.write("inherits\n")
			write_as_identifier(node.inherits[1], node.inherits[0], f)

		f.write(str(len(node.children))+"\n")
		for child in node.children:
			output(child, f)

	elif node.type == "FEATURE":
		f.write(node.init + "\n")
		write_as_identifier(node.identifier[1], node.identifier[0], f)
		if node.init == "attribute_no_init":
			write_as_identifier(node.type2[1], node.type2[0], f)
		elif node.init == "attribute_init":
			write_as_identifier(node.type2[1], node.type2[0], f)
			output(node.body, f)
		else: # Method
			f.write(str(len(node.formals))+"\n")
			for formal in node.formals:
				output(formal, f)
			write_as_identifier(node.type2[1], node.type2[0], f)
			for expr in node.children:
				output(expr, f)

	elif node.type == "FORMAL":
		write_as_identifier(node.identifier[1], node.identifier[0], f)
		write_as_identifier(node.type2[1], node.type2[0], f)

	elif node.type == "EXPR":
		# Handle (expr)
		if node.subpart == "":
			node.children.linenumber = node.linenumber
			output(node.children, f)
		else:
			write_as_identifier(node.linenumber, node.subpart, f)
		
		if node.subpart == "assign":
			write_as_identifier(node.linenumber, node.identifier, f)
			output(node.children, f)

		elif node.subpart == "static_dispatch":
			output(node.children, f)
			write_as_identifier(node.type2[1], node.type2[0], f)
			write_as_identifier(node.identifier[1], node.identifier[0], f)
			f.write(str(len(node.args))+"\n")
			for arg in node.args:
				output(arg, f)

		elif node.subpart == "dynamic_dispatch":
			output(node.children, f)
			write_as_identifier(node.identifier[1], node.identifier[0], f)
			f.write(str(len(node.args))+"\n")
			for arg in node.args:
				output(arg, f)

		elif node.subpart == "self_dispatch":
			write_as_identifier(node.identifier[1], node.identifier[0], f)
			f.write(str(len(node.args))+"\n")
			for arg in node.args:
				output(arg, f)

		elif node.subpart == "if":
			for body in node.children:
				output(body, f)

		elif node.subpart == "while":
			for body in node.children:
				output(body, f)

		elif node.subpart == "block":
			f.write(str(len(node.children))+"\n")
			for body in node.children:
				output(body, f)
			
		elif node.subpart == "new":
			write_as_identifier(node.identifier[1], node.identifier[0], f)
			
		elif node.subpart == "isvoid":
			output(node.children, f)

		elif node.subpart == "plus":
			for expr in node.children:
				output(expr, f)

		elif node.subpart == "minus":
			for expr in node.children:
				output(expr, f)

		elif node.subpart == "times":
			for expr in node.children:
				output(expr, f)

		elif node.subpart == "divide":
			for expr in node.children:
				output(expr, f)

		elif node.subpart == "negate":
			output(node.children, f)

		elif node.subpart == "lt":
			for expr in node.children:
				output(expr, f)

		elif node.subpart == "le":
			for expr in node.children:
				output(expr, f)

		elif node.subpart == "eq":
			for expr in node.children:
				output(expr, f)

		elif node.subpart == "not":
			output(node.children, f)

		elif node.subpart == "identifier":
			write_as_identifier(node.linenumber, node.identifier, f)

		elif node.subpart == "integer":
			f.write(str(int(node.identifier))+"\n")

		elif node.subpart == "string":
			f.write(node.identifier+"\n")
		# true and false already written as subpart
		elif node.subpart == "true":
			pass
		elif node.subpart == "false":
			pass
		elif node.subpart == "let":
			f.write(str(len(node.children))+"\n")
			for binder in node.children:
				if binder.binding == "noinit":
					f.write("let_binding_no_init\n")
					write_as_identifier(binder.identifier[1], binder.identifier[0], f)
					write_as_identifier(binder.type2[1], binder.type2[0], f)
				if binder.binding == "init":
					f.write("let_binding_init\n")
					write_as_identifier(binder.identifier[1], binder.identifier[0], f)
					write_as_identifier(binder.type2[1], binder.type2[0], f)
					output(binder.value, f)
			output(node.body, f)

		elif node.subpart == "case":
			output(node.case, f)
			f.write(str(len(node.children))+"\n")
			for element in node.children:
				write_as_identifier(element.variable[1], element.variable[0], f)
				write_as_identifier(element.type2[1], element.type2[0], f)
				output(element.body, f)
		