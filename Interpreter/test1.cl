class Aaa {
  x : Int <- 4;
  getx() : Int { x };
} ; 

class Bbb inherits Aaa {
} ; 

class Ccc inherits Bbb {
} ; 

class Main inherits IO{
  i : Int <- 2;
  x : Bbb <- new Bbb;
  main() : Object {
    {
      out_int((new Aaa).getx());
      out_int((new Bbb).getx());
      out_int((new Ccc).getx());
      if isvoid x then out_string("true") else out_string("false") fi;
      if not true then out_string("true") else out_string("false") fi;
      case x of
        a : Aaa => out_int(3);
        b : Bbb => out_int(6);
      esac;
      let x : Aaa <- new Ccc in {
        case x of
        a : Int => (new IO).out_string("a");
        b : Object => (new IO).out_string("e");
        c : Ccc => (new IO).out_string("b");
        esac;
      };
      out_int(i);
      case i of
        a : Object => 3;
        b : Int => b <- 4;
      esac;
      out_int(i);
      out_string("\n");
      case while false loop 1 pool of
        a : Object => 1;
        b : Int => 2;
      esac;
    }
  } ;
} ;
