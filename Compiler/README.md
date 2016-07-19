#Compiler
Cool reference manual can be found here: <a src="http://dijkstra.cs.virginia.edu/ldi/cool-manual/cool-manual.html">http://dijkstra.cs.virginia.edu/ldi/cool-manual/cool-manual.html</a>

X86 Compiler written for Programming Languages class

###Compiler
- Optimizing Cool compiler
- Targets X86 instruction architecture
- Takes an annotated abstract syntax tree as input and produces an x86 file, which can then be linked into an executable
- Written Python 2.7

###Using the compiler
1. Use the provided cool interpreter to generate an AST from one the cool test cases (.cl files), this can be done with <code>$ ./cool test1.cl --type</code> and will generate a test1.cl-type file
2. Then use the command <code>$ python main.py test1.cl-type</code> to produce a test1.s file with x86 assembly code.
3. Then use the command <code>$ gcc test1.s</code> to produce an executable file a.out
4. Finally run the executable with <code>$ ./a.out</code>
The provided cool interpreter can be used to compare outputs with using the command <code>$ ./cool test1.ck</code>