from ast import *
from genblocks import *
import copy
# Global variables used for TAC generation
taclist = []
reg_counter = 0
label_counter = -1

# TAC generation functions
def nr():
	global reg_counter
	reg_counter += 1
	return "t$" + str(reg_counter)

def nl():
	global label_counter
	label_counter += 1
	return "label_" + str(label_counter)

def get_sym(ident, symbol_table):
	if not ident in symbol_table:
		symbol_table[ident] = nr()
	return symbol_table[ident]

def gen(ast, symbol_table):
	global taclist
	global my_class
	global parent_map
	if (isinstance(ast, ASTProgram)):
		for child in ast.classes:
			gen(child, copy.deepcopy(symbol_table))
	elif (isinstance(ast, ASTClass)):
		for feature in ast.features:
			gen(feature, copy.deepcopy(symbol_table))
	elif (isinstance(ast, ASTNoInit)):
		pass
	elif (isinstance(ast, ASTInit)):
		pass
	elif (isinstance(ast, ASTMethod)):
		label = nl()
		taclist.append(TACLabel(label))
		for formal in ast.parameters:
			pass
		retval = gen(ast.body, copy.deepcopy(symbol_table))
		taclist.append(TACRet(retval))
	elif (isinstance(ast, ASTFormal)):
		pass
	elif (isinstance(ast, ASTAssign)):
		myexp = gen(ast.rhs, copy.deepcopy(symbol_table))
		temp = get_sym(ast.var.ident, symbol_table)
		if temp[0:4] == "attr":
			newtemp = nr()
			taclist.append(TACAssign(newtemp, myexp))
			taclist.append(TACAssign(temp, newtemp))
			return newtemp
		else:
			taclist.append(TACAssign(temp, myexp))
			return temp
	elif (isinstance(ast, ASTDyndisp)):
		caller_type = ast.e.etype
		if caller_type == "SELF_TYPE":
			caller_type = my_class
		args = []
		for arg in ast.args:
			e = nr()
			taclist.append(TACAssign(e, str(gen(arg, copy.deepcopy(symbol_table)))))
			args.append(e)
		myexp = gen(ast.e, copy.deepcopy(symbol_table))
		void_check = nr()
		not_void_label = nl()
		notvoid = nr()
		taclist.append(TACIv(void_check, myexp))
		taclist.append(TACBneg(notvoid, void_check))
		taclist.append(TACBt(notvoid, not_void_label))
		taclist.append(TACError("ERROR: "+str(ast.linenum)+": dynamic dispatch on void"))
		taclist.append(TACLabel(not_void_label))
		method = ast.method.ident
		args = [myexp]+args
		newtemp = nr()
		taclist.append(TACCall(newtemp, method, caller_type, args))
		return newtemp
	elif (isinstance(ast, ASTStatdisp)):
		caller_type = ast.typ.ident
		args = []
		for arg in ast.args:
			e = nr()
			taclist.append(TACAssign(e, str(gen(arg, copy.deepcopy(symbol_table)))))
			args.append(e)
		myexp = gen(ast.e, copy.deepcopy(symbol_table))
		void_check = nr()
		not_void_label = nl()
		notvoid = nr()
		taclist.append(TACIv(void_check, myexp))
		taclist.append(TACBneg(notvoid, void_check))
		taclist.append(TACBt(notvoid, not_void_label))
		taclist.append(TACError("ERROR: "+str(ast.linenum)+": dynamic dispatch on void"))
		taclist.append(TACLabel(not_void_label))
		method = ast.method.ident
		args = [myexp]+args
		newtemp = nr()
		taclist.append(TACCall(newtemp, method, "stat."+caller_type, args))
		return newtemp
	elif (isinstance(ast, ASTSelfdisp)):
		method = ast.method.ident
		args = ["self"]
		for arg in ast.args:
			e = nr()
			taclist.append(TACAssign(e, str(gen(arg, copy.deepcopy(symbol_table)))))
			args.append(e)
		newtemp = nr()
		taclist.append(TACCall(newtemp, method, my_class, args))
		return newtemp
	elif (isinstance(ast, ASTIf)):
		truelabel = nl()
		falselabel = nl()
		endlabel = nl()
		retval = nr()

		exp1 = gen(ast.predicate, copy.deepcopy(symbol_table))
		unboxed_bool = nr()
		taclist.append(TACUnbox(unboxed_bool, exp1))
		taclist.append(TACBt(unboxed_bool, truelabel))

		taclist.append(TACJmp(falselabel))
		taclist.append(TACLabel(falselabel))
		exp3 = gen(ast.els, copy.deepcopy(symbol_table))
		taclist.append(TACAssign(retval, exp3))
		taclist.append(TACJmp(endlabel))
		
		taclist.append(TACLabel(truelabel))
		exp2 = gen(ast.then, copy.deepcopy(symbol_table))
		taclist.append(TACAssign(retval, exp2))
		taclist.append(TACJmp(endlabel))

		taclist.append(TACLabel(endlabel))
		return retval
	elif (isinstance(ast, ASTWhile)):
		newlabel1 = nl()
		newlabel2 = nl()
		newtemp = nr()
		retval = nr()
	
		taclist.append(TACJmp(newlabel1))
		taclist.append(TACLabel(newlabel1))
		myexp1 = gen(ast.condition, copy.deepcopy(symbol_table))
		unboxed_myexp = nr()
		taclist.append(TACUnbox(unboxed_myexp, myexp1))
		taclist.append(TACBneg(newtemp, unboxed_myexp))
		taclist.append(TACBt(newtemp, newlabel2))
		gen(ast.body, copy.deepcopy(symbol_table))
		taclist.append(TACJmp(newlabel1))
		taclist.append(TACLabel(newlabel2))
		taclist.append(TACAssign(retval, "Void"))
		return retval
	elif (isinstance(ast, ASTBlock)):
		retval = ""
		for b in ast.body:
			retval = gen(b, copy.deepcopy(symbol_table))
		return retval
	elif (isinstance(ast, ASTNew)):
		newtemp = nr()
		taclist.append(TACAlloc(newtemp, ast.clas.ident))
		return newtemp
	elif (isinstance(ast, ASTIsvoid)):
		retval = nr()
		arg = gen(ast.e, copy.deepcopy(symbol_table))
		taclist.append(TACIv(retval, arg))
		taclist.append(TACBoxBool(retval, retval))
		return retval
	elif (isinstance(ast, ASTPlus)):
		exp1 = nr()
		exp2 = nr()
		myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
		taclist.append(TACUnbox(exp1, myexp1))
		myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
		taclist.append(TACUnbox(exp2, myexp2))
		newtemp = nr()
		taclist.append(TACPlus(newtemp, exp1, exp2))
		taclist.append(TACBoxInt(newtemp, newtemp))
		return newtemp
	elif (isinstance(ast, ASTMinus)):
		exp1 = nr()
		exp2 = nr()
		myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
		taclist.append(TACUnbox(exp1, myexp1))
		myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
		taclist.append(TACUnbox(exp2, myexp2))
		newtemp = nr()
		taclist.append(TACMinus(newtemp, exp1, exp2))
		taclist.append(TACBoxInt(newtemp, newtemp))
		return newtemp
	elif (isinstance(ast, ASTTimes)):
		exp1 = nr()
		exp2 = nr()
		myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
		taclist.append(TACUnbox(exp1, myexp1))
		myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
		taclist.append(TACUnbox(exp2, myexp2))
		newtemp = nr()
		taclist.append(TACMult(newtemp, exp1, exp2))
		taclist.append(TACBoxInt(newtemp, newtemp))
		return newtemp
	elif (isinstance(ast, ASTDivide)):
		exp1 = nr()
		exp2 = nr()
		myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
		taclist.append(TACUnbox(exp1, myexp1))
		myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
		taclist.append(TACUnbox(exp2, myexp2))
		zero_const = nr()
		taclist.append(TACInt(zero_const, "0"))
		zero_check = nr()
		not_zero_label = nl()
		nonzero = nr()
		taclist.append(TACEq(zero_check, zero_const, exp2, "Int"))
		taclist.append(TACBneg(nonzero, zero_check))
		taclist.append(TACBt(nonzero, not_zero_label))
		taclist.append(TACError("ERROR: "+str(ast.linenum)+": divide by 0"))
		taclist.append(TACLabel(not_zero_label))
		newtemp = nr()
		taclist.append(TACDiv(newtemp, exp1, exp2))
		taclist.append(TACBoxInt(newtemp, newtemp))
		return newtemp
	elif (isinstance(ast, ASTLt)):
		if ast.x.etype == "Int" or ast.x.etype == "Bool":
			exp1 = nr()
			exp2 = nr()
			myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
			taclist.append(TACUnbox(exp1, myexp1))
			myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
			taclist.append(TACUnbox(exp2, myexp2))
			newtemp = nr()
			taclist.append(TACLt(newtemp, exp1, exp2, "Int"))
			taclist.append(TACBoxBool(newtemp, newtemp))
			return newtemp
		else:
			exp1 = nr()
			exp2 = nr()
			myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
			taclist.append(TACAssign(exp1, myexp1))
			myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
			taclist.append(TACAssign(exp2, myexp2))
			newtemp = nr()
			taclist.append(TACLt(newtemp, exp1, exp2, ast.x.etype))
			taclist.append(TACBoxBool(newtemp, newtemp))
			return newtemp
	elif (isinstance(ast, ASTLe)):
		if ast.x.etype == "Int" or ast.x.etype == "Bool":
			exp1 = nr()
			exp2 = nr()
			myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
			taclist.append(TACUnbox(exp1, myexp1))
			myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
			taclist.append(TACUnbox(exp2, myexp2))
			newtemp = nr()
			taclist.append(TACLte(newtemp, exp1, exp2, "Int"))
			taclist.append(TACBoxBool(newtemp, newtemp))
			return newtemp
		else:
			exp1 = nr()
			exp2 = nr()
			myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
			taclist.append(TACAssign(exp1, myexp1))
			myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
			taclist.append(TACAssign(exp2, myexp2))
			newtemp = nr()
			taclist.append(TACLte(newtemp, exp1, exp2, ast.x.etype))
			taclist.append(TACBoxBool(newtemp, newtemp))
			return newtemp
	elif (isinstance(ast, ASTEq)):
		if ast.x.etype == "Int" or ast.x.etype == "Bool":
			exp1 = nr()
			exp2 = nr()
			myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
			taclist.append(TACUnbox(exp1, myexp1))
			myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
			taclist.append(TACUnbox(exp2, myexp2))
			newtemp = nr()
			taclist.append(TACEq(newtemp, exp1, exp2, "Int"))
			taclist.append(TACBoxBool(newtemp, newtemp))
			return newtemp
		else:
			exp1 = nr()
			exp2 = nr()
			myexp1 = gen(ast.x, copy.deepcopy(symbol_table))
			taclist.append(TACAssign(exp1, myexp1))
			myexp2 = gen(ast.y, copy.deepcopy(symbol_table))
			taclist.append(TACAssign(exp2, myexp2))
			newtemp = nr()
			taclist.append(TACEq(newtemp, exp1, exp2, ast.x.etype))
			taclist.append(TACBoxBool(newtemp, newtemp))
			return newtemp
	elif (isinstance(ast, ASTNot)):
		retval = nr()
		exp = gen(ast.x, copy.deepcopy(symbol_table))
		unboxed_exp = nr()
		taclist.append(TACUnbox(unboxed_exp, exp))
		taclist.append(TACBneg(unboxed_exp, unboxed_exp))
		taclist.append(TACBoxBool(retval, unboxed_exp))
		return retval
	elif (isinstance(ast, ASTNegate)):
		retval = nr()
		unb = nr()
		exp = gen(ast.x, copy.deepcopy(symbol_table))

		taclist.append(TACUnbox(unb, exp))
		taclist.append(TACAneg(retval, unb))
		taclist.append(TACBoxInt(retval, retval))
		return retval
	elif (isinstance(ast, ASTInteger)):
		newtemp = nr()
		taclist.append(TACInt(newtemp, str(ast.const)))
		taclist.append(TACBoxInt(newtemp, newtemp))
		return newtemp
	elif (isinstance(ast, ASTString)):
		newtemp = nr()
		taclist.append(TACStr(newtemp, ast.string))
		return newtemp
	elif (isinstance(ast, ASTEIdent)):
		temp = get_sym(ast.ident.ident, symbol_table)
		if temp[0:4] == "attr":
			newtemp = nr()
			taclist.append(TACAssign(newtemp, temp))
			return newtemp
		else:
			return temp
	elif (isinstance(ast, ASTTrue)):
		newtemp = nr()
		taclist.append(TACBool(newtemp, "true"))
		taclist.append(TACBoxBool(newtemp, newtemp))
		return newtemp
	elif (isinstance(ast, ASTFalse)):
		newtemp = nr()
		taclist.append(TACBool(newtemp, "false"))
		taclist.append(TACBoxBool(newtemp, newtemp))
		return newtemp
	elif (isinstance(ast, ASTLet)):
		for binding in ast.bindings:
			gen(binding, symbol_table)
		retval = gen(ast.body, copy.deepcopy(symbol_table))
		return retval
	elif (isinstance(ast, ASTBindingNoInit)):
		variable = ast.variable.ident
		typ = ast.typ.ident
		retval = nr()
		taclist.append(TACDef(retval, typ))
		symbol_table[variable] = retval
		return retval
	elif (isinstance(ast, ASTBindingInit)):
		variable = ast.variable.ident
		retval = nr()
		newtemp = gen(ast.value, copy.deepcopy(symbol_table))
		taclist.append(TACAssign(retval, newtemp))
		symbol_table[variable] = retval
		return retval
	elif (isinstance(ast, ASTCase)):
		cas = gen(ast.case, symbol_table)
		case_var = nr()
		taclist.append(TACAssign(case_var, cas))
		void_check = nr()
		void_label = nl()
		taclist.append(TACIv(void_check, cas))
		taclist.append(TACBt(void_check, void_label))

		all_types = [child for child in parent_map.keys()]+["Object"]
		reachable_types = []
		static_casetype = ast.case.etype
		if static_casetype == "SELF_TYPE":
			static_casetype = my_class

		for possible_type in all_types:
			iterator = possible_type
			while iterator != static_casetype and iterator != "Object":
				iterator = parent_map[iterator]
			if iterator == static_casetype:
				reachable_types.append(possible_type)

		retval = nr()
		base_cases = [ce.typ.ident for ce in ast.elements]
		reachable_base_cases = []
		for case in base_cases:
			if case in reachable_types:
				reachable_base_cases.append(case)

		iterator = static_casetype
		while iterator not in base_cases and iterator != "Object":
			iterator = parent_map[iterator]
		if iterator not in reachable_base_cases and iterator in base_cases:
			reachable_base_cases.append(iterator)

		if len(reachable_base_cases) == 0:
			taclist.append(TACError("ERROR: "+str(ast.linenum)+": no matching case branch"))
			taclist.append(TACLabel(void_label))
			taclist.append(TACError("ERROR: "+str(ast.linenum)+": case on void"))
			return retval

		case_labels = {}
		for case in reachable_base_cases:
			case_labels[case] = nl()
		case_labels["error"] = nl()
		end_label = nl()

		for possible_type in reachable_types:
			iterator = possible_type
			while iterator not in reachable_base_cases and iterator != "Object":
				iterator = parent_map[iterator]
			if iterator not in reachable_base_cases:
				iterator = "error"
			type_reg = nr()
			res_reg = nr()
			taclist.append(TACTypeCheck(res_reg, cas, possible_type))
			taclist.append(TACBt(res_reg, str(case_labels[iterator])))

		for case in ast.elements:
			if case.typ.ident in reachable_base_cases:
				taclist.append(TACLabel(str(case_labels[case.typ.ident])))
				new_table = copy.deepcopy(symbol_table)
				new_table[case.variable.ident] = case_var
				ret = gen(case.body, new_table)
				taclist.append(TACAssign(retval, ret))
				taclist.append(TACJmp(end_label))
		taclist.append(TACLabel(str(case_labels["error"])))
		taclist.append(TACError("ERROR: "+str(ast.linenum)+": no matching case branch"))
		taclist.append(TACLabel(void_label))
		taclist.append(TACError("ERROR: "+str(ast.linenum)+": case on void"))
		taclist.append(TACLabel(str(end_label)))
		return retval
	elif (isinstance(ast, ASTCaseElement)):
		pass
	elif (isinstance(ast, ASTIdent)):
		raise Exception("ASTIdent, gentac, shouldn't be reached should be ASTEIdent instead")

def fill_list(ast, symbol_table):
	return gen(ast, symbol_table)

my_class = []
parent_map = []
# generate TAC for a method
def genmethod(immethod, cmclass, the_par_map):
	global my_class
	global parent_map
	parent_map = the_par_map
	my_class = cmclass.name
	ast = immethod.body
	symbol_table = {}
	symbol_table["self"] = "self"
	attr_count = 0
	global taclist
	taclist = []
	taclist.append(TACLabel(immethod.definer+"."+immethod.name))
	for attribute in cmclass.attributes:
		reg = nr()
		symbol_table[attribute.name] = "attr"+str(attr_count)
		attr_count += 1
	param_count = 24
	for formal in immethod.formals:
		reg = nr()
		symbol_table[formal] = reg
		taclist.append(TACAssign(reg, "param"+str(param_count)))
		param_count += 8
	retval = fill_list(ast, symbol_table)
	attr_count = 0
	if retval == None:
		pass
	else:
		taclist.append(TACRet(retval))
	return taclist

# generate attribute initializationmethod
def genAttr(astinit, cmclass, the_par_map):
	global my_class
	global parent_map
	parent_map = the_par_map
	my_class = cmclass.name
	ast = astinit.init
	symbol_table = {}
	symbol_table["self"] = "self"
	attr_count = 0
	global taclist
	taclist = []
	taclist.append(TACLabel(my_class+".attr."+astinit.name))
	for attribute in cmclass.attributes:
		reg = nr()
		symbol_table[attribute.name] = "attr"+str(attr_count)
		attr_count += 1
	retval = fill_list(ast, symbol_table)
	attr_count = 0
	if retval == None:
		pass
	else:
		taclist.append(TACRet(retval))
	return taclist

