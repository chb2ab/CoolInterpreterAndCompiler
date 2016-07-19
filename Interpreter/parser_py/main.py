import sys
import yacc
import cerealize
import gentoks

# Custom lexer for reading in token output of PA2
class lex(object):
	def input(self, tokens):
		self.tokens = tokens
		self.ind = 0

	def token(self):
		if self.ind >= len(self.tokens):
			return None
		ret = self.tokens[self.ind]
		self.ind += 1
		return ret

# General object for a node in the AST.
class node(object):
	def __init__(self, type, children):
		self.type = type
		self.children = children

# All possible tokens
tokens = (
	'string',
	'at',
	'case',
	'class',
	'rarrow',
	'le',
	'colon',
	'comma',
	'divide',
	'dot',
	'else',
	'equals',
	'esac',
	'false',
	'fi',
	'if',
	'in',
	'inherits',
	'integer',
	'isvoid',
	'larrow',
	'lbrace',
	'let',
	'loop',
	'lparen',
	'lt',
	'minus',
	'new',
	'not',
	'of',
	'plus',
	'pool',
	'rbrace',
	'rparen',
	'semi',
	'then',
	'tilde',
	'times',
	'true',
	'while',
	'type',
	'identifier',
)

precedence = (
    ('right', 'larrow'),
    ('left', 'not'),
    ('nonassoc', 'le', 'lt', 'equals'),
    ('left', 'plus', 'minus'),
    ('left', 'times', 'divide'),
    ('left', 'isvoid'),
    ('left', 'tilde'),
    ('left', 'at'),
    ('left', 'dot')
)

# CFG definition, derived from cool reference manual
def p_PROGRAM(p):
	'PROGRAM : CLASS semi'
	p[0] = node("PROGRAM", [p[1]])

def p_PROGRAM_multiple_CLASSes(p):
	'PROGRAM : PROGRAM CLASS semi'
	p[1].children.append(p[2])
	p[0] = node("PROGRAM", p[1].children)

def p_CLASS_inherits_FEATURE(p):
	'CLASS : class type inherits type lbrace FEATUREPLUS rbrace'
	p[0] = node("CLASS", p[6].children)
	p[0].name = ( p[2], p.lineno(2) )
	p[0].inherits = ( p[4], p.lineno(4) )

def p_CLASS_inherits(p):
	'CLASS : class type inherits type lbrace rbrace'
	p[0] = node("CLASS", [])
	p[0].name = ( p[2], p.lineno(2) )
	p[0].inherits = ( p[4], p.lineno(4) )

def p_CLASS_FEATURE(p):
	'CLASS : class type lbrace FEATUREPLUS rbrace'
	p[0] = node("CLASS", p[4].children)
	p[0].name = ( p[2], p.lineno(2) )
	p[0].inherits = ""

def p_CLASS(p):
	'CLASS : class type lbrace rbrace'
	p[0] = node("CLASS", [])
	p[0].name = ( p[2], p.lineno(2) )
	p[0].inherits = ""

def p_FEATURE_FORMALPLUS(p):
	'FEATURE : identifier lparen FORMALPLUS rparen colon type lbrace EXPR rbrace'
	p[0] = node("FEATURE", [p[8]])
	p[0].identifier = ( p[1], p.lineno(1) )
	p[0].init = "method"
	p[0].type2 = ( p[6], p.lineno(6) )
	p[0].formals = p[3].children

def p_FEATURE_noFORMAL(p):
	'FEATURE : identifier lparen rparen colon type lbrace EXPR rbrace'
	p[0] = node("FEATURE", [p[7]])
	p[0].identifier = ( p[1], p.lineno(1) )
	p[0].init = "method"
	p[0].type2 = ( p[5], p.lineno(5) )
	p[0].expr = p[7]
	p[0].formals = []

def p_FEATURE_noEXPR(p):
	'FEATURE : identifier colon type'
	p[0] = node("FEATURE", [])
	p[0].identifier = ( p[1], p.lineno(1) )
	p[0].init = "attribute_no_init"
	p[0].type2 = ( p[3], p.lineno(3) )


def p_FEATURE_EXPR(p):
	'FEATURE : identifier colon type larrow EXPR'
	p[0] = node("FEATURE", [])
	p[0].identifier = ( p[1], p.lineno(1) )
	p[0].init = "attribute_init"
	p[0].type2 = ( p[3], p.lineno(3) )
	p[0].body = p[5]

def p_FORMAL(p):
	'FORMAL : identifier colon type'
	p[0] = node("FORMAL", [])
	p[0].identifier = ( p[1], p.lineno(1) )
	p[0].type2 = ( p[3], p.lineno(3) )

def p_EXPR_assign(p):
	'EXPR : identifier larrow EXPR'
	p[0] = node("EXPR", p[3])
	p[0].identifier = p[1]
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "assign"

def p_EXPR_at_EXPRPLUS(p):
	'EXPR : EXPR at type dot identifier lparen EXPRPLUS rparen'
	p[0] = node("EXPR", p[1])
	p[0].identifier = ( p[5], p.lineno(5) )
	p[0].type2 = ( p[3], p.lineno(3) )
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "static_dispatch"
	p[0].args = p[7].children

def p_EXPR_at(p):
	'EXPR : EXPR at type dot identifier lparen rparen'
	p[0] = node("EXPR", p[1])
	p[0].identifier = ( p[5], p.lineno(5) )
	p[0].type2 = ( p[3], p.lineno(3) )
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "static_dispatch"
	p[0].args = []

def p_EXPR_EXPRPLUS(p):
	'EXPR : EXPR dot identifier lparen EXPRPLUS rparen'
	p[0] = node("EXPR", p[1])
	p[0].identifier = ( p[3], p.lineno(3) )
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "dynamic_dispatch"
	p[0].args = p[5].children

def p_EXPR_no_EXPRPLUS(p):
	'EXPR : EXPR dot identifier lparen rparen'
	p[0] = node("EXPR", p[1])
	p[0].identifier = ( p[3], p.lineno(3) )
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "dynamic_dispatch"
	p[0].args = []

def p_EXPR_identifier_EXPRPLUS(p):
	'EXPR : identifier lparen EXPRPLUS rparen'
	p[0] = node("EXPR", [])
	p[0].identifier = ( p[1], p.lineno(1) )
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "self_dispatch"
	p[0].args = p[3].children

def p_EXPR_identifier(p):
	'EXPR : identifier lparen rparen'
	p[0] = node("EXPR", [])
	p[0].identifier = ( p[1], p.lineno(1) )
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "self_dispatch"
	p[0].args = []

def p_EXPR_if(p):
	'EXPR : if EXPR then EXPR else EXPR fi'
	p[0] = node("EXPR", [p[2], p[4], p[6]])
	p[0].identifier = "if"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "if"

def p_EXPR_while(p):
	'EXPR : while EXPR loop EXPR pool'
	p[0] = node("EXPR", [p[2], p[4]])
	p[0].identifier = "while"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "while"

def p_EXPR_braced(p):
	'EXPR : lbrace EXPRSEMIPLUS rbrace'
	p[0] = node("EXPR", p[2].children)
	p[0].identifier = "block"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "block"

def p_EXPR_let_all(p):
	'EXPR : let identifier colon type larrow EXPR IDTYPEEXPRPLUS in EXPR'
	toappend = node("IDTYPEEXPRPLUS", [])
	toappend.identifier = ( p[2], p.lineno(2) )
	toappend.binding = "init"
	toappend.value = p[6]
	toappend.type2 = ( p[4], p.lineno(4) )
	toappend.linenumber = p.lineno(1)
	p[7].children.insert(0, toappend)
	p[0] = node("EXPR", p[7].children)
	p[0].subpart = "let"
	p[0].body = p[9]
	p[0].linenumber = p.lineno(1)

def p_EXPR_let_no_IDTYPEEXPRPLUS(p):
	'EXPR : let identifier colon type larrow EXPR in EXPR'
	toappend = node("IDTYPEEXPRPLUS", [])
	toappend.identifier = ( p[2], p.lineno(2) )
	toappend.binding = "init"
	toappend.value = p[6]
	toappend.type2 = ( p[4], p.lineno(4) )
	toappend.linenumber = p.lineno(1)
	p[0] = node("EXPR", [toappend])
	p[0].subpart = "let"
	p[0].body = p[8]
	p[0].linenumber = p.lineno(1)

def p_EXPR_let_no_larrow(p):
	'EXPR : let identifier colon type IDTYPEEXPRPLUS in EXPR'
	toappend = node("IDTYPEEXPRPLUS", [])
	toappend.identifier = ( p[2], p.lineno(2) )
	toappend.binding = "noinit"
	toappend.type2 = ( p[4], p.lineno(4) )
	toappend.linenumber = p.lineno(1)
	p[5].children.insert(0, toappend)
	p[0] = node("EXPR", p[5].children)
	p[0].subpart = "let"
	p[0].body = p[7]
	p[0].linenumber = p.lineno(1)

def p_EXPR_let_no_IDTYPEEXPRPLUS_no_larrow(p):
	'EXPR : let identifier colon type in EXPR'
	toappend = node("IDTYPEEXPRPLUS", [])
	toappend.identifier = ( p[2], p.lineno(2) )
	toappend.binding = "noinit"
	toappend.type2 = ( p[4], p.lineno(4) )
	toappend.linenumber = p.lineno(1)
	p[0] = node("EXPR", [toappend])
	p[0].subpart = "let"
	p[0].body = p[6]
	p[0].linenumber = p.lineno(1)

def p_EXPR_case_IDTYPEARROWPLUS(p):
	'EXPR : case EXPR of IDTYPEARROWPLUS esac'
	p[0] = node("EXPR", p[4].children)
	p[0].subpart = "case"
	p[0].linenumber = p.lineno(1)
	p[0].case = p[2]

def p_EXPR_new(p):
	'EXPR : new type'
	p[0] = node("EXPR", [])
	p[0].identifier = ( p[2], p.lineno(2) )
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "new"

def p_EXPR_isvoid(p):
	'EXPR : isvoid EXPR'
	p[0] = node("EXPR", p[2])
	p[0].identifier = "isvoid"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "isvoid"

def p_EXPR_plus(p):
	'EXPR : EXPR plus EXPR'
	p[0] = node("EXPR", [p[1], p[3]])
	p[0].identifier = "plus"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "plus"

def p_EXPR_minus(p):
	'EXPR : EXPR minus EXPR'
	p[0] = node("EXPR", [p[1], p[3]])
	p[0].identifier = "minus"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "minus"

def p_EXPR_mult(p):
	'EXPR : EXPR times EXPR'
	p[0] = node("EXPR", [p[1], p[3]])
	p[0].identifier = "times"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "times"

def p_EXPR_div(p):
	'EXPR : EXPR divide EXPR'
	p[0] = node("EXPR", [p[1], p[3]])
	p[0].identifier = "divide"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "divide"

def p_EXPR_neg(p):
	'EXPR : tilde EXPR'
	p[0] = node("EXPR", p[2])
	p[0].identifier = "negate"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "negate"

def p_EXPR_lt(p):
	'EXPR : EXPR lt EXPR'
	p[0] = node("EXPR", [p[1], p[3]])
	p[0].identifier = "lt"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "lt"

def p_EXPR_le(p):
	'EXPR : EXPR le EXPR'
	p[0] = node("EXPR", [p[1], p[3]])
	p[0].identifier = "le"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "le"

def p_EXPR_equals(p):
	'EXPR : EXPR equals EXPR'
	p[0] = node("EXPR", [p[1], p[3]])
	p[0].identifier = "eq"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "eq"

def p_EXPR_not(p):
	'EXPR : not EXPR'
	p[0] = node("EXPR", p[2])
	p[0].identifier = "not"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "not"

def p_EXPR_parens(p):
	'EXPR : lparen EXPR rparen'
	p[0] = node("EXPR", p[2])
	p[0].identifier = "parens"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = ""

def p_EXPR_ident(p):
	'EXPR : identifier'
	p[0] = node("EXPR", [])
	p[0].identifier = p[1]
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "identifier"

def p_EXPR_int(p):
	'EXPR : integer'
	p[0] = node("EXPR", [])
	p[0].identifier = p[1]
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "integer"

def p_EXPR_string(p):
	'EXPR : string'
	p[0] = node("EXPR", [])
	p[0].identifier = p[1]
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "string"

def p_EXPR_true(p):
	'EXPR : true'
	p[0] = node("EXPR", [])
	p[0].identifier = "true"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "true"

def p_EXPR_false(p):
	'EXPR : false'
	p[0] = node("EXPR", [])
	p[0].identifier = "false"
	p[0].linenumber = p.lineno(1)
	p[0].subpart = "false"

# Dealing with recursive definitions in the CFG

def p_FEATUREPLUS(p):
	'FEATUREPLUS : FEATURE semi'
	p[0] = node("FEATUREPLUS", [p[1]])

def p_FEATUREPLUS_more(p):
	'FEATUREPLUS : FEATUREPLUS FEATURE semi'
	p[1].children.append(p[2])
	p[0] = node("FEATUREPLUS", p[1].children)

def p_FORMALPLUS(p):
	'FORMALPLUS : FORMAL'
	p[0] = node("FORMALPLUS", [p[1]])

def p_FORMALPLUS_more(p):
	'FORMALPLUS : FORMALPLUS comma FORMAL'
	p[1].children.append(p[3])
	p[0] = node("FORMALPLUS", p[1].children)

def p_EXPRPLUS(p):
	'EXPRPLUS : EXPR'
	p[0] = node("EXPRPLUS", [p[1]])
	p[0].linenumber = p.lineno(1)

def p_EXPRPLUS_more(p):
	'EXPRPLUS : EXPRPLUS comma EXPR'
	p[1].children.append(p[3])
	p[0] = node("EXPRPLUS", p[1].children)
	p[0].linenumber = p.lineno(1)

def p_EXPRSEMIPLUS(p):
	'EXPRSEMIPLUS : EXPR semi'
	p[0] = node("EXPRSEMIPLUS", [p[1]])
	p[0].linenumber = p.lineno(1)

def p_EXPRSEMIPLUS_more(p):
	'EXPRSEMIPLUS : EXPRSEMIPLUS EXPR semi'
	p[1].children.append(p[2])
	p[0] = node("EXPRSEMIPLUS", p[1].children)
	p[0].linenumber = p.lineno(1)

def p_IDTYPEEXPRPLUS_larrow(p):
	'IDTYPEEXPRPLUS : comma identifier colon type larrow EXPR'
	toappend = node("IDTYPEEXPRPLUS", [])
	toappend.identifier = ( p[2], p.lineno(2) )
	toappend.binding = "init"
	toappend.value = p[6]
	toappend.type2 = ( p[4], p.lineno(4) )
	toappend.linenumber = p.lineno(1)
	p[0] = node("IDTYPEEXPRPLUS", [toappend])
	p[0].linenumber = p.lineno(1)

def p_IDTYPEEXPRPLUS(p):
	'IDTYPEEXPRPLUS : comma identifier colon type'
	toappend = node("IDTYPEEXPRPLUS", [])
	toappend.identifier = ( p[2], p.lineno(2) )
	toappend.binding = "noinit"
	toappend.type2 = ( p[4], p.lineno(4) )
	toappend.linenumber = p.lineno(1)
	p[0] = node("IDTYPEEXPRPLUS", [toappend])
	p[0].linenumber = p.lineno(1)

def p_IDTYPEEXPRPLUS_larrow_more(p):
	'IDTYPEEXPRPLUS : IDTYPEEXPRPLUS comma identifier colon type larrow EXPR'
	toappend = node("IDTYPEEXPRPLUS", [])
	toappend.identifier = ( p[3], p.lineno(3) )
	toappend.binding = "init"
	toappend.value = p[7]
	toappend.type2 = ( p[5], p.lineno(5) )
	toappend.linenumber = p.lineno(1)
	p[1].children.append(toappend)
	p[0] = node("IDTYPEEXPRPLUS", p[1].children)
	p[0].linenumber = p.lineno(1)

def p_IDTYPEEXPRPLUS_more(p):
	'IDTYPEEXPRPLUS : IDTYPEEXPRPLUS comma identifier colon type'
	toappend = node("IDTYPEEXPRPLUS", [])
	toappend.identifier = ( p[3], p.lineno(3) )
	toappend.binding = "noinit"
	toappend.type2 = ( p[5], p.lineno(5) )
	toappend.linenumber = p.lineno(1)
	p[1].children.append(toappend)
	p[0] = node("IDTYPEEXPRPLUS", p[1].children)
	p[0].linenumber = p.lineno(1)

def p_IDTYPEARROWPLUS(p):
	'IDTYPEARROWPLUS : identifier colon type rarrow EXPR semi'
	toappend = node("IDTYPEARROWPLUS", [])
	toappend.variable = ( p[1], p.lineno(1) )
	toappend.type2 = ( p[3], p.lineno(3) )
	toappend.body = p[5]
	toappend.linenumber = p.lineno(1)
	p[0] = node("IDTYPEARROWPLUS", [toappend])
	p[0].linenumber = p.lineno(1)

def p_IDTYPEARROWPLUS_more(p):
	'IDTYPEARROWPLUS : IDTYPEARROWPLUS identifier colon type rarrow EXPR semi'
	toappend = node("IDTYPEARROWPLUS", [])
	toappend.variable = ( p[2], p.lineno(2) )
	toappend.type2 = ( p[4], p.lineno(4) )
	toappend.body = p[6]
	toappend.linenumber = p.lineno(1)
	p[1].children.append(toappend)
	p[0] = node("IDTYPEARROWPLUS", p[1].children)
	p[0].linenumber = p.lineno(1)

# Error rule for syntax errors

def p_error(p):
	print("ERROR: " + str(p.lineno) + ": Parser: " + str(p))
	exit()

if __name__ == "__main__":
	f = open(sys.argv[1], 'r')
	# Generate list of tokens
	readtokens = gentoks.readFile(f)
	lexer = lex()
	parser = yacc.yacc()
	# Parse using PLY
	root = parser.parse(readtokens, lexer, tracking=True)
	# If parse was succesful, output to cl-ast file
	if root != None:
		filename = sys.argv[1]
		f = open(filename[0:len(filename)-6]+"cl-ast", 'w')
		cerealize.output(root, f)