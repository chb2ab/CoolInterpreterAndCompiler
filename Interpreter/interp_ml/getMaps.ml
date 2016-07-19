(* identifier string *)
type identifier = string

(*--------------------------
Types for each expression
--------------------------*)
type binding =
  (* identifier : identifier <- expression *)
| Bindinginit of identifier * identifier * expression
  (* identifier : identifier *)
| Bindingnoinit of identifier * identifier
and
(* identifier : identifier => expression *)
caseelement = identifier * identifier * expression
and
expression =
(* first two parameters in an expression are linenumber and static type *)
(* the other parameters appear in order from left to right of the cool syntax *)
  (* identifier <- expression *)
| Eassign of      string * string * identifier * expression
  (* expression.identifier(expression list) *)
| Edyndisp of     string * string * expression * identifier * expression list
  (* expression@identifier.identifier(expression list) *)
| Estatdisp of    string * string * expression * identifier * identifier * expression list
  (* identifier.(expression list) *)
| Eselfdisp of    string * string * identifier * expression list
  (* if expression then expression else expression fi *)
| Eif of          string * string * expression * expression * expression
  (* while expression loop expression pool *)
| Ewhile of       string * string * expression * expression
  (* { expression list } *)
| Eblock of       string * string * expression list
  (* new identifier *)
| Enew of         string * string * identifier
  (* isvoid expression *)
| Eisvoid of      string * string * expression
  (* expression + expression *)
| Eplus of        string * string * expression * expression
  (* expression - expression *)
| Eminus of       string * string * expression * expression
  (* expression * expression *)
| Etimes of       string * string * expression * expression
  (* expression / expression *)
| Edivide of      string * string * expression * expression
  (* expression < expression *)
| Elt of          string * string * expression * expression
  (* expression <= expression *)
| Ele of          string * string * expression * expression
  (* expression = expression *)
| Eeq of          string * string * expression * expression
  (* not expression *)
| Enot of         string * string * expression
  (* ~expression *)
| Enegate of      string * string * expression
  (* int *)
| Einteger of     string * string * string
  (* string *)
| Estring of      string * string * string
  (* identifier *)
| Eident of       string * string * identifier
  (* true *)
| Etrue of        string * string
  (* false *)
| Efalse of       string * string
  (* let binding list in expression *)
| Elet of         string * string * binding list * expression
  (* case expression of caseelement list esac *)
| Ecase of        string * string * expression * caseelement list
(* string *)
| Einternal of    string * string * string

type attribute =
  (* attributes have a linenumber, name, type, and can have an initializer *)
| AttrInit of   string * string * string * expression
| AttrNoInit of string * string * string

(* name of formal *)
type imformal = string

(* method has a name, list of formals, the class that defined it, and a body *)
type immethod = imformal list * string * expression

(* map from strings to objects *)
module Stringmap = Map.Make (String)

(* get an identifier from the AAST *)
let get_ident_from_file (file : in_channel) : identifier = 
  (* ignore line number *)
  ignore (input_line file);
  let ident : string = input_line file in
  ident

(* recursively extract a list of length num_exprs of expressions from the AAST *)
let rec get_expr_list_from_file (num_exprs : int) (file : in_channel) : expression list = match num_exprs with
| 0 -> []
| num_exprs -> 
  let expr : expression = get_expr_from_file file in
  expr :: (get_expr_list_from_file (num_exprs-1) file)

(* recursively extract a list of num_bindings of bindings from the AAST *)
and get_binding_list_from_file (num_bindings : int) (file : in_channel) : binding list = match num_bindings with
| 0 -> []
| num_bindings -> 
  let binder : binding = get_binding_from_file file in
  binder :: (get_binding_list_from_file (num_bindings-1) file)

(* extract a let binding from the AAST *)
and get_binding_from_file (file : in_channel) : binding =
  let bindingtyp : string = input_line file in
  match bindingtyp with
| "let_binding_no_init" ->
  let variable : identifier = get_ident_from_file file in
  let typ : identifier = get_ident_from_file file in
  Bindingnoinit (variable, typ)
| "let_binding_init" ->
  let variable : identifier = get_ident_from_file file in
  let typ : identifier= get_ident_from_file file in
  let value : expression = get_expr_from_file file in
  Bindinginit (variable, typ, value)
| _ ->
  print_endline "error in get_binding_from_file";
  let variable : identifier = get_ident_from_file file in
  let typ : identifier = get_ident_from_file file in
  Bindingnoinit (variable, typ)

(* recursively extract a list of num_els case elements from the AAST *)
and get_case_element_list (num_els : int) (file : in_channel) : caseelement list = match num_els with
| 0 -> []
| num_els ->
  let variable : identifier = get_ident_from_file file in
  let typ : identifier = get_ident_from_file file in
  let body : expression = get_expr_from_file file in
  (variable, typ, body) :: (get_case_element_list (num_els-1) file)

(* extract an expression from the AAST file *)
and get_expr_from_file (file : in_channel) : expression =
  let linenum : string = input_line file in
  let typ : string = input_line file in
  let exptype : string = input_line file in
  match exptype with
| "assign" ->
  let var : identifier = get_ident_from_file file in
  let rhs : expression = get_expr_from_file file in
  Eassign (linenum, typ, var, rhs)
| "dynamic_dispatch" ->
  let e : expression = get_expr_from_file file in
  let meth : identifier = get_ident_from_file file in
  let numargs : int = int_of_string (input_line file) in
  let args : expression list = get_expr_list_from_file numargs file in
  Edyndisp (linenum, typ, e, meth, args)
| "static_dispatch" ->
  let e : expression = get_expr_from_file file in
  let stattyp : identifier = get_ident_from_file file in
  let meth : identifier = get_ident_from_file file in
  let numargs : int = int_of_string (input_line file) in
  let args : expression list = get_expr_list_from_file numargs file in
  Estatdisp (linenum, typ, e, stattyp, meth, args)
| "self_dispatch" ->
  let meth : identifier = get_ident_from_file file in
  let numargs : int = int_of_string (input_line file) in
  let args : expression list = get_expr_list_from_file numargs file in
  Eselfdisp (linenum, typ, meth, args)
| "if" ->
  let predicate : expression = get_expr_from_file file in
  let thenn : expression = get_expr_from_file file in
  let els : expression = get_expr_from_file file in
  Eif (linenum, typ, predicate, thenn, els)
| "while" ->
  let condition : expression = get_expr_from_file file in
  let body : expression = get_expr_from_file file in
  Ewhile (linenum, typ, condition, body)
| "block" ->
  let numexprs : int = int_of_string (input_line file) in
  let exprs : expression list= get_expr_list_from_file numexprs file in
  Eblock (linenum, typ, exprs)
| "new" ->
  let clas :identifier = get_ident_from_file file in
  Enew (linenum, typ, clas)
| "isvoid" ->
  let e : expression = get_expr_from_file file in
  Eisvoid (linenum, typ, e)
| "plus" ->
  let x : expression = get_expr_from_file file in
  let y : expression = get_expr_from_file file in
  Eplus (linenum, typ, x, y)
| "minus" ->
  let x : expression = get_expr_from_file file in
  let y : expression = get_expr_from_file file in
  Eminus (linenum, typ, x, y)
| "times" ->
  let x : expression = get_expr_from_file file in
  let y : expression = get_expr_from_file file in
  Etimes (linenum, typ, x, y)
| "divide" ->
  let x : expression = get_expr_from_file file in
  let y : expression = get_expr_from_file file in
  Edivide (linenum, typ, x, y)
| "lt" ->
  let x : expression = get_expr_from_file file in
  let y : expression = get_expr_from_file file in
  Elt (linenum, typ, x, y)
| "le" ->
  let x : expression = get_expr_from_file file in
  let y : expression = get_expr_from_file file in
  Ele (linenum, typ, x, y)
| "eq" ->
  let x : expression = get_expr_from_file file in
  let y : expression = get_expr_from_file file in
  Eeq (linenum, typ, x, y)
| "not" ->
  let x : expression = get_expr_from_file file in
  Enot (linenum, typ, x)
| "negate" ->
  let x : expression = get_expr_from_file file in
  Enegate (linenum, typ, x)
| "integer" ->
  let const : string = input_line file in
  Einteger (linenum, typ, const)
| "string" ->
  let str : string = input_line file in
  Estring (linenum, typ, str)
| "identifier" ->
  let ident : identifier = get_ident_from_file file in
  Eident (linenum, typ, ident)
| "true" ->
  Etrue (linenum, typ)
| "false" ->
  Efalse (linenum, typ)
| "let" ->
  let numbindings : int = int_of_string (input_line file) in
  let bindings : binding list = get_binding_list_from_file numbindings file in
  let body : expression = get_expr_from_file file in
  Elet (linenum, typ, bindings, body)
| "case" ->
  let casee : expression = get_expr_from_file file in
  let numelements : int = int_of_string (input_line file) in
  let elementss : caseelement list = get_case_element_list numelements file in
  Ecase (linenum, typ, casee, elementss)
| "internal" ->
  let meth : string = input_line file in
  Einternal (linenum, typ, meth)
| _ ->
  print_endline "error in get_expr_from_file";
  Etrue ("error", "error")

(* get a list of length num_attrs of attributes from the class map in the type file *)
let rec get_cmattributes_from_file (num_attrs : int) (file : in_channel) : attribute list = match num_attrs with
| 0 -> []
| num_attrs ->
  let init : string = input_line file in
  let name : string = input_line file in
  let typ : string = input_line file in
  match init with
| "no_initializer" ->
    AttrNoInit ("0", name, typ) :: get_cmattributes_from_file (num_attrs-1) file
| "initializer" ->
    let expr : expression = get_expr_from_file file in
    AttrInit ("0", name, typ, expr) :: get_cmattributes_from_file (num_attrs-1) file
| _ ->
  print_endline "error in get_cmattributes_from_file";
  []

(* get a list of length num_formals of formals from the implementation map in the type file *)
let rec get_imformals_from_file (num_formals : int) (file : in_channel) : imformal list = match num_formals with
| 0 -> []
| num_formals ->
  let form_name : string = input_line file in
  form_name :: (get_imformals_from_file (num_formals-1) file)

(* create a mapping from method name to method types from the implementation map in the type file*)
let rec get_immethods_from_file (num_meths : int) (file : in_channel) : immethod Stringmap.t = match num_meths with
| 0 -> Stringmap.empty
| num_meths ->
  let name : string = input_line file in
  let num_formals : int = int_of_string (input_line file) in
  let formals : imformal list = get_imformals_from_file num_formals file in
  let definer : string = input_line file in
  let body : expression = get_expr_from_file file in
  let immethods : immethod Stringmap.t = get_immethods_from_file (num_meths-1) file in
  Stringmap.add name (formals, definer, body) immethods

(* create a mapping from class name to it's list of attributes from the class map in the type file *)
let rec get_cmclasses_from_file (num_classes : int) (file : in_channel) : attribute list Stringmap.t = match num_classes with
| 0 -> Stringmap.empty
| num_classes ->
  let name : string = input_line file in
  let num_attributes : int = int_of_string (input_line file) in
  let attributes : attribute list = get_cmattributes_from_file num_attributes file in
  let clas_map : attribute list Stringmap.t = get_cmclasses_from_file (num_classes-1) file in
  Stringmap.add name attributes clas_map

(* get implementation map representation for classes from the type file. Each class is represented as a mapping from method name to immethod type *)
let rec get_imclasses_from_file (num_classes : int) (file : in_channel) : (immethod Stringmap.t) Stringmap.t = match num_classes with
| 0 -> Stringmap.empty
| num_classes ->
  let name : string = input_line file in
  let num_meths : int = int_of_string (input_line file) in
  let methods : immethod Stringmap.t = get_immethods_from_file num_meths file in
  let im_map : (immethod Stringmap.t) Stringmap.t = get_imclasses_from_file (num_classes-1) file in
  Stringmap.add name methods im_map

(* get the parent map from the type file. The parent map maps a class name to its parent *)
let rec get_relations_from_file (num_rels : int) (file : in_channel) : string Stringmap.t = match num_rels with
| 0 -> Stringmap.empty
| num_rels ->
  let child : string = input_line file in
  let parent : string = input_line file in
  let pmap : string Stringmap.t = get_relations_from_file (num_rels-1) file in
  Stringmap.add child parent pmap

(* The class map is represented as a mapping from class name to its list of attributes *)
let get_class_map (file : in_channel) : attribute list Stringmap.t = 
  ignore (input_line file);
  let num_classes : int = int_of_string (input_line file) in
  get_cmclasses_from_file num_classes file

(* The implementation map is represented as a mapping from class name to a map of method names to methods *)
let get_implementation_map (file : in_channel) : (immethod Stringmap.t) Stringmap.t =
  ignore (input_line file);
  let num_classes : int = int_of_string (input_line file) in
  get_imclasses_from_file num_classes file 

(* The parent map is a mapping of class name to it's parent *)
let get_parent_map (file : in_channel) : string Stringmap.t =
  ignore (input_line file);
  let num_rels : int = int_of_string (input_line file) in
  get_relations_from_file num_rels file
