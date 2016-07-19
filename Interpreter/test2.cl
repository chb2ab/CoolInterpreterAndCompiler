class Aaa{
	x : Int;
	ret_self() : SELF_TYPE {
		self
	} ;
	out() : String {
		"aaaa"
	} ;
	get_x() : Int {
		x
	} ;
	assign_x(o : Int) : Int {
		x <- o
	} ;
	concat_after(s : String) : String {
		"A".concat(s)
	} ;
} ; 

class Bbb inherits Aaa{
	b : Int;
	return_a(a : Int, b : Int, c : Int) : Int { 
		b
	} ;
	concat_after(s : String) : String {
		"B".concat(s)
	} ;
	out() : String {
		"bbbb"
	} ;
} ; 

class Main inherits IO {
		a : Aaa;
		b : Aaa;
		c : Int;
		d : Bbb;
	test(a : Int, b : Int, c : Int, d : Int) : Object {
		1
	};
	main() : Object {
		{
			a <- new Aaa;
			b <- a.copy();
			out_string(b.out());
			b.assign_x(5);
			out_int(a.get_x());
			out_string(b.concat_after("here"));
			out_string("\n");
			b <- new Bbb;
			out_string((b.ret_self()).type_name());
			out_string("\n");
			({out_string("aaa\n"); new SELF_TYPE;}).test({out_int(1);1;},{out_int(2);2;},{out_int(3);3;},{out_int(4);4;});
			out_string((a <- new Bbb)@Aaa.concat_after("eeek"));
			out_string((a <- new Bbb)@Bbb.concat_after("eeek"));
			d.out();
		}
	};
};