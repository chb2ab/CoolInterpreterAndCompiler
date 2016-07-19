class Main inherits IO {
	a : Bool <- true;
	b : Bool <- false;
	c : Bool;
  d : Object;
  e : Object;
  main() : Object {
  	{
      if a then out_string("true\n") else out_string("false\n") fi;
      if b then out_string("true\n") else out_string("false\n") fi;
      if c then out_string("true\n") else out_string("false\n") fi;
      if b < a then out_string("true\n") else out_string("false\n") fi;
      if a <- true = a <- false then out_string("true\n") else out_string("false\n") fi;
      if true < false then out_string("true\n") else out_string("false\n") fi;
      if new Bool <= new Bool then out_string("true\n") else out_string("false\n") fi;
      if new Bool < true then out_string("true\n") else out_string("false\n") fi;
      if not c then out_string("true\n") else out_string("false\n") fi;
      out_string(true.type_name());
      out_string(new Bool.type_name());
      d <- not new Bool;
      e <- false;
      out_string(d.type_name());
      out_string(e.type_name());
      out_string(d@Object.copy().type_name());
  	}
  };
};
