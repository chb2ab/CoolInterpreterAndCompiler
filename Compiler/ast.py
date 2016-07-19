import sys
# Classes for each node in AST
class ASTProgram(object):
	def __init__(self):
		self.classes = []

class ASTClass(object):
	def __init__(self, linenum, name, inherits):
		self.linenum = linenum
		self.name = name
		self.inherits = inherits
		self.features = []

class ASTFeature(object):
	pass

class ASTNoInit(ASTFeature):
	def __init__(self, linenum, name, typ):
		self.linenum = linenum
		self.name = name
		self.typ = typ

class ASTInit(ASTFeature):
	def __init__(self, linenum, name, init, typ):
		self.linenum = linenum
		self.name = name
		self.init = init
		self.typ = typ

class ASTMethod(ASTFeature):
	def __init__(self, linenum, name, parameters, body, typ):
		self.linenum = linenum
		self.name = name
		self.parameters = parameters
		self.body = body
		self.typ = typ

class ASTFormal(object):
	def __init__(self, linenum, name, typ):
		self.linenum = linenum
		self.name = name
		self.typ = typ

class ASTExpr(object):
	pass

class ASTAssign(ASTExpr):
	def __init__(self, linenum, etype, var, rhs):
		self.linenum = linenum
		self.etype = etype
		self.var = var
		self.rhs = rhs

class ASTDyndisp(ASTExpr):
	def __init__(self, linenum, etype, e, method, args):
		self.linenum = linenum
		self.etype = etype
		self.e = e
		self.method = method
		self.args = args

class ASTStatdisp(ASTExpr):
	def __init__(self, linenum, etype, e, typ, method, args):
		self.linenum = linenum
		self.etype = etype
		self.e = e
		self.typ = typ
		self.method = method
		self.args = args

class ASTSelfdisp(ASTExpr):
	def __init__(self, linenum, etype, method, args):
		self.linenum = linenum
		self.etype = etype
		self.method = method
		self.args = args

class ASTIf(ASTExpr):
	def __init__(self, linenum, etype, predicate, then, els):
		self.linenum = linenum
		self.etype = etype
		self.predicate = predicate
		self.then = then
		self.els = els

class ASTWhile(ASTExpr):
	def __init__(self, linenum, etype, condition, body):
		self.linenum = linenum
		self.etype = etype
		self.condition = condition
		self.body = body

class ASTBlock(ASTExpr):
	def __init__(self, linenum, etype, body):
		self.linenum = linenum
		self.etype = etype
		self.body = body

class ASTNew(ASTExpr):
	def __init__(self, linenum, etype, clas):
		self.linenum = linenum
		self.etype = etype
		self.clas = clas

class ASTIsvoid(ASTExpr):
	def __init__(self, linenum, etype, e):
		self.linenum = linenum
		self.etype = etype
		self.e = e

class ASTPlus(ASTExpr):
	def __init__(self, linenum, etype, x, y):
		self.linenum = linenum
		self.etype = etype
		self.x = x
		self.y = y

class ASTMinus(ASTExpr):
	def __init__(self, linenum, etype, x, y):
		self.linenum = linenum
		self.etype = etype
		self.x = x
		self.y = y

class ASTTimes(ASTExpr):
	def __init__(self, linenum, etype, x, y):
		self.linenum = linenum
		self.etype = etype
		self.x = x
		self.y = y

class ASTDivide(ASTExpr):
	def __init__(self, linenum, etype, x, y):
		self.linenum = linenum
		self.etype = etype
		self.x = x
		self.y = y

class ASTLt(ASTExpr):
	def __init__(self, linenum, etype, x, y):
		self.linenum = linenum
		self.etype = etype
		self.x = x
		self.y = y

class ASTLe(ASTExpr):
	def __init__(self, linenum, etype, x, y):
		self.linenum = linenum
		self.etype = etype
		self.x = x
		self.y = y

class ASTEq(ASTExpr):
	def __init__(self, linenum, etype, x, y):
		self.linenum = linenum
		self.etype = etype
		self.x = x
		self.y = y

class ASTNot(ASTExpr):
	def __init__(self, linenum, etype, x):
		self.linenum = linenum
		self.etype = etype
		self.x = x

class ASTNegate(ASTExpr):
	def __init__(self, linenum, etype, x):
		self.linenum = linenum
		self.etype = etype
		self.x = x

class ASTInteger(ASTExpr):
	def __init__(self, linenum, etype, const):
		self.linenum = linenum
		self.etype = etype
		self.const = const

class ASTString(ASTExpr):
	def __init__(self, linenum, etype, string):
		self.linenum = linenum
		self.etype = etype
		self.string = string

class ASTEIdent(ASTExpr):
	def __init__(self, linenum, etype, ident):
		self.linenum = linenum
		self.etype = etype
		self.ident = ident

class ASTIdent(ASTExpr):
	def __init__(self, linenum, ident):
		self.linenum = linenum
		self.ident = ident

class ASTTrue(ASTExpr):
	def __init__(self, linenum, etype):
		self.linenum = linenum
		self.etype = etype

class ASTFalse(ASTExpr):
	def __init__(self, linenum, etype):
		self.linenum = linenum
		self.etype = etype

class ASTLet(ASTExpr):
	def __init__(self, linenum, etype, bindings, body):
		self.linenum = linenum
		self.etype = etype
		self.bindings = bindings
		self.body = body

class ASTBindingNoInit(ASTExpr):
	def __init__(self, variable, typ):
		self.variable = variable
		self.typ = typ

class ASTBindingInit(ASTExpr):
	def __init__(self, variable, typ, value):
		self.variable = variable
		self.typ = typ
		self.value = value

class ASTCase(ASTExpr):
	def __init__(self, linenum, etype, case, elements):
		self.linenum = linenum
		self.etype = etype
		self.case = case
		self.elements = elements

class ASTCaseElement(ASTExpr):
	def __init__(self, variable, typ, body):
		self.variable = variable
		self.typ = typ
		self.body = body

class ASTInternal(ASTExpr):
	def __init__(self, method):
		self.method = method

# Deserialization code

def ni(ast):
	return int(ast.pop(0))

def ns(ast):
	return str(ast.pop(0))

def ident_ast_from_file(ast):
	linenum = ni(ast)
	ident = ns(ast)
	return ASTIdent(linenum, ident)

def binding_ast_from_file(ast):
	binding = ns(ast)
	if binding == 'let_binding_no_init':
		variable = ident_ast_from_file(ast)
		typ = ident_ast_from_file(ast)
		retval = ASTBindingNoInit(variable, typ)
	elif binding == 'let_binding_init':
		variable = ident_ast_from_file(ast)
		typ = ident_ast_from_file(ast)
		value = exp_ast_from_file(ast)
		retval = ASTBindingInit(variable, typ, value)
	return retval

def caseelement_ast_from_file(ast):
	variable = ident_ast_from_file(ast)
	typ = ident_ast_from_file(ast)
	body = exp_ast_from_file(ast)
	return ASTCaseElement(variable, typ, body)

def exp_ast_from_file(ast):
	linenum = ni(ast)
	typ = ns(ast)
	exptype = ns(ast)
	retval = None
	if exptype == 'assign':
		var = ident_ast_from_file(ast)
		rhs = exp_ast_from_file(ast)
		retval = ASTAssign(linenum, typ, var, rhs)
	elif exptype == 'dynamic_dispatch':
		e = exp_ast_from_file(ast)
		method = ident_ast_from_file(ast)
		args = []
		numargs = ni(ast)
		for i in range(numargs):
			args.append(exp_ast_from_file(ast))
		retval = ASTDyndisp(linenum, typ, e, method, args)
	elif exptype == 'static_dispatch':
		e = exp_ast_from_file(ast)
		stattyp = ident_ast_from_file(ast)
		method = ident_ast_from_file(ast)
		args = []
		numargs = ni(ast)
		for i in range(numargs):
			args.append(exp_ast_from_file(ast))
		retval = ASTStatdisp(linenum, typ, e, stattyp, method, args)
	elif exptype == 'self_dispatch':
		method = ident_ast_from_file(ast)
		args = []
		numargs = ni(ast)
		for i in range(numargs):
			args.append(exp_ast_from_file(ast))
		retval = ASTSelfdisp(linenum, typ, method, args)
	elif exptype == 'if':
		predicate = exp_ast_from_file(ast)
		then = exp_ast_from_file(ast)
		els = exp_ast_from_file(ast)
		retval = ASTIf(linenum, typ, predicate, then, els)
	elif exptype == 'while':
		condition = exp_ast_from_file(ast)
		body = exp_ast_from_file(ast)
		retval = ASTWhile(linenum, typ, condition, body)
	elif exptype == 'block':
		block = []
		numargs = ni(ast)
		for i in range(numargs):
			block.append(exp_ast_from_file(ast))
		retval = ASTBlock(linenum, typ, block)
	elif exptype == 'new':
		clas = ident_ast_from_file(ast)
		retval = ASTNew(linenum, typ, clas)
	elif exptype == 'isvoid':
		e = exp_ast_from_file(ast)
		retval = ASTIsvoid(linenum, typ, e)
	elif exptype == 'plus':
		x = exp_ast_from_file(ast)
		y = exp_ast_from_file(ast)
		retval = ASTPlus(linenum, typ, x, y)
	elif exptype == 'minus':
		x = exp_ast_from_file(ast)
		y = exp_ast_from_file(ast)
		retval = ASTMinus(linenum, typ, x, y)
	elif exptype == 'times':
		x = exp_ast_from_file(ast)
		y = exp_ast_from_file(ast)
		retval = ASTTimes(linenum, typ, x, y)
	elif exptype == 'divide':
		x = exp_ast_from_file(ast)
		y = exp_ast_from_file(ast)
		retval = ASTDivide(linenum, typ, x, y)
	elif exptype == 'lt':
		x = exp_ast_from_file(ast)
		y = exp_ast_from_file(ast)
		retval = ASTLt(linenum, typ, x, y)
	elif exptype == 'le':
		x = exp_ast_from_file(ast)
		y = exp_ast_from_file(ast)
		retval = ASTLe(linenum, typ, x, y)
	elif exptype == 'eq':
		x = exp_ast_from_file(ast)
		y = exp_ast_from_file(ast)
		retval = ASTEq(linenum, typ, x, y)
	elif exptype == 'not':
		x = exp_ast_from_file(ast)
		retval = ASTNot(linenum, typ, x)
	elif exptype == 'negate':
		x = exp_ast_from_file(ast)
		retval = ASTNegate(linenum, typ, x)
	elif exptype == 'integer':
		const = ni(ast)
		retval = ASTInteger(linenum, typ, const)
	elif exptype == 'string':
		string = ns(ast)
		retval = ASTString(linenum, typ, string)
	elif exptype == 'identifier':
		ident = ident_ast_from_file(ast)
		retval = ASTEIdent(linenum, typ, ident)
	elif exptype == 'true':
		retval = ASTTrue(linenum, typ)
	elif exptype == 'false':
		retval = ASTFalse(linenum, typ)
	elif exptype == 'let':
		bindings = []
		numargs = ni(ast)
		for i in range(numargs):
			bindings.append(binding_ast_from_file(ast))
		body = exp_ast_from_file(ast)
		retval = ASTLet(linenum, typ, bindings, body)
	elif exptype == 'case':
		case = exp_ast_from_file(ast)
		elements = []
		numargs = ni(ast)
		for i in range(numargs):
			elements.append(caseelement_ast_from_file(ast))
		retval = ASTCase(linenum, typ, case, elements)
	elif exptype == 'internal':
		method = ns(ast)
		retval = ASTInternal(method)
	return retval

def formal_ast_from_file(ast):
	linenum = ni(ast)
	name = ns(ast)
	typ = ident_ast_from_file(ast)
	return ASTFormal(linenum, name, typ)

def noinit_ast_from_file(ast):
	linenum = ni(ast)
	name = ns(ast)
	typ = ident_ast_from_file(ast)
	retval = ASTNoInit(linenum, name, typ)
	return retval

def init_ast_from_file(ast):
	linenum = ni(ast)
	name = ns(ast)
	typ = ident_ast_from_file(ast)
	init = exp_ast_from_file(ast)
	retval = ASTInit(linenum, name, typ, init)
	return retval

def method_ast_from_file(ast):
	linenum = ni(ast)
	name = ns(ast)
	params = []
	numparams = ni(ast)
	for i in range(numparams):
		params.append(formal_ast_from_file(ast))
	typ = ident_ast_from_file(ast)
	body = exp_ast_from_file(ast)
	retval = ASTMethod(linenum, name, params, body, typ)
	return retval

def feature_ast_from_file(ast):
	feature_type = ns(ast)
	if feature_type == 'attribute_no_init':
		return noinit_ast_from_file(ast)
	elif feature_type == 'attribute_init':
		return init_ast_from_file(ast)
	elif feature_type == 'method':
		return method_ast_from_file(ast)

def class_ast_from_file(ast):
	linenum = ni(ast)
	classname = ns(ast)
	inherits = ns(ast)

	if inherits == 'inherits':
		cl_inherits = ident_ast_from_file(ast)
	else:
		cl_inherits = 'none'
	myclass = ASTClass(linenum, classname, cl_inherits)
	numfeatures = ni(ast)
	for i in range(numfeatures):
		myclass.features.append(feature_ast_from_file(ast))
	return myclass

def prog_ast(ast):
	prog = ASTProgram()
	numclasses = ni(ast)
	for i in range(numclasses):
		prog.classes.append(class_ast_from_file(ast))
	return prog

# Read in an annotated abstract syntax tree
def get_ast(maps):
	myast = prog_ast(maps)
	return myast

# The parent map is a dictionary mapping a type to it's parent
def get_parent_map(maps):
	ns(maps)
	num_rels = ni(maps)
	pmap = {}
	for i in range(num_rels):
		child = ns(maps)
		parent = ns(maps)
		pmap[child] = parent
	return pmap

class IMClass(object):
	def __init__(self, name):
		self.name = name
		self.methods = []

class IMMethod(object):
	def __init__(self, name, formals, definer, body):
		self.name = name
		self.formals = formals
		self.definer = definer
		self.body = body

# An IMClass is a list of IMMethod's
def get_imp_map_meth(maps):
	name = ns(maps)
	nf = ni(maps)
	formals = []
	for i in range(nf):
		formals.append(ns(maps))
	definer = ns(maps)
	body = exp_ast_from_file(maps)
	return IMMethod(name, formals, definer, body)

# The implementation map is a list of IMClass's
def get_implementation_map(maps):
	ns(maps)
	numclasses = ni(maps)
	im = []
	for i in range(numclasses):
		name = ns(maps)
		num_methods = ni(maps)
		to_add = IMClass(name)
		for i in range(num_methods):
			to_add.methods.append(get_imp_map_meth(maps))
		im.append(to_add)
	return im

class CMClass(object):
	def __init__(self, name):
		self.name = name
		self.attributes = []

# a CMClass is a list of attributes, which may or may not have intializers
def get_class_map_attr(maps):
	init = ns(maps)
	name = ns(maps)
	typ = ns(maps)
	retval = None
	if init == "no_initializer":
		retval = ASTNoInit(0, name, typ)
	elif init == "initializer":
		expr = exp_ast_from_file(maps)
		retval = ASTInit(0, name, expr, typ)
	return retval

# the class map is a list of CMClass's
def get_class_map(maps):
	ns(maps)
	numclasses = ni(maps)
	cm = []
	for i in range(numclasses):
		name = ns(maps)
		num_attributes = ni(maps)
		to_add = CMClass(name)
		for i in range(num_attributes):
			to_add.attributes.append(get_class_map_attr(maps))
		cm.append(to_add)
	return cm

# read in all 4 of the maps from the cl-type file
def maps_from_type_file(filename):
	f = open(filename)
	maps = []
	for line in f:
		maps.append(line.rstrip("\n"))
	class_map = get_class_map(maps)
	impl_map = get_implementation_map(maps)
	parent_map = get_parent_map(maps)
	ast = get_ast(maps)
	return [class_map, impl_map, parent_map, ast]
