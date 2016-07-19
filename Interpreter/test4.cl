class Main inherits IO {
	aa:String;
	a:String;
	b:String;
	c:String;
	d:String;
	e:String;
	 x:String;
	 y:String;
	 z:String;
	 k:Int;
  main() : Object {
  	{
      out_string("1");
      aa <- "\"H\0\0\llo.\"\n";
      out_string(aa);
      out_int(aa.length());
      a <- "	a\"\"\\a\	taa";
      out_string(a);
      out_int(a.length());
      b <- "a\"\\"\n\t\a\ta\\a\\\\\a\n";
      out_string(b);
      out_int(b.length());
      c <- "";
      aa <- "";
      out_string(aa);
      out_int(aa.length());
      out_string(c);
      out_int(c.length());
      d <- "\n 019231098019708uoaoaioi";
      out_string(d);
      out_int(d.length());
      out_string(d.substr(0,1));
      out_string(d.substr(0,2));
      out_string(d.substr(3,2));
      out_string(d.substr(5,5));
      e <- "-- (*(  )  )  (a\"______\\___\"\\a\taa";
      out_string(e);
      out_int(e.length());
      out_string((new String).type_name());
      out_int((new String).type_name().length());
      out_string((new Main).type_name());
      out_int((new Main).type_name().length());
      out_string((new Int).type_name());
      out_int((new Int).type_name().length());
      out_string((new IO).type_name());
      out_int((new IO).type_name().length());
      out_string((new Bool).type_name());
      out_int((new Bool).type_name().length());
      out_string("\n");
      out_int("\n".length());
      out_string(x.type_name());
      out_int(x.type_name().length());
      out_string(out_string(x.type_name()).type_name());
      out_string(self@IO.out_string(x.type_name()).type_name());
      out_string((new IO).out_string(x.type_name()).type_name());
      out_string("\n");
      out_string(x.concat(x.type_name()));
      out_string(x.type_name().concat(x.type_name()));
      out_string("\n");
      out_string(k.type_name().concat(x.type_name().concat("")).concat("\"\"\"\""));
      out_string("\n");
      out_string(z.type_name().concat(z));
      z <- "lfkjsaaasdflkajeffl\\\"kajeflkajslfkjaselfkjlkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkjaselfkjsaaasdflkajeflkajslfkj".concat("aeslfjalil098qwho hefowqh;oqinq4\t\t\t\t\n\n\n\n\n\0\0\0\\\\jlijlij la\"\"\ijs liajs elia a                              ");
      out_string(z);
      z.substr(z.length(),1);
  	}
  } ;
} ; 
