class Aaa{
	x : Aaa;
	aaaa(x : Int, y : String) : Object { 
		1
	};
	out() : String {
		"aaaa"
	};
}; 

class Bbb inherits Aaa{
	b : Int;
	return_a(a : Int, b : Int, c : Int) : Int { 
		b
	} ;
	concat_after(s : String) : String {
		"aaaa".concat(s)
	} ;
	out() : String {
		"bbbb"
	};
}; 

class Main inherits IO {
	a : Bbb;
	b : Aaa;
	c : Int <- 5;
	d : Int <- 10;
	s : String <- "bobooooo";
	x : Int;
	f : Object;
	g : Object;
	main() : Object {
		{
			f <- 5;
			g <- 5;
			if f = g then out_string("true") else out_string("false") fi;
			f <- 5;
			g <- "asfs";
			if f = g then out_string("true") else out_string("false") fi;
			f <- true;
			g <- true;
			if f = g then out_string("true") else out_string("false") fi;
			f <- false;
			g <- "boo";
			if f = g then out_string("true") else out_string("false") fi;
			while c < 10 loop {out_int(c); c <- c+1;} pool;
			let
			a : Int,
			b : Int,
			c : Int in {
				out_int( a-b+c*x/d );
				out_int( a+4/5-b/6+3*c*x/d );
				out_int( (c<-3)+(c<-4) );
				out_int( (c<-3+(a<-0-1)+b<-0-2)+(c<-4+(a<-6)+b<-5) );
				out_int( (c<-3*(a<-1)/b<-2)*(c<-4-(a<-0-6)+b<-5) );
			};
			if 5 <= 5 then out_string("true") else out_string("false") fi;
			if false <= true then out_string("true") else out_string("false") fi;
			if "tests" < "tests" then out_string("true") else out_string("false") fi;
			if "tests" = "tests" then out_string("true") else out_string("false") fi;
			if new Bbb < new Aaa then out_string("true") else out_string("false") fi;
			if new Aaa < new Bbb then out_string("true") else out_string("false") fi;
			if new Aaa = new Aaa then out_string("true") else out_string("false") fi;
			b <- if true then
			new Aaa
			else
			new Bbb
			fi;
			out_string(b.out());
			if b = b then out_string("true") else out_string("false") fi;
			b <- if false then
			new Aaa
			else
			new Bbb
			fi;
			out_string(b.out());
			abort();
		}
	};
};