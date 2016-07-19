class Main inherits IO {
	a : Int <- 1;
	b : Int <- 2;
	c : Int;
  d : Object;
  e : Object;
  main() : Object {
  	{
      out_int(c + 7);
      out_int(new Int + 5);
      out_int(new Int + new Int);
      if new Int < 5 then out_string("true\n") else out_string("false\n") fi;
      if b = a then out_string("true\n") else out_string("false\n") fi;
      if c <= b then out_string("true\n") else out_string("false\n") fi;
      if (c <- 1) = (c <- 2) then out_string("true\n") else out_string("false\n") fi;
      out_string(new Int.type_name());
      out_int(a);
      out_int(b);
      out_int(c);
      out_int(a <- (c <- 5) + (c <- 3));
      out_int(b <- (a <-1) + (a <-2 + b <- 3));
      out_int(a);
      out_int(b);
      out_int(c);
      out_string(a.type_name());
      out_string(5.type_name());
  		out_int(5 + 5);
      out_int(0-a);
      out_int(b*(0-1));
      out_int(b/(0-1));
      a <- b.copy();
      out_int(a);
      out_int(a.copy());
      out_string(a@Object.copy().type_name());
      out_int(a.copy() - b.copy());
      c <- a+b;
      out_int(c);
  	}
  };
};
