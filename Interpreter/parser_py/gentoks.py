# Custom token class.
class LexToken(object):
    def __str__(self):
        return 'LexToken(%s,%r,%d,%d)' % (self.type, self.value, self.lineno, self.lexpos)

    def __repr__(self):
        return str(self)
# Read in the PA2 output and generate a list of tokens
def readFile(f):
	tokens = []
	lineno = 0
	pos = 0
	for line in f:
		if line == "":
			continue
		newtok = LexToken()
		newtok.lineno = int(line.rstrip())
		if newtok.lineno > lineno:
			pos = 0
			lineno = newtok.lineno
		newtok.type = f.next().rstrip()
		if newtok.type == "string":
			newtok.value = f.next()[:-1]
			newtok.lexpos = pos
			pos += len(newtok.value) + 3
		elif newtok.type == "at":
			newtok.value = "@"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "case":
			newtok.value = "case"
			newtok.lexpos = pos
			pos += 5
		elif newtok.type == "class":
			newtok.value = "class"
			newtok.lexpos = pos
			pos += 6
		elif newtok.type == "rarrow":
			newtok.value = "=>"
			newtok.lexpos = pos
			pos += 3
		elif newtok.type == "le":
			newtok.value = "<="
			newtok.lexpos = pos
			pos += 3
		elif newtok.type == "colon":
			newtok.value = ":"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "comma":
			newtok.value = ","
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "divide":
			newtok.value = "/"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "dot":
			newtok.value = "."
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "else":
			newtok.value = "else"
			newtok.lexpos = pos
			pos += 5
		elif newtok.type == "equals":
			newtok.value = "="
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "esac":
			newtok.value = "esac"
			newtok.lexpos = pos
			pos += 5
		elif newtok.type == "false":
			newtok.value = "false"
			newtok.lexpos = pos
			pos += 6
		elif newtok.type == "fi":
			newtok.value = "fi"
			newtok.lexpos = pos
			pos += 3
		elif newtok.type == "if":
			newtok.value = "if"
			newtok.lexpos = pos
			pos += 3
		elif newtok.type == "in":
			newtok.value = "in"
			newtok.lexpos = pos
			pos += 3
		elif newtok.type == "inherits":
			newtok.value = "inherits"
			newtok.lexpos = pos
			pos += 9
		elif newtok.type == "integer":
			int_as_str = f.next().rstrip()
			newtok.value = int(int_as_str)
			newtok.lexpos = pos
			pos += len(int_as_str) + 1
		elif newtok.type == "isvoid":
			newtok.value = "isvoid"
			newtok.lexpos = pos
			pos += 7
		elif newtok.type == "larrow":
			newtok.value = "<-"
			newtok.lexpos = pos
			pos += 3
		elif newtok.type == "lbrace":
			newtok.value = "{"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "let":
			newtok.value = "let"
			newtok.lexpos = pos
			pos += 4
		elif newtok.type == "loop":
			newtok.value = "loop"
			newtok.lexpos = pos
			pos += 5
		elif newtok.type == "lparen":
			newtok.value = "("
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "lt":
			newtok.value = "<"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "minus":
			newtok.value = "-"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "new":
			newtok.value = "new"
			newtok.lexpos = pos
			pos += 4
		elif newtok.type == "not":
			newtok.value = "not"
			newtok.lexpos = pos
			pos += 4
		elif newtok.type == "of":
			newtok.value = "of"
			newtok.lexpos = pos
			pos += 3
		elif newtok.type == "plus":
			newtok.value = "+"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "pool":
			newtok.value = "pool"
			newtok.lexpos = pos
			pos += 5
		elif newtok.type == "rbrace":
			newtok.value = "}"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "rparen":
			newtok.value = ")"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "semi":
			newtok.value = ";"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "then":
			newtok.value = "then"
			newtok.lexpos = pos
			pos += 5
		elif newtok.type == "tilde":
			newtok.value = "~"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "times":
			newtok.value = "*"
			newtok.lexpos = pos
			pos += 2
		elif newtok.type == "true":
			newtok.value = "true"
			newtok.lexpos = pos
			pos += 5
		elif newtok.type == "while":
			newtok.value = "while"
			newtok.lexpos = pos
			pos += 6
		elif newtok.type == "type":
			newtok.value = f.next().rstrip()
			newtok.lexpos = pos
			pos += len(newtok.value) + 1
		elif newtok.type == "identifier":
			newtok.value = f.next().rstrip()
			newtok.lexpos = pos
			pos += len(newtok.value) + 1
		tokens.append(newtok)
	return tokens