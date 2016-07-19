#Interpreter
Cool reference manual can be found here: <a src="http://dijkstra.cs.virginia.edu/ldi/cool-manual/cool-manual.html">http://dijkstra.cs.virginia.edu/ldi/cool-manual/cool-manual.html</a>

Cool Interpreter written for Programming Languages class

###Interpreter
- Performs lexical analysis, parsing, semantic analysis, and interpreting on Cool programs
- The interpreter is written in Javascript and uses the jison Javascript lexical analyzer generator. It takes a Cool program as input and outputs a serialized list of Cool tokens.
- Parser is written in Python and uses the ply Python parser analyzer generator. It takes a serialized list of Cool tokens as input and outputs a serialized Cool abstract syntax tree.
- Semantic analyzer is written in Haskell. Takes a serialized Cool abstract syntax tree as input and outputs an annotated abstract syntax tree.
- Interpreter is written in Ocaml. Takes a AAST as input and outputs the output of the program.
