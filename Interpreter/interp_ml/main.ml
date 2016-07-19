open GetMaps

(* Representation of an object, has a type string, void indicator (true if void), mapping of attribute names to their registers, and a unique store identifier for each object *)
type objekt = { typ : string; void : bool; attrs : string Stringmap.t; storeloc : int }

(* Open type file and read in the different maps *)
let chan : in_channel = open_in Sys.argv.(1)
let class_map : attribute list Stringmap.t = get_class_map chan (* map from type to list of attributes *)
let implementation_map :(immethod Stringmap.t) Stringmap.t = get_implementation_map chan (* map from type to map of methods *)
let parent_map : string Stringmap.t = get_parent_map chan (* map from type to parent *)
(* The store maps from registers to the object in that register *)
let store : objekt Stringmap.t ref = ref Stringmap.empty
(* new register incrementer *)
let reg_counter : int ref = ref 0
(* store incrementor for new objects *)
let store_counter : int ref = ref 0
(* incrementor for new stack frames *)
let stack_counter : int ref = ref 0

(* increment global register counter and return a new register *)
let new_register () : string =
  ignore (reg_counter := !reg_counter+1);
  string_of_int !reg_counter

(* increment global store counter and return a new store *)
let new_store () : int =
  ignore (store_counter := !store_counter+1);
  !store_counter

(* increment global stack counter *)
let new_stack () : int =
  ignore (stack_counter := !stack_counter+1);
  !stack_counter

(* decrement global stack counter *)
let decr_stack () : int =
  ignore (stack_counter := !stack_counter-1);
  !stack_counter

(* convert string character by character into proper outputting format *)
let rec convert_string_guts (ind : int) (str : string) : string list = 
  if ind >= String.length str then []
  else (
    let chari : char = str.[ind] in
    if chari = '\\' && ind+1 < String.length str  then (
      let chari2 : char = str.[ind+1] in
      if chari2 = 'n' then String.make 1 '\n' :: convert_string_guts (ind+2) str
      else if chari2 = 't' then String.make 1 '\t' :: convert_string_guts (ind+2) str
      else String.make 1 chari :: convert_string_guts (ind+1) str 
    )
    else  String.make 1 chari :: convert_string_guts (ind+1) str
  )

(* convert string into correct format for outputting, namely converting \n to newlines and such *)
let convert_string (str : string) : string =
  String.concat "" (convert_string_guts 0 str)

(* check if the input string has the null character in it and return a null if it does *)
let check_instring (str : string) : string =
  try (
    ignore (String.index str (Char.chr 0));
    "")
  with Not_found -> str

(* trim out leading whitespace from the string *)
let rec trim (ind : int) (str : string) : string =
  if ind >= String.length str then ""
  else (let chari : char = str.[ind] in match chari with
    | ' ' | '\n' | '\x12' | '\r' | '\t' | '\x11' -> trim (ind+1) str
    | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' -> String.sub str ind ((String.length str)-ind)
    | '-' -> ( if ind+1 < String.length str then
      let chari2 : char = str.[ind+1] in match chari2 with
      | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' -> String.sub str ind ((String.length str)-ind)
      | _ -> ""
      else "")
    | _ -> "")

(* extract the leading digits from the input string and ignoring trailing characters *)
let rec get_dig (ind : int) (str : string) : string =
  if ind >= String.length str then str
  else (let chari : char = str.[ind]  in match chari with
    | '0' when ind = 0 || (ind = 1 && str.[0] = '-') -> String.sub str 0 (ind+1)
    | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' -> get_dig (ind+1) str
    | '-' when ind = 0 -> get_dig (ind+1) str
    | _ -> String.sub str 0 ind
  )

(* check input integer if it is valid *)
let rec check_inint_guts (ind : int) (str : string) : string =
  let trimmed : string = trim 0 str in
  if trimmed = "" then "0"
  else (
    let dig : string = get_dig 0 trimmed in
    try (
      let dig_int : int = int_of_string dig in
      if dig_int > 2147483647 || dig_int < -2147483648 then "0"
      else string_of_int dig_int)
    with Failure "int_of_string" -> "0")

(* check input integer and return integer in string format *)
let check_inint (str : string) : string =
  check_inint_guts 0 str

(* check how many stack frames are allocated, print error message if there are too many *)
let check_stackof (ln : string) : string =
  if new_stack () > 1000 then (
    print_endline (String.concat "" ["ERROR: ";ln;": Exception: exception, stack overflow"]);
    exit 0;)
  else "ok"

(* given an object to perform a case on, find the appropriate case branch to take by walking up the parent map and comparing to all the case branch types *)
let rec decide_case (casetype : string) (caseelements : caseelement list) : caseelement =
  try List.find (fun (_,typ,_) -> typ = casetype) caseelements
  with Not_found -> (
  if casetype = "Object" then
    raise Not_found
  else decide_case (Stringmap.find casetype parent_map) caseelements)

(* execute an expression given the current self object, current environment, and the expression to execute. All expressions return some type of object *)
let rec execute_expression (self_object : objekt) (environment : string Stringmap.t) (expr : expression) : objekt = match expr with
(* execute the right hand side expression and update the store so that the register for the identifier points to the new object *)
| Eassign (_,_,ident,rhs) ->
  let myexp : objekt = execute_expression self_object environment rhs in
  let temp : string = Stringmap.find ident environment in
  store := Stringmap.add temp myexp !store;
  myexp

| Edyndisp (ln,_,e,meth,args) ->
  (* check for stack overflow *)
  ignore (check_stackof ln);
  (* evaluate each formal and allocate a new register for it *)
  let arg_regs : string list = List.fold_left (fun arg_regs expr ->
      let temp : string = new_register () in
      let regobj : objekt = execute_expression self_object environment expr in
      ignore (store := Stringmap.add temp regobj !store);
      arg_regs@[temp]) [] args in
  (* evaluate the dispatch object *)
  let myexp : objekt = execute_expression self_object environment e in
  if (myexp.void) then (
    print_endline (String.concat "" ["ERROR: ";ln;": Exception: eXcEpTiOn, void dispatch"]);
    exit 0;)
  else (
    (* dispatch the method *)
    let retval : objekt = execute_method myexp myexp.typ meth arg_regs in
    (* restore selftype after dispatch *)
    ignore (store := Stringmap.add "self" self_object !store);
    ignore (decr_stack ());
    retval)

(* basically dynamic dispatch but execute method from the specified class type *)
| Estatdisp (ln,_,e,typ,meth,args) ->
  (* check for stack overflow *)
  ignore (check_stackof ln);
  (* evaluate each formal and allocate a new register for it *)
  let arg_regs : string list = List.fold_left (fun arg_regs expr ->
    let temp : string = new_register () in
    let regobj : objekt = execute_expression self_object environment expr in
    ignore (store := Stringmap.add temp regobj !store);
    arg_regs@[temp]) [] args in
  (* evaluate the dispatch object *)
  let myexp : objekt = execute_expression self_object environment e in
  if (myexp.void) then (
    print_endline (String.concat "" ["ERROR: ";ln;": Exception: ExCePtIoN, [[[[[[[[[[[[[:::::::::::--<>><><[[[[[[[[[[[[[[[[[[[static void dispatch]"]);
    exit 0;)
  else (
    (* dispatch the method *)
    let retval : objekt = execute_method myexp typ meth arg_regs in
    (* restore selftype after dispatch *)
    ignore (store := Stringmap.add "self" self_object !store);
    ignore (decr_stack ());
    retval)

| Eselfdisp (ln,_,meth,args) ->
  (* check for stack overflow *)
  ignore (check_stackof ln);
  (* evaluate each formal and allocate a new register for it *)
  let arg_regs : string list = List.fold_left (fun arg_regs expr ->
    let temp : string = new_register () in
    let regobj : objekt = execute_expression self_object environment expr in
    ignore (store := Stringmap.add temp regobj !store);
    arg_regs@[temp]) [] args in
  (* dispatch the method *)
  let retval : objekt = execute_method self_object self_object.typ meth arg_regs in
  (* restore selftype after dispatch *)
  ignore (store := Stringmap.add "self" self_object !store);
  ignore (decr_stack ());
  retval

(* evaluate the predicate, check if its attribute is set to true or false, and then execute the appropriate expression *)
| Eif (_,_,predicate,thenn,els) ->
  let predobj : objekt = execute_expression self_object environment predicate in
  if (Stringmap.find "Bval" predobj.attrs) = "true" then
    execute_expression self_object environment thenn
  else execute_expression self_object environment els

(* evaluate the predicate and return void if false or execute the body and recurse if ftrue *)
| Ewhile (_,_,condition,body) ->
  let condobj : objekt = execute_expression self_object environment condition in
  if (Stringmap.find "Bval" condobj.attrs) = "true" then (
    ignore (execute_expression self_object environment body);
    execute_expression self_object environment expr)
  else {typ = "void"; void = true; attrs = Stringmap.empty; storeloc = 0}

(* execute each expression in the block in order *)
| Eblock (_,_,exprs) ->
  List.fold_left (fun _ e -> execute_expression self_object environment e) {typ = "void"; void = true; attrs = Stringmap.empty; storeloc = 0} exprs

(* make a new object of the requested type *)
| Enew (ln,_,ntyp) ->
  (* check for stack overflow *)
  ignore (check_stackof ln);
  (match ntyp with
    (* built in types have their own initializers *)
  | "String" ->
    {typ = "String"; void = false; attrs = Stringmap.add "Sval" "" Stringmap.empty; storeloc = new_store ()}
  | "Int" ->
    {typ = "Int"; void = false; attrs = Stringmap.add "Ival" "0" Stringmap.empty; storeloc = new_store ()}
  | "Bool" ->
    {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | _ ->
    let ntyp : string = (if ntyp = "SELF_TYPE" then self_object.typ else ntyp) in
    (* get the list of attributes from the class map*)
    let attrs : attribute list = Stringmap.find ntyp class_map in
    (* Initialize all attributes with a new register set to default for that type *)
    let newenv : string Stringmap.t = List.fold_left 
      (fun env atr -> 
        let (name, typ) = (match atr with
        | AttrInit (_,name,typ,_) -> (name,typ)
        | AttrNoInit (_,name,typ) -> (name,typ)) in
        let typ : string = (if typ = "SELF_TYPE" then ntyp else typ) in
        let temp : string = new_register () in
        if typ = "Int" then(
          ignore (store := Stringmap.add temp {typ = "Int"; void = false; attrs = Stringmap.add "Ival" "0" Stringmap.empty; storeloc = new_store ()} !store);
          Stringmap.add name temp env)
        else if typ = "Bool" then(
          ignore (store := Stringmap.add temp {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()} !store);
          Stringmap.add name temp env)
        else if typ = "String" then(
          ignore (store := Stringmap.add temp {typ = "String"; void = false; attrs = Stringmap.add "Sval" "" Stringmap.empty; storeloc = new_store ()} !store);
          Stringmap.add name temp env)
        else(
          ignore (store := Stringmap.add temp {typ = typ; void = true; attrs = Stringmap.empty; storeloc = 0} !store);
          Stringmap.add name temp env)
        ) Stringmap.empty attrs in
    (* create the new object *)
    let newobj : objekt = {typ = ntyp; void = false; attrs = newenv; storeloc = new_store ()} in
    let newenv : string Stringmap.t = Stringmap.add "self" "self" newenv in
    ignore (store := Stringmap.add "self" newobj !store);
    (* evaluate attributes with initializers. self in an initializier refers to the new object *)
    ignore (List.fold_left (fun _ atr ->
      match atr with
      | AttrInit (_,name,_,expr) ->
        let attrobj : objekt = execute_expression newobj newenv expr in
        ignore (store := Stringmap.add (Stringmap.find name newenv) attrobj !store)
      | AttrNoInit (_,_,_)  -> ()) () attrs);
    (* restore self after initializing the attributes *)
    ignore (store := Stringmap.add "self" self_object !store);
    ignore (decr_stack ());
    (* return the new object *)
    newobj)

(* evaluate the body and returna  new boolean object indicating if it was void or not *)
| Eisvoid (_,_,body) ->
  let obj : objekt = execute_expression self_object environment body in
  if obj.void then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
  else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}

(* evaluate left and right hand sides, convert to 32 bit integers, return a new integer with their sum *)
| Eplus (_,_,lhs,rhs) ->
  let lobj : objekt = execute_expression self_object environment lhs in
  let lval : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" lobj.attrs)) in
  let robj : objekt = execute_expression self_object environment rhs in
  let rval : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" robj.attrs)) in
  {typ = "Int"; void = false; attrs = Stringmap.add "Ival" (string_of_int (Int32.to_int (Int32.add lval rval))) Stringmap.empty; storeloc = new_store ()}

(* evaluate left and right hand sides, convert to 32 bit integers, return a new integer with their difference *)
| Eminus (_,_,lhs,rhs) ->
  let lobj : objekt = execute_expression self_object environment lhs in
  let lval : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" lobj.attrs)) in
  let robj : objekt = execute_expression self_object environment rhs in
  let rval : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" robj.attrs)) in
  {typ = "Int"; void = false; attrs = Stringmap.add "Ival" (string_of_int (Int32.to_int (Int32.sub lval rval))) Stringmap.empty; storeloc = new_store ()}

(* evaluate left and right hand sides, convert to 32 bit integers, return a new integer with their product *)
| Etimes (_,_,lhs,rhs) ->
  let lobj : objekt = execute_expression self_object environment lhs in
  let lval : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" lobj.attrs)) in
  let robj : objekt = execute_expression self_object environment rhs in
  let rval : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" robj.attrs)) in
  {typ = "Int"; void = false; attrs = Stringmap.add "Ival" (string_of_int (Int32.to_int (Int32.mul lval rval))) Stringmap.empty; storeloc = new_store ()}

(* evaluate left and right hand sides, convert to 32 bit integers, return a new integer with their division *)
| Edivide (ln,_,lhs,rhs) ->
  let lobj : objekt = execute_expression self_object environment lhs in
  let lval : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" lobj.attrs)) in
  let robj : objekt = execute_expression self_object environment rhs in
  if (Stringmap.find "Ival" robj.attrs = "0") then (
    print_endline (String.concat "" ["ERROR: ";ln;": Exception: 1/0 = exception"]);
    exit 0;)
  else (
    let rval : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" robj.attrs)) in
    {typ = "Int"; void = false; attrs = Stringmap.add "Ival" (string_of_int (Int32.to_int (Int32.div lval rval))) Stringmap.empty; storeloc = new_store ()})

(* evaluate left and right hand sides and compare using the appropriate type comparison rules *)
| Elt (_,_,lhs,rhs) ->
  let lobj : objekt = execute_expression self_object environment lhs in
  let robj : objekt = execute_expression self_object environment rhs in
  (match (lobj.typ, robj.typ) with
  | "Int", "Int" ->
    let lval : int = int_of_string (Stringmap.find "Ival" lobj.attrs) in
    let rval : int = int_of_string (Stringmap.find "Ival" robj.attrs) in
    if lval < rval then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | "String", "String" ->
    let lval : string = Stringmap.find "Sval" lobj.attrs in
    let rval : string = Stringmap.find "Sval" robj.attrs in
    if String.compare lval rval < 0 then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | "Bool", "Bool" ->
    let lval : string = Stringmap.find "Bval" lobj.attrs in
    let rval : string = Stringmap.find "Bval" robj.attrs in
    let lval : int = (if lval = "true" then 1 else 0) in
    let rval : int = (if rval = "true" then 1 else 0) in
    if lval < rval then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | _ ->
    {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()})

(* evaluate left and right hand sides and compare using the appropriate type comparison *)
| Ele (_,_,lhs,rhs) ->
  let lobj : objekt = execute_expression self_object environment lhs in
  let robj : objekt = execute_expression self_object environment rhs in
  (match (lobj.typ, robj.typ) with
  | "Int", "Int" ->
    let lval : int = int_of_string (Stringmap.find "Ival" lobj.attrs) in
    let rval : int = int_of_string (Stringmap.find "Ival" robj.attrs) in
    if lval <= rval then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | "String", "String" ->
    let lval : string = Stringmap.find "Sval" lobj.attrs in
    let rval : string = Stringmap.find "Sval" robj.attrs in
    if String.compare lval rval <= 0 then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | "Bool", "Bool" ->
    let lval : string = Stringmap.find "Bval" lobj.attrs in
    let rval : string = Stringmap.find "Bval" robj.attrs in
    let lval : int = (if lval = "true" then 1 else 0) in
    let rval : int = (if rval = "true" then 1 else 0) in
    if lval <= rval then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | _ ->
    if ((not lobj.void) && (not robj.void)) then (
      if lobj.storeloc = robj.storeloc then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
      else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()})
    else (if lobj.void && robj.void then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
      else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}))

(* evaluate left and right hand sides and compare using the appropriate type comparison *)
| Eeq (_,_,lhs,rhs) ->
  let lobj : objekt = execute_expression self_object environment lhs in
  let robj : objekt = execute_expression self_object environment rhs in
  (match (lobj.typ, robj.typ) with
  | "Int", "Int" ->
    let lval : int = int_of_string (Stringmap.find "Ival" lobj.attrs) in
    let rval : int = int_of_string (Stringmap.find "Ival" robj.attrs) in
    if lval = rval then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | "String", "String" ->
    let lval : string = Stringmap.find "Sval" lobj.attrs in
    let rval : string = Stringmap.find "Sval" robj.attrs in
    if lval = rval then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | "Bool", "Bool" ->
    let lval : string = Stringmap.find "Bval" lobj.attrs in
    let rval : string = Stringmap.find "Bval" robj.attrs in
    if lval = rval then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
    else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  | _ ->
    if ((not lobj.void) && (not robj.void)) then (
      if lobj.storeloc = robj.storeloc then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
      else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()})
    else (if lobj.void && robj.void then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}
      else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}))

(* evaluate the body and return a boolean with the opposite value *)
| Enot (_,_,body) ->
  let obj : objekt = execute_expression self_object environment body in
  if (Stringmap.find "Bval" obj.attrs) = "true" then {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
  else {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}

(* evaluate the body and return an integer with the negative value *)
| Enegate (_,_,body) ->
  let obj : objekt = execute_expression self_object environment body in
  let vall : int32 = Int32.of_int (int_of_string (Stringmap.find "Ival" obj.attrs)) in
  {typ = "Int"; void = false; attrs = Stringmap.add "Ival" (string_of_int (Int32.to_int (Int32.neg vall))) Stringmap.empty; storeloc = new_store ()}

(* return a new integer object with constants value stored in attribute Ival as a string *)
| Einteger (_,_,const) ->
  {typ = "Int"; void = false; attrs = Stringmap.add "Ival" const Stringmap.empty; storeloc = new_store ()}

(* return a new string object with constants value stored in attribute Sval *)
| Estring (_,_,const) ->
  {typ = "String"; void = false; attrs = Stringmap.add "Sval" const Stringmap.empty; storeloc = new_store ()}

(* look up the identifiers register in the environment, then look up the object stored in that register in the store and return it *)
| Eident (_,_,ident) ->
  Stringmap.find (Stringmap.find ident environment) !store

(* return a new boolean object with "true" stored in attribute Bval *)
| Etrue (_,_) ->
  {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "true" Stringmap.empty; storeloc = new_store ()}

(* return a new boolean object with "false" stored in attribute Bval *)
| Efalse (_,_) ->
  {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}

(* recursively evaluate let expression, adding bindings if there are any left to add before evaluating the body *)
| Elet (ln,atyp,bindings,body) ->
  (match bindings with
    (* If there are no more bindings in the binding list, evaluate the body *)
  | [] -> execute_expression self_object environment body
  | (x::xs) ->
    (* If there are bindings left, evaluate them and recurse with 1 less binding*)
    (match x with
    | Bindingnoinit (ident,typ) ->
      let typ : string = (if typ = "SELF_TYPE" then self_object.typ else typ) in
      let nr : string = new_register () in
      (* update environment so identifier goes to a new register *)
      let newenv : string Stringmap.t = Stringmap.add ident nr environment in
      let newobj : objekt = (match typ with
        | "Int" -> {typ = "Int"; void = false; attrs = Stringmap.add "Ival" "0" Stringmap.empty; storeloc = new_store ()}
        | "String" -> {typ = "String"; void = false; attrs = Stringmap.add "Sval" "" Stringmap.empty; storeloc = new_store ()}
        | "Bool" -> {typ = "Bool"; void = false; attrs = Stringmap.add "Bval" "false" Stringmap.empty; storeloc = new_store ()}
        | _ -> {typ = typ; void = true; attrs = Stringmap.empty; storeloc = 0}) in
      (* update store so register goes to default object*)
      ignore (store := Stringmap.add nr newobj !store);
      execute_expression self_object newenv (Elet (ln,atyp,xs,body))
    | Bindinginit (ident,_,expr) ->
      let newobj : objekt = execute_expression self_object environment expr in
      let nr : string = new_register () in
      (* update environment so identifier goes to a new register *)
      let newenv : string Stringmap.t = Stringmap.add ident nr environment in
      (* update store so register goes to initialized object*)
      ignore (store := Stringmap.add nr newobj !store);
      execute_expression self_object newenv (Elet (ln,atyp,xs,body)) ))

| Ecase (ln,_,cas,elements) ->
  (* evaluate the case object *)
  let casobj : objekt = execute_expression self_object environment cas in
  if casobj.void then (
    print_endline (String.concat "" ["ERROR: ";ln;": Exception: case voidbiov esac"]);
    exit 0;)
  else (
    (* if the case object was nonvoid try to decide a case branch *)
    (try (let (ident,_,body) = decide_case casobj.typ elements in
      let nr : string = new_register () in
      (* bind the case branch variable and execute the body*)
      let newenv : string Stringmap.t = Stringmap.add ident nr environment in
      ignore (store := Stringmap.add nr casobj !store);
      execute_expression self_object newenv body)
    with Not_found -> 
      print_endline (String.concat "" ["ERROR: ";ln;": Exception: eee--casebranchnotfounde--ee"]);
      exit 0;))

(* internal methods have their implementations defined here *)
| Einternal (_,_,meth) ->
  match meth with
  | "Object.abort" ->
    print_endline "abort";
    exit 0;
  | "Object.copy" ->
    let attrs : attribute list = Stringmap.find self_object.typ class_map in
    (* copy attributes of self_object into a new object *)
    let newenv : string Stringmap.t = List.fold_left 
      (fun env atr -> 
        let (name, typ) = (match atr with
        | AttrInit (_,name,typ,_) -> (name,typ)
        | AttrNoInit (_,name,typ) -> (name,typ)) in
        let temp : string = new_register () in
        let copyval : objekt = Stringmap.find (Stringmap.find name self_object.attrs) !store in 
        ignore (store := Stringmap.add temp copyval !store);
        Stringmap.add name temp env) Stringmap.empty attrs in
    {typ = self_object.typ; void = false; attrs = newenv; storeloc = new_store ()}
  | "Object.type_name" ->
    {typ = "String"; void = false; attrs = Stringmap.add "Sval" (self_object.typ) Stringmap.empty; storeloc = new_store ()}
  | "IO.in_int" ->
    let inint : string = try (input_line stdin)
    with End_of_file -> "0" in
    let inint : string = check_inint inint in
    {typ = "Int"; void = false; attrs = Stringmap.add "Ival" inint Stringmap.empty; storeloc = new_store ()}
  | "IO.in_string" ->
    let instr : string = try (input_line stdin)
    with End_of_file -> ""  in
    let instr : string = check_instring instr in
    {typ = "String"; void = false; attrs = Stringmap.add "Sval" instr Stringmap.empty; storeloc = new_store ()}
  | "IO.out_int" ->
    let intobj : objekt = Stringmap.find (Stringmap.find "x" environment) !store in
    let int_to_print : string = Stringmap.find "Ival" intobj.attrs in
    Printf.printf "%s" int_to_print;
    flush stdout;
    self_object
  | "IO.out_string" ->
    let strobj : objekt = Stringmap.find (Stringmap.find "x" environment) !store in
    let str_to_print : string = Stringmap.find "Sval" strobj.attrs in
    let str_to_print : string = convert_string str_to_print in
    Printf.printf "%s" str_to_print;
    flush stdout;
    self_object
  | "String.concat" ->
    let str1 : string = Stringmap.find "Sval" self_object.attrs in
    (* formal name for string to concat is "s" *)
    let strobj2 : objekt = Stringmap.find (Stringmap.find "s" environment) !store in
    let str2 : string = Stringmap.find "Sval" strobj2.attrs in
    let strconcat : string = String.concat "" [str1; str2] in
    {typ = "String"; void = false; attrs = Stringmap.add "Sval" strconcat Stringmap.empty; storeloc = new_store ()}
  | "String.length" ->
    let str1 : string = Stringmap.find "Sval" self_object.attrs in
    let strlength : string = string_of_int (String.length str1) in
    {typ = "Int"; void = false; attrs = Stringmap.add "Ival" strlength Stringmap.empty; storeloc = new_store ()}
  | "String.substr" -> 
    let str1 : string = Stringmap.find "Sval" self_object.attrs in
    (* start index to start the substring is in formal named "i" *)
    let stobj : objekt = Stringmap.find (Stringmap.find "i" environment) !store in
    let start : int = int_of_string (Stringmap.find "Ival" stobj.attrs) in
    (* length of substring is stored in formal named "l" *)
    let leobj : objekt = Stringmap.find (Stringmap.find "l" environment) !store in
    let leng : int = int_of_string (Stringmap.find "Ival" leobj.attrs) in
    (try (
      let strsub : string = String.sub str1 start leng in
      {typ = "String"; void = false; attrs = Stringmap.add "Sval" strsub Stringmap.empty; storeloc = new_store ()})
    with Invalid_argument "String.sub" ->(
      print_endline "ERROR: 0: Exception: you messed up with substrings";
      exit 0;))
  | _ ->
    print_endline "error internal method DOES NOT EXIST";
    self_object

(* execute method method_name from the obj_type specified with the given self_object and arguments registers *)
and execute_method (self_object : objekt) (obj_type : string) (method_name : string) (arguments : string list) : objekt =
  (* look up the formal names and the body of the method in the implementation map *)
  let formals,_,body = Stringmap.find method_name (Stringmap.find obj_type implementation_map) in
  (* map the formal names to their registers *)
  let formal_mappings : string Stringmap.t = List.fold_left2 (fun mapp formal argument -> Stringmap.add formal argument mapp) Stringmap.empty formals arguments in
  (* environment maps from identifier names to registers *)
  (* add in the attributes of self_object to the environment, shadowing the formals*)
  let environment : string Stringmap.t = Stringmap.merge (fun l x y -> match x,y with
    | None,x -> x
    | x,None -> x
    | x,y -> x) formal_mappings self_object.attrs in
  (* the self identifier always maps to the "self" register, whose store is self_object *)
  let environment : string Stringmap.t = Stringmap.add "self" "self" environment in
  ignore (store := Stringmap.add "self" self_object !store);
  execute_expression self_object environment body
;;

(* To interpret a cool program execute a "new Main" method, then evaluate Main's main method with the new Main object as the self object *)
let newmain : objekt = execute_expression {typ = "Main"; void = false; attrs = Stringmap.empty; storeloc = new_store ()} Stringmap.empty (Enew ("0","Main","Main")) in
  execute_method newmain "Main" "main" []
