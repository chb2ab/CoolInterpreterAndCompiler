module Deserializer where
import AST_nodes

-- deserialize the ast by reading in a list of classes
readAST :: [String] -> [Class]
readAST [] = []
readAST (num_classes:xs) = (readClasses (read num_classes :: Int) xs)

-- read in a list of classes, the first parameter indicates how many classes their are, the second parameter is the serialized ast
readClasses :: Int -> [String] -> [Class]
readClasses 0 ast = []
readClasses x (clas_nm_l:clas_nm:inh:num_features:xs) | inh == "no_inherits" = do
    let (ast, feats) = readFeatures clas_nm (read num_features :: Int) xs
    -- Classes that don't inherit are made to inherit from object
    (Class_Inh {c_name = Identifier {i_ln = clas_nm_l, i = clas_nm}, inherited = Identifier {i_ln = "0", i = "Object"}, features = feats, obj_inh = True}):(readClasses (x-1) ast)
readClasses x (clas_nm_l:clas_nm:inh:inh_nm_ln:inh_nm:num_features:xs) | inh == "inherits" = do
    let (ast, feats) = readFeatures clas_nm (read num_features :: Int) xs
    (Class_Inh {c_name = Identifier {i_ln = clas_nm_l, i = clas_nm}, inherited = Identifier {i_ln = inh_nm_ln, i = inh_nm}, features = feats, obj_inh = False}):(readClasses (x-1) ast)
readClasses x y = 
    [(Class_Err {err = "error"})]

-- Read in a list of features, returns the list of features as well as the serialized AST with the read in feature removed
readFeatures :: String -> Int -> [String] -> ([String], [Feature])
readFeatures c_nm 0 ast = (ast, [])
readFeatures c_nm x (feat:nm_ln:nm:typ_ln:typ:xs) | feat == "attribute_no_init" = do
    let (ast, feats) = readFeatures c_nm (x-1) xs
    ( ast, (Attr_No_Init {f_definer = c_nm, f_name = Identifier {i_ln = nm_ln, i = nm}, f_type = Identifier {i_ln = typ_ln, i = typ}}):feats )
readFeatures c_nm x (feat:nm_ln:nm:typ_ln:typ:xs) | feat == "attribute_init" = do
    let (ast, expr) = readExpression xs
    let (ret_ast, feats) = readFeatures c_nm (x-1) ast
    ( ret_ast, (Attr_Init {f_definer = c_nm, f_name = Identifier {i_ln = nm_ln, i = nm}, f_type = Identifier {i_ln = typ_ln, i = typ}, f_init = expr}):feats )
readFeatures c_nm x (feat:nm_ln:nm:num_formals:xs) | feat == "method" = do
    let (ast, formals) = readFormals (read num_formals :: Int) xs
    let typ_ln:typ:xss = ast
    let (ast2, expr) = readExpression xss
    let (ret_ast, feats) = readFeatures c_nm (x-1) ast2
    ( ret_ast, (Method {f_definer = c_nm, f_name = Identifier {i_ln = nm_ln, i = nm}, f_formals = formals, f_type = Identifier {i_ln = typ_ln, i = typ}, f_body = expr}):feats )
readFeatures c_nm x y = ( y, [(Feat_Error {f_error = "error"})] )

-- Read in a list of expressions, returns the list of expressions as well as the serialized AST with the read in list removed
readExpressions :: Int -> [String] -> ([String], [Expression])
readExpressions 0 ast = (ast, [])
readExpressions x ast = do
    let (ast2, expr) = readExpression ast
    let (ret_ast, exprs) = readExpressions (x-1) ast2
    (ret_ast, expr:exprs)

-- Read in an expression, returns the expression as well as the serialized AST with the read in expression removed
readExpression :: [String] -> ([String], Expression)
readExpression (exp_ln:exp_typ:var_ln:var:xs) | exp_typ == "assign" = do
    let (ast, expr) = readExpression xs
    (ast, E_Assign {e_type = "", e_ln = exp_ln, var = Identifier {i_ln = var_ln, i = var}, rhs = expr})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "dynamic_dispatch" = do
    let (ast, expr) = readExpression xs
    let (meth_ln:meth:num_args:ast2) = ast
    let (ret_ast, args) = readExpressions (read num_args :: Int) ast2
    (ret_ast, E_Dynamic_Dispatch {e_type = "", e_ln = exp_ln, e = expr, method = Identifier {i_ln = meth_ln, i = meth}, args = args})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "static_dispatch" = do
    let (ast, expr) = readExpression xs
    let (typ_ln:typ:meth_ln:meth:num_args:ast2) = ast
    let (ret_ast, args) = readExpressions (read num_args :: Int) ast2
    (ret_ast, E_Static_Dispatch {e_type = "", e_ln = exp_ln, e = expr, typ = Identifier {i_ln = typ_ln, i = typ}, method = Identifier {i_ln = meth_ln, i = meth}, args = args})
readExpression (exp_ln:exp_typ:meth_ln:meth:num_args:xs) | exp_typ == "self_dispatch" = do
    let (ast, args) = readExpressions (read num_args :: Int) xs
    (ast, E_Self_Dispatch {e_type = "", e_ln = exp_ln, method = Identifier {i_ln = meth_ln, i = meth}, args = args})
readExpression (exp_ln:exp_typ:meth_ln:meth:num_args:xs) | exp_typ == "self_dispatch" = do
    let (ast, args) = readExpressions (read num_args :: Int) xs
    (ast, E_Self_Dispatch {e_type = "", e_ln = exp_ln, method = Identifier {i_ln = meth_ln, i = meth}, args = args})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "if" = do
    let (ast, predi) = readExpression xs
    let (ast2, thenn) = readExpression ast
    let (ret_ast, elsee) = readExpression ast2
    (ret_ast, E_If {e_type = "", e_ln = exp_ln, predicate = predi, thenn = thenn, elsee = elsee})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "while" = do
    let (ast, predi) = readExpression xs
    let (ret_ast, body) = readExpression ast
    (ret_ast, E_While {e_type = "", e_ln = exp_ln, predicate = predi, body = body})
readExpression (exp_ln:exp_typ:num_args:xs) | exp_typ == "block" = do
    let (ast, exp_list) = readExpressions (read num_args :: Int) xs
    (ast, E_Block {e_type = "", e_ln = exp_ln, bodies = exp_list})
readExpression (exp_ln:exp_typ:class_ln:class_nm:xs) | exp_typ == "new" = 
    (xs, E_New {e_type = "", e_ln = exp_ln, clas = Identifier {i_ln = class_ln, i = class_nm}})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "isvoid" = do
    let (ast, e) = readExpression xs
    (ast, E_Isvoid {e_type = "", e_ln = exp_ln, e = e})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "plus" = do
    let (ast, x) = readExpression xs
    let (ret_ast, y) = readExpression ast
    (ret_ast, E_Plus {e_type = "", e_ln = exp_ln, x = x, y = y})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "minus" = do
    let (ast, x) = readExpression xs
    let (ret_ast, y) = readExpression ast
    (ret_ast, E_Minus {e_type = "", e_ln = exp_ln, x = x, y = y})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "times" = do
    let (ast, x) = readExpression xs
    let (ret_ast, y) = readExpression ast
    (ret_ast, E_Times {e_type = "", e_ln = exp_ln, x = x, y = y})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "divide" = do
    let (ast, x) = readExpression xs
    let (ret_ast, y) = readExpression ast
    (ret_ast, E_Divide {e_type = "", e_ln = exp_ln, x = x, y = y})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "lt" = do
    let (ast, x) = readExpression xs
    let (ret_ast, y) = readExpression ast
    (ret_ast, E_Lt {e_type = "", e_ln = exp_ln, x = x, y = y})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "le" = do
    let (ast, x) = readExpression xs
    let (ret_ast, y) = readExpression ast
    (ret_ast, E_Le {e_type = "", e_ln = exp_ln, x = x, y = y})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "eq" = do
    let (ast, x) = readExpression xs
    let (ret_ast, y) = readExpression ast
    (ret_ast, E_Eq {e_type = "", e_ln = exp_ln, x = x, y = y})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "not" = do
    let (ast, x) = readExpression xs
    (ast, E_Not {e_type = "", e_ln = exp_ln, x = x})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "negate" = do
    let (ast, x) = readExpression xs
    (ast, E_Negate {e_type = "", e_ln = exp_ln, x = x})
readExpression (exp_ln:exp_typ:i_cons:xs) | exp_typ == "integer" =
    (xs, E_Integer {e_type = "", e_ln = exp_ln, i_const = i_cons})
readExpression (exp_ln:exp_typ:s_cons:xs) | exp_typ == "string" =
    (xs, E_String {e_type = "", e_ln = exp_ln, s_const = s_cons})
readExpression (exp_ln:exp_typ:var_ln:var:xs) | exp_typ == "identifier" =
    (xs, E_Identifier {e_type = "", e_ln = exp_ln, var = Identifier {i_ln = var_ln, i = var}})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "true" =
    (xs, E_True {e_type = "", e_ln = exp_ln})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "false" =
    (xs, E_False {e_type = "", e_ln = exp_ln})
readExpression (exp_ln:exp_typ:num_binds:xs) | exp_typ == "let" = do
    let (ast, bindings) = readBindings (read num_binds :: Int) xs
    let (ret_ast, body) = readExpression ast
    (ret_ast, E_Let {e_type = "", e_ln = exp_ln, bindings = bindings, body = body})
readExpression (exp_ln:exp_typ:xs) | exp_typ == "case" = do
    let (ast, expr) = readExpression xs
    let (num_els:ast2) = ast
    let (ret_ast, case_els) = readCaseElements (read num_els :: Int) ast2
    (ret_ast, E_Case {e_type = "", e_ln = exp_ln, expr = expr, case_elements = case_els})
readExpression x = ( x, (E_Error {e_error = "error"}) )

-- Read in a list of formals
readFormals :: Int -> [String] -> ([String], [Formal])
readFormals 0 ast = (ast, [])
readFormals x (nm_ln:nm:typ_ln:typ:xs) = do
    let (ast, formals) = readFormals (x-1) xs
    ( ast, (Formal {fo_name = Identifier {i_ln = nm_ln, i = nm}, fo_type = Identifier {i_ln = typ_ln, i = typ}}):formals )
readFormals x y = ( y, [(Form_Error {fo_error = "error"})] )

-- read in let bindings
readBindings :: Int -> [String] -> ([String], [Binding])
readBindings 0 ast = (ast, [])
readBindings x (ini:var_ln:var:typ_ln:typ:xs) | ini == "let_binding_no_init" = do
    let (ast, bindings) = readBindings (x-1) xs
    ( ast, (Binding_No_Init {b_variable = Identifier {i_ln = var_ln, i = var}, b_typ = Identifier {i_ln = typ_ln, i = typ}}):bindings )
readBindings x (ini:var_ln:var:typ_ln:typ:xs) | ini == "let_binding_init" = do
    let (ast, val) = readExpression xs
    let (ret_ast, bindings) = readBindings (x-1) ast
    ( ret_ast, (Binding_Init {b_variable = Identifier {i_ln = var_ln, i = var}, b_typ = Identifier {i_ln = typ_ln, i = typ}, b_value = val}):bindings )
readBindings x y = ( y, [(Binding_Error {b_error = "error"})] )

-- read in case elements
readCaseElements :: Int -> [String] -> ([String], [Case_Element])
readCaseElements 0 ast = (ast, [])
readCaseElements x (var_ln:var:typ_ln:typ:xs) = do
    let (ast, body) = readExpression xs
    let (ret_ast, elements) = readCaseElements (x-1) ast
    ( ret_ast, (Case_Element {c_variable = Identifier {i_ln = var_ln, i = var}, c_typ = Identifier {i_ln = typ_ln, i = typ}, c_body = body}):elements )
readCaseElements x y = ( y, [(Case_Error {c_error = "error"})] )
