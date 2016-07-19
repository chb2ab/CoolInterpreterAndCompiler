module Type_checker where
import Data.Map
import Check_misc
import AST_nodes

-- Type Check Expressions
-- Return a list of classes with annotated expressions if succesful, otherwise return an error string
typeCheck :: [Class] -> (String, [Class])
typeCheck classes = do
    let (err_string, new_classes) = typCheckClasses classes classes
    if err_string == "" then
        ("", new_classes)
    else
        (err_string, [])

-- Type check a list of classes by checking each class in sequence
typCheckClasses :: [Class] -> [Class] -> (String, [Class])
typCheckClasses classes [] = ("", [])
typCheckClasses classes (x:xs) = do
    let (err_string, new_class) = typeCheckClass classes x
    if err_string == "" then do
        let (err_string, new_classes) = typCheckClasses classes xs
        (err_string, new_class:new_classes)
    else (err_string, [])

-- Type check a specific class by checking its features
typeCheckClass :: [Class] -> Class -> (String, Class)
typeCheckClass classes clas = do
    let attr_list = [ ((i (f_name x)), (i (f_type x))) | x <- (getAttributes (features clas)) ]
    let mapp = (fromList (attr_list++[ ("self", "SELF_TYPE"), ("SELF_TYPE", (i (c_name clas))) ]) )
    let (err_string, new_feats) = typeCheckFeatures classes mapp (features clas)
    (err_string, clas {features = new_feats})

-- Type check a list of features by checking each feature in sequence. A feature will either be an attribute or a method. If an attribute has an init, type check the init.
typeCheckFeatures :: [Class] -> Map String String -> [Feature] -> (String, [Feature])
typeCheckFeatures classes mapp [] = ("", [])
typeCheckFeatures classes mapp (x:xs) = do
    case x of
        Attr_No_Init a1 a2 a3 -> do
            let (err_string, feats) = typeCheckFeatures classes mapp xs
            (err_string, (x:feats)) 
        Attr_Init a1 a2 a3 a4 -> do
            let (err_string, typp1, new_init) = typeCheckExpr classes mapp (f_init x)
            if err_string == "" then do
                if lessTOrEq classes mapp typp1 (i (f_type x)) then do
                    let (err_string, feats) = typeCheckFeatures classes mapp xs
                    (err_string, (x {f_init = new_init}):feats)
                else ("ERROR: "++(read $ show (i_ln (f_name x)))++": Type-Check: Attribute initialized with type which doesn't conform to declared type", [])
            else (err_string, [])
        Method a1 a2 a3 a4 a5 -> do
            let (err_string, new_meth) = typeCheckMeth classes mapp x
            if err_string == "" then do
                let (err_string, feats) = typeCheckFeatures classes mapp xs
                (err_string, new_meth:feats)
            else (err_string, [])
        _ -> ("error", [])

-- Type check a method by checking its body and return type
typeCheckMeth :: [Class] -> Map String String -> Feature -> (String, Feature)
typeCheckMeth classes mapp meth = do
    let (err_string, typp, body_new) = typeCheckExpr classes (Data.Map.union (fromList [( (i (fo_name x)), (i (fo_type x)) ) | x <- (f_formals meth)]) mapp) (f_body meth)
    if err_string == "" then do
        if (lessTOrEq classes mapp typp (i (f_type meth))) then ("", (meth {f_body = body_new}))
        else ("ERROR: "++(read $ show (i_ln (f_type meth)))++": Type-Check: Return type "++(i (f_type meth))++" doesn't match body-type "++typp, meth)
    else (err_string, meth)

-- Type check expressions, takes in the class environment, type environment, and the expression to check. Returns an error message, the type of the expression, and a new annotated expression node
typeCheckExpr :: [Class] -> Map String String -> Expression -> (String, String, Expression)
typeCheckExpr classes mapp ex = do
    -- On error, return the error expression
    let error_ex = E_Error {e_error = "type error"}
    -- Case over all types of expressions
    case ex of
        E_Assign a1 a2 a3 a4 -> do
            let (err_string, typp1) = checkIdentifier mapp (var ex)
            if err_string == "" then do
                let (err_string, typp2, rhs_new) = typeCheckExpr classes mapp (rhs ex)
                if err_string == "" then do
                    if lessTOrEq classes mapp typp2 typp1 then ("", typp2, ex {e_type = typp2, rhs = rhs_new})
                    else ("ERROR: "++(read $ show (i_ln (var ex)))++": Type-Check: Assignment doesn't conform", "", error_ex)
                else (err_string, "", error_ex)
            else (err_string, "", error_ex)
        E_Dynamic_Dispatch a1 a2 a3 a4 a5 -> do
            let (err_string, t0, e_new) = typeCheckExpr classes mapp (e ex)
            if err_string == "" then do
                let t0p = lookupEnvTyp mapp t0
                let (err_string, params, args_new) = typeCheckExprs classes mapp (args ex) []
                if err_string == "" then do
                    let (err_string, func) = lookupFunc classes mapp t0p (i (method ex)) (i_ln (method ex))
                    if err_string == "" then do
                        let fotypes = [(i (fo_type fo)) | fo <- (f_formals func)]
                        if (length fotypes) == (length (args ex)) then do
                            let err_string = lessTOrEqLists classes mapp (e_ln ex) params fotypes
                            if err_string == "" then do
                                let rettype = (i (f_type func))
                                if rettype == "SELF_TYPE" then ("", t0, ex {e_type = t0, e = e_new, args = args_new})
                                else ("", rettype, ex {e_type = rettype, e = e_new, args = args_new})
                            else (err_string, "", error_ex)
                        else ("ERROR: "++(read $ show (e_ln ex))++": Type-Check: Not the same number of parameters", "", error_ex)
                    else (err_string, "", error_ex)
                else (err_string, "", error_ex)
            else (err_string, "", error_ex)
        E_Static_Dispatch a1 a2 a3 a4 a5 a6 -> do
            let (err_string, t0, e_new) = typeCheckExpr classes mapp (e ex)
            if err_string == "" then do
                let t = (i (typ ex))
                if (lessTOrEq classes mapp t0 t) then do
                    let (err_string, params, args_new) = typeCheckExprs classes mapp (args ex) []
                    if err_string == "" then do
                        let (err_string, func) = lookupFunc classes mapp t (i (method ex)) (i_ln (method ex))
                        if err_string == "" then do
                            let fotypes = [(i (fo_type fo)) | fo <- (f_formals func)]
                            if (length fotypes) == (length (args ex)) then do
                                let err_string = lessTOrEqLists classes mapp (e_ln ex) params fotypes
                                if err_string == "" then do
                                    let rettype = (i (f_type func))
                                    if rettype == "SELF_TYPE" then ("", t0, ex {e_type = t0, e = e_new, args = args_new})
                                    else ("", rettype, ex {e_type = rettype, e = e_new, args = args_new})
                                else (err_string, "", error_ex)
                            else ("ERROR: "++(read $ show (e_ln ex))++": Type-Check: Not the same number of parameters", "", error_ex)
                        else (err_string, "", error_ex)
                    else (err_string, "", error_ex)
                else ("ERROR: "++(read $ show (i_ln (typ ex)))++": Type-Check: Static dispatch assignment isn't right", "", error_ex)
            else (err_string, "", error_ex)
        E_Self_Dispatch a1 a2 a3 a4 -> do
            let t0 = Data.Map.findWithDefault "error" "self" mapp
            let (err_string, params, args_new) = typeCheckExprs classes mapp (args ex) []
            if err_string == "" then do
                let (err_string, func) = lookupFunc classes mapp t0 (i (method ex)) (i_ln (method ex))
                if err_string == "" then do
                    let fotypes = [(i (fo_type fo)) | fo <- (f_formals func)]
                    if (length fotypes) == (length (args ex)) then do
                        let err_string = lessTOrEqLists classes mapp (e_ln ex) params fotypes
                        if err_string == "" then do
                            let rettype = (i (f_type func))
                            if rettype == "SELF_TYPE" then ("", t0, ex {e_type = t0, args = args_new})
                            else ("", rettype, ex {e_type = rettype, args = args_new})
                        else (err_string, "", error_ex)
                    else ("ERROR: "++(read $ show (e_ln ex))++": Type-Check: Not the same number of parameters", "", error_ex)
                else (err_string, "", error_ex)
            else (err_string, "", error_ex)
        E_If a1 a2 a3 a4 a5 -> do
            let (err_string, typP, pred_new) = typeCheckExpr classes mapp (predicate ex)
            if err_string == "" then do
                if typP == "Bool" then do
                    let (err_string, typT, then_new) = typeCheckExpr classes mapp (thenn ex)
                    if err_string == "" then do
                        let (err_string, typE, else_new) = typeCheckExpr classes mapp (elsee ex)
                        if err_string == "" then ("", typeUnion classes mapp typT typE, ex {e_type = (typeUnion classes mapp typT typE), predicate = pred_new, thenn = then_new, elsee = else_new})
                        else (err_string, "", error_ex)
                    else (err_string, "", error_ex)
                else ("ERROR: "++(read $ show (e_ln ex))++": Type-Check: Predicate of if must be boolean", "", error_ex)
            else (err_string, "", error_ex)
        E_While a1 a2 a3 a4 -> do
            let (err_string, typ1, pred_new) = typeCheckExpr classes mapp (predicate ex)
            if err_string == "" then do
                if typ1 == "Bool" then do
                    let (err_string, typ2, body_new) = typeCheckExpr classes mapp (body ex)
                    if err_string == "" then ("", "Object", ex {e_type = "Object", predicate = pred_new, body = body_new})
                    else (err_string, "", error_ex)
                else ("ERROR: "++(read $ show (e_ln (predicate ex)))++": Type-Check: Predicate of while must be boolean", "", error_ex)
            else (err_string, "", error_ex)
        E_Block a1 a2 a3 -> do 
            let (err_string, types, bodies_new) = typeCheckExprs classes mapp (bodies ex) []
            if err_string == "" then ("", last types, ex {e_type = (last types), bodies = bodies_new})
            else (err_string, "", error_ex)
        E_New a1 a2 a3 -> do
            ("", (i (clas ex)), ex {e_type = (i (clas ex))})
        E_Isvoid a1 a2 a3 -> do
            let (err_string, typ1, e_new) = typeCheckExpr classes mapp (e ex)
            if err_string == "" then ("", "Bool", ex {e_type = "Bool", e = e_new})
            else (err_string, "", error_ex)
        E_Plus a1 a2 a3 a4 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                if typ1 == "Int" then do
                    let (err_string, typ2, y_new) = typeCheckExpr classes mapp (y ex)
                    if err_string == "" then do
                        if typ2 == "Int" then ("", "Int", ex {e_type = "Int", x = x_new, y = y_new})
                        else ("ERROR: "++(read $ show (e_ln (y ex)))++": Type-Check: Addition must be done on ints", "", error_ex)
                    else (err_string, "", error_ex)
                else ("ERROR: "++(read $ show (e_ln (x ex)))++": Type-Check: Addition must be done on ints", "", error_ex)
            else (err_string, "", error_ex)
        E_Minus a1 a2 a3 a4 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                if typ1 == "Int" then do
                    let (err_string, typ2, y_new) = typeCheckExpr classes mapp (y ex)
                    if err_string == "" then do
                        if typ2 == "Int" then ("", "Int", ex {e_type = "Int", x = x_new, y = y_new})
                        else ("ERROR: "++(read $ show (e_ln (y ex)))++": Type-Check: Subtraction must be done on ints", "", error_ex)
                    else (err_string, "", error_ex)
                else ("ERROR: "++(read $ show (e_ln (x ex)))++": Type-Check: Subtraction must be done on ints", "", error_ex)
            else (err_string, "", error_ex)
        E_Times a1 a2 a3 a4 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                if typ1 == "Int" then do
                    let (err_string, typ2, y_new) = typeCheckExpr classes mapp (y ex)
                    if err_string == "" then do
                        if typ2 == "Int" then ("", "Int", ex {e_type = "Int", x = x_new, y = y_new})
                        else ("ERROR: "++(read $ show (e_ln (y ex)))++": Type-Check: Multiplication must be done on ints", "", error_ex)
                    else (err_string, "", error_ex)
                else ("ERROR: "++(read $ show (e_ln (x ex)))++": Type-Check: Multiplication must be done on ints", "", error_ex)
            else (err_string, "", error_ex)
        E_Divide a1 a2 a3 a4 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                if typ1 == "Int" then do
                    let (err_string, typ2, y_new) = typeCheckExpr classes mapp (y ex)
                    if err_string == "" then do
                        if typ2 == "Int" then ("", "Int", ex {e_type = "Int", x = x_new, y = y_new})
                        else ("ERROR: "++(read $ show (e_ln (y ex)))++": Type-Check: Division must be done on ints", "", error_ex)
                    else (err_string, "", error_ex)
                else ("ERROR: "++(read $ show (e_ln (x ex)))++": Type-Check: Division must be done on ints", "", error_ex)
            else (err_string, "", error_ex)
        E_Lt a1 a2 a3 a4 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                let (err_string, typ2, y_new) = typeCheckExpr classes mapp (y ex)
                if err_string == "" then do
                    if (typeCheckEqualityOPs typ1 typ2) then ("", "Bool", ex {e_type = "Bool", x = x_new, y = y_new})
                    else ("ERROR: "++(read $ show (e_ln ex))++": Type-Check: Lt types don't match", "", error_ex)
                else (err_string, "", error_ex)
            else (err_string, "", error_ex)
        E_Le a1 a2 a3 a4 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                let (err_string, typ2, y_new) = typeCheckExpr classes mapp (y ex)
                if err_string == "" then do
                    if (typeCheckEqualityOPs typ1 typ2) then ("", "Bool", ex {e_type = "Bool", x = x_new, y = y_new})
                    else ("ERROR: "++(read $ show (e_ln ex))++": Type-Check: Le types don't match", "", error_ex)
                else (err_string, "", error_ex)
            else (err_string, "", error_ex)
        E_Eq a1 a2 a3 a4 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                let (err_string, typ2, y_new) = typeCheckExpr classes mapp (y ex)
                if err_string == "" then do
                    if (typeCheckEqualityOPs typ1 typ2) then ("", "Bool", ex {e_type = "Bool", x = x_new, y = y_new})
                    else ("ERROR: "++(read $ show (e_ln ex))++": Type-Check: Eq types don't match", "", error_ex)
                else (err_string, "", error_ex)
            else (err_string, "", error_ex)
        E_Not a1 a2 a3 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                if typ1 == "Bool" then ("", "Bool", ex {e_type = "Bool", x = x_new})
                else ("ERROR: "++(read $ show (e_ln (x ex)))++": Type-Check: Not must be applied to a boolean", "", error_ex)
            else (err_string, "", error_ex)
        E_Negate a1 a2 a3 -> do
            let (err_string, typ1, x_new) = typeCheckExpr classes mapp (x ex)
            if err_string == "" then do
                if typ1 == "Int" then ("", "Int", ex {e_type = "Int", x = x_new})
                else ("ERROR: "++(read $ show (e_ln (x ex)))++": Type-Check: Negate must be applied to an int", "", error_ex)
            else (err_string, "", error_ex)
        E_Integer a1 a2 a3 -> ("", "Int", ex {e_type = "Int"})
        E_String a1 a2 a3 -> ("", "String", ex {e_type = "String"})
        E_Identifier a1 a2 a3 -> do
            let (err_string, typ) = checkIdentifier mapp (var ex)
            (err_string, typ, ex {e_type = typ})
        E_True a1 a2 -> ("", "Bool", ex {e_type = "Bool"})
        E_False a1 a2 -> ("", "Bool", ex {e_type = "Bool"})
        E_Let a1 a2 a3 a4 -> do
            let (err_string, new_map, new_bindings) = typeCheckBindings classes (e_ln ex) mapp (bindings ex)
            if err_string == "" then do
                let (err_string, typp1, body_new) = typeCheckExpr classes new_map (body ex)
                if err_string == "" then ("", typp1, ex {e_type = typp1, bindings = new_bindings, body = body_new})
                else (err_string, "", error_ex)
            else (err_string, "", error_ex)
        E_Case a1 a2 a3 a4 -> do
            let (err_string, t0, expr_new) = typeCheckExpr classes mapp (expr ex)
            if err_string == "" then do
                let (err_string, types, new_case_els) = typeCheckCaseElements classes mapp (case_elements ex) [] []
                if err_string == "" then ("", typeUnionList classes mapp types, ex {e_type = (typeUnionList classes mapp types), expr = expr_new, case_elements = new_case_els})
                else (err_string, "", error_ex)
            else (err_string, "", error_ex)
        _ -> ("", "", error_ex)

-- Helper functions for type checking expressions

-- look up a function given a class name
lookupFunc :: [Class] -> Map String String -> String -> String -> String -> (String, Feature)
lookupFunc classes mapp clas_raw meth ln = do
    let clas = lookupEnvTyp mapp clas_raw
    let meths = getMethods (features (lookFor classes clas))
    let found = getMethod meths meth
    case found of
        Method a b c d e -> ("", found)
        _ -> ("ERROR: "++(read $ show ln)++": Type-Check: Method not found "++meth++" in class "++clas, found)
        
-- Check if one class conforms to another. 
lessTOrEq :: [Class] -> Map String String -> String -> String -> Bool
lessTOrEq classes mapp typ1_raw typ2_raw | typ2_raw == "SELF_TYPE" = typ1_raw == "SELF_TYPE"
lessTOrEq classes mapp typ1_raw typ2_raw = do
    let typ1 = lookupEnvTyp mapp typ1_raw
    let typ2 = typ2_raw
    if typ1 == typ2 then True
    else do
        if typ1 == "Object" then False
        else do lessTOrEq classes mapp (i (c_name (getParent classes (lookFor classes typ1)))) typ2

-- Compare elements in a pair of lists to see if each element in the list conforms to its corresponding element in the other list
lessTOrEqLists :: [Class] -> Map String String -> String -> [String] -> [String] -> String
lessTOrEqLists classes mapp ln [] [] = ""
lessTOrEqLists classes mapp ln (x1:xs1) (x2:xs2) = do
    if (lessTOrEq classes mapp x1 x2) then lessTOrEqLists classes mapp ln xs1 xs2
    else "ERROR: "++(read $ show ln)++": Type-Check: Binding of formal parameter doesn't conform"
lessTOrEqLists classes mapp ln x1 x2 = ""

-- Perform a type union on two classes
typeUnion :: [Class] -> Map String String -> String -> String -> String
typeUnion classes mapp typ1_raw typ2_raw = do
    if lessTOrEq classes mapp typ1_raw typ2_raw then typ2_raw
    else do
        if lessTOrEq classes mapp typ2_raw typ1_raw then typ1_raw
        else do
            let typ1 = lookupEnvTyp mapp typ1_raw
            let typ2 = lookupEnvTyp mapp typ2_raw
            typeUnion classes mapp (i (c_name (getParent classes (lookFor classes typ1)))) typ2

-- Perform a type union over a list of classes
typeUnionList :: [Class] -> Map String String -> [String] -> String
typeUnionList classes mapp [] = ""
typeUnionList classes mapp (x:xs) | (length xs) == 0 = x
typeUnionList classes mapp (typ1:typ2:xs) = typeUnionList classes mapp ((typeUnion classes mapp typ1 typ2):xs)

-- Look up type
lookupEnvTyp :: Map String String -> String -> String
lookupEnvTyp mapp typ = do
    if typ == "SELF_TYPE" then (Data.Map.findWithDefault "error" "SELF_TYPE" mapp)
    else typ

-- Equality operations between int, string and bool types must conform to each other
typeCheckEqualityOPs :: String -> String -> Bool
typeCheckEqualityOPs typ1 typ2 = do
    if elem typ1 ["Int", "String", "Bool"] then do
        if typ1 == typ2 then True
        else False
    else do
        if elem typ2 ["Int", "String", "Bool"] then False
        else True

-- Check a list of expressions
typeCheckExprs :: [Class] -> Map String String -> [Expression] -> [String] -> (String, [String], [Expression])
typeCheckExprs classes mapp [] types = ("", types, []) 
typeCheckExprs classes mapp (x:xs) types = do
    let (err_string, typ, exp_new) = typeCheckExpr classes mapp x
    if err_string == "" then do
        let (err_string, typs, exps) = typeCheckExprs classes mapp xs types
        (err_string, typ:typs, (exp_new {e_type = typ}):exps)
    else (err_string, [], [])

-- Type check each binding in let statement
typeCheckBindings :: [Class] -> String -> Map String String -> [Binding] -> (String, Map String String, [Binding])
typeCheckBindings classes ln mapp [] = ("", mapp, [])
typeCheckBindings classes ln mapp (x:xs) = do
    case x of
        Binding_No_Init a b -> do
            let (err_string, new_map, bindings) = typeCheckBindings classes ln (Data.Map.insert (i (b_variable x)) (i (b_typ x)) mapp) xs
            (err_string, new_map, x:bindings)
        Binding_Init a b c -> do
            let (err_string, t1, value_new) = typeCheckExpr classes mapp (b_value x)
            if err_string == "" then do
                if lessTOrEq classes mapp t1 (i (b_typ x)) then do
                    let (err_string, new_map, bindings) = typeCheckBindings classes ln (Data.Map.insert (i (b_variable x)) (i (b_typ x)) mapp) xs
                    (err_string, new_map, (x {b_value = value_new}):bindings)
                else ("ERROR: "++(read $ show ln)++": Type-Check: Binding init doesn't conform", mapp, []) 
            else (err_string, mapp, [])
        _ -> typeCheckBindings classes ln mapp xs

-- Type check case statement elements
typeCheckCaseElements :: [Class] -> Map String String -> [Case_Element] -> [String] -> [String] -> (String, [String], [Case_Element])
typeCheckCaseElements classes mapp [] b_types r_types = ("", r_types, [])
typeCheckCaseElements classes mapp (x:xs) b_types r_types = do
    if (elem (i (c_typ x)) b_types) then ("ERROR: "++(read $ show (i_ln (c_typ x)))++": Type-Check: Case statement with same type "++(i (c_typ x)), [], [])
    else do
        let new_map = Data.Map.insert (i (c_variable x)) (i (c_typ x)) mapp
        let (err_string, typp1, body_new) = typeCheckExpr classes new_map (c_body x)
        if err_string == "" then do
            let (err_string, typs, ces) = typeCheckCaseElements classes mapp xs ((i (c_typ x)):b_types) (typp1:r_types)
            (err_string, typs, (x {c_body = (body_new {e_type = typp1})}):ces)
        else (err_string, [], [])

-- Check identifier to verify it is known
checkIdentifier :: Map String String -> Identifier -> (String, String)
checkIdentifier mapp ident = do
    if (member (i ident) mapp) then ("", Data.Map.findWithDefault "error" (i ident) mapp)
    else ("ERROR: "++(read $ show (i_ln ident))++": Type-Check: Unknown Identifier", "")
