module Serealizer where
import AST_nodes
import Check_misc

-- create an implementation map, returned as a list of strings
createImplementationMap :: [Class] -> [String]
createImplementationMap [] = []
createImplementationMap (x:xs) = (outputImplementationClass x)++(createImplementationMap xs)

-- serialize a class in the implementation map
outputImplementationClass :: Class -> [String]
outputImplementationClass clas = [(i (c_name clas)),(show (length (getMethods (features clas))))]++(outputImplementationMethods (getMethods (features clas)))

-- serialize a list of features
strAttributes :: [Feature] -> [String]
strAttributes [] = []
strAttributes (x:xs) = do
    case x of
        Attr_No_Init a b c -> ["no_initializer",(i (f_name x)),(i (f_type x))]++(strAttributes xs)
        Attr_Init a b c d -> ["initializer",(i (f_name x)),(i (f_type x))]++(outputExpr (f_init x))++(strAttributes xs)
        _ -> strAttributes xs

-- serialize the methods in an implementation map
outputImplementationMethods :: [Feature] -> [String]
outputImplementationMethods [] = []
outputImplementationMethods (x:xs) = do
    let obj_meth = (f_definer x)++"."++(i (f_name x))
    if elem obj_meth ["Object.abort", "Object.type_name", "Object.copy", "IO.out_string", "IO.out_int", "IO.in_string", "IO.in_int", "String.length", "String.concat", "String.substr"] then
        [(i (f_name x)), (show (length (f_formals x)))]++(outputImplementationFormals (f_formals x))++[(f_definer x)]++["0", (i (f_type x)), "internal", obj_meth]++(outputImplementationMethods xs)
    else [(i (f_name x)), (show (length (f_formals x)))]++(outputImplementationFormals (f_formals x))++[(f_definer x)]++(outputExpr (f_body x))++(outputImplementationMethods xs)

-- serialize the formal methods in an implementation map
outputImplementationFormals :: [Formal] -> [String]
outputImplementationFormals [] = []
outputImplementationFormals (x:xs) = (i (fo_name x)):(outputImplementationFormals xs)


-- produce serialized identifier
outputID :: Identifier -> [String]
outputID ident = [i_ln ident, i ident]

-- produce serialized list of annotated expressions
outputExprList :: [Expression] -> [String]
outputExprList [] = []
outputExprList (x:xs) = (outputExpr x)++(outputExprList xs)

-- produce serialized let binding
outputBinding :: Binding -> [String]
outputBinding bi = do
    case bi of
        Binding_No_Init a b -> ["let_binding_no_init"]++(outputID (b_variable bi))++(outputID (b_typ bi))
        Binding_Init a b c -> ["let_binding_init"]++(outputID (b_variable bi))++(outputID (b_typ bi))++(outputExpr (b_value bi))
        _ -> ["error"]

-- produce serialized list of let bindings
outputBindingList :: [Binding] -> [String]
outputBindingList [] = []
outputBindingList (x:xs) = (outputBinding x)++(outputBindingList xs)

-- produce serialized case element
outputCaseElement :: Case_Element -> [String]
outputCaseElement ce = (outputID (c_variable ce))++(outputID (c_typ ce))++(outputExpr (c_body ce))

-- produce serialized list of case elements
outputCaseElements :: [Case_Element] -> [String]
outputCaseElements [] = []
outputCaseElements (x:xs) = (outputCaseElement x)++(outputCaseElements xs)

-- Produced a serialized, annotated expression
outputExpr :: Expression -> [String]
outputExpr ex = do
    case ex of
        E_Assign a1 a2 a3 a4 -> [e_ln ex, e_type ex, "assign"]++(outputID (var ex))++(outputExpr (rhs ex))
        E_Dynamic_Dispatch a1 a2 a3 a4 a5 -> [e_ln ex, e_type ex, "dynamic_dispatch"]++(outputExpr (e ex))++(outputID (method ex))++[(show (length (args ex)))]++(outputExprList (args ex))
        E_Static_Dispatch a1 a2 a3 a4 a5 a6 -> [e_ln ex, e_type ex, "static_dispatch"]++(outputExpr (e ex))++(outputID (typ ex))++(outputID (method ex))++[(show (length (args ex)))]++(outputExprList (args ex))
        E_Self_Dispatch a1 a2 a3 a4 -> [e_ln ex, e_type ex, "self_dispatch"]++(outputID (method ex))++[(show (length (args ex)))]++(outputExprList (args ex))
        E_If a1 a2 a3 a4 a5 -> [e_ln ex, e_type ex, "if"]++(outputExpr (predicate ex))++(outputExpr (thenn ex))++(outputExpr (elsee ex))
        E_While a1 a2 a3 a4 -> [e_ln ex, e_type ex, "while"]++(outputExpr (predicate ex))++(outputExpr (body ex))
        E_Block a1 a2 a3 -> [e_ln ex, e_type ex, "block", (show (length (bodies ex)))]++(outputExprList (bodies ex))
        E_New a1 a2 a3 -> [e_ln ex, e_type ex, "new"]++(outputID (clas ex))
        E_Isvoid a1 a2 a3 -> [e_ln ex, e_type ex, "isvoid"]++(outputExpr (e ex))
        E_Plus a1 a2 a3 a4 -> [e_ln ex, e_type ex, "plus"]++(outputExpr (x ex))++(outputExpr (y ex))
        E_Minus a1 a2 a3 a4 -> [e_ln ex, e_type ex, "minus"]++(outputExpr (x ex))++(outputExpr (y ex))
        E_Times a1 a2 a3 a4 -> [e_ln ex, e_type ex, "times"]++(outputExpr (x ex))++(outputExpr (y ex))
        E_Divide a1 a2 a3 a4 -> [e_ln ex, e_type ex, "divide"]++(outputExpr (x ex))++(outputExpr (y ex))
        E_Lt a1 a2 a3 a4 -> [e_ln ex, e_type ex, "lt"]++(outputExpr (x ex))++(outputExpr (y ex))
        E_Le a1 a2 a3 a4 -> [e_ln ex, e_type ex, "le"]++(outputExpr (x ex))++(outputExpr (y ex))
        E_Eq a1 a2 a3 a4 -> [e_ln ex, e_type ex, "eq"]++(outputExpr (x ex))++(outputExpr (y ex))
        E_Not a1 a2 a3 -> [e_ln ex, e_type ex, "not"]++(outputExpr (x ex))
        E_Negate a1 a2 a3 -> [e_ln ex, e_type ex, "negate"]++(outputExpr (x ex))
        E_Integer a1 a2 a3 -> [e_ln ex, e_type ex, "integer", i_const ex]
        E_String a1 a2 a3 -> [e_ln ex, e_type ex, "string", s_const ex]
        E_Identifier a1 a2 a3 -> [e_ln ex, e_type ex, "identifier"]++(outputID (var ex))
        E_True a1 a2 -> [e_ln ex, e_type ex, "true"]
        E_False a1 a2 -> [e_ln ex, e_type ex, "false"]
        E_Let a1 a2 a3 a4 -> [e_ln ex, e_type ex, "let", (show (length (bindings ex)))]++(outputBindingList (bindings ex))++(outputExpr (body ex))
        E_Case a1 a2 a3 a4 -> [e_ln ex, e_type ex, "case"]++(outputExpr (expr ex))++[(show (length (case_elements ex)))]++(outputCaseElements (case_elements ex))
        _ -> ["error"]

-- return the number of attributes in a list of features
lenAttributes :: [Feature] -> Int
lenAttributes [] = 0
lenAttributes (x:xs) = do
    case x of
        Attr_No_Init a b c -> 1 + lenAttributes xs
        Attr_Init a b c d -> 1 + lenAttributes xs
        _ -> lenAttributes xs

-- Serialize a list of classes into the class map
createClassMap :: [Class] -> [String]
createClassMap [] = []
createClassMap (x:xs) = [(i (c_name x)), show (lenAttributes (features x))]++(strAttributes (features x))++(createClassMap xs)

-- Serialize the parent map
createParentMap :: [Class] -> [String]
createParentMap [] = []
createParentMap (x:xs) = do
    case x of
        Class_Non_Inh a b -> (createParentMap xs)
        Class_Inh a b c d -> [i (c_name x), (i (inherited x))]++(createParentMap xs)
        _ -> []

-- Generate the annotated ast from a list of classes, return the aast as a list of strings
createAnnotatedAST :: [Class] -> [String]
createAnnotatedAST classes = (show (length classes)):(outputAnnotatedClassList classes)

--Generaete aast for a list of classes
outputAnnotatedClassList :: [Class] -> [String]
outputAnnotatedClassList [] = []
outputAnnotatedClassList (x:xs) = do
    case x of
        Class_Non_Inh a b -> (outputID (c_name x))++["no_inherits", (show (length (features x)))]++((outputAnnotatedFeatures (features x))++(outputAnnotatedClassList xs))
        Class_Inh a b c d -> do
            if (i (inherited x)) == "Object" && (obj_inh x) then (outputID (c_name x))++["no_inherits",(show (length (features x)))]++((outputAnnotatedFeatures (features x))++(outputAnnotatedClassList xs))
            else (outputID (c_name x))++("inherits":(outputID (inherited x))++[(show (length (features x)))]++((outputAnnotatedFeatures (features x))++(outputAnnotatedClassList xs)))
        _ -> []

-- Generate the aast for a list of features
outputAnnotatedFeatures :: [Feature] -> [String]
outputAnnotatedFeatures [] = []
outputAnnotatedFeatures (x:xs) = do
    case x of
        Attr_No_Init a b c -> "attribute_no_init":((outputID (f_name x))++(outputID (f_type x)))++(outputAnnotatedFeatures xs)
        Attr_Init a b c d -> "attribute_init":((outputID (f_name x))++(outputID (f_type x))++(outputExpr (f_init x)))++(outputAnnotatedFeatures xs)
        Method a b c d e -> "method":((outputID (f_name x))++[(show (length (f_formals x)))]++(outputAnnotatedFormals (f_formals x))++(outputID (f_type x))++(outputExpr (f_body x)))++(outputAnnotatedFeatures xs)
        _ -> []

-- Generate the aast for a list of formals
outputAnnotatedFormals :: [Formal] ->[String]
outputAnnotatedFormals [] = []
outputAnnotatedFormals (x:xs) = (outputID (fo_name x))++(outputID (fo_type x))++(outputAnnotatedFormals xs)

-- Remove inherited features from each class in a list of classes
takeOutInheritanceFromClasses :: [Class] -> [Class]
takeOutInheritanceFromClasses [] = []
takeOutInheritanceFromClasses (x:xs) | elem (i (c_name x)) ["Object", "IO", "Int", "String", "Bool"]= takeOutInheritanceFromClasses xs
takeOutInheritanceFromClasses (x:xs) = (takeOutInheritanceFromClass x):(takeOutInheritanceFromClasses xs)

-- Remove inherited features from a specific class
takeOutInheritanceFromClass :: Class -> Class
takeOutInheritanceFromClass clas = clas {features = (takeOutInheritance (i (c_name clas)) (features clas))}

-- remove inherited features, the first parameter is the class name and the second is the list of features. The list of features with inherited parameters removed is returned
takeOutInheritance :: String -> [Feature] -> [Feature]
takeOutInheritance clas [] = []
takeOutInheritance clas (x:xs) | (f_definer x) == clas = x:(takeOutInheritance clas xs)
takeOutInheritance clas (x:xs) = takeOutInheritance clas xs

-- Reorder features so inherited features are at the top for a list of classes
reOrderClassFeats :: [Class] -> [Class] -> [Class]
reOrderClassFeats [] [] = []
reOrderClassFeats (bx:bxs) (x:xs) = (x { features = (reOrderFeats (features bx) (features x)) }):(reOrderClassFeats bxs xs)

-- Reorder a list of features so the inherited features are at the top. The first list is the parents features and the second is the childs
reOrderFeats :: [Feature] -> [Feature] -> [Feature]
reOrderFeats [] [] = []
reOrderFeats (bx:bxs) mine = do
    case bx of
        Attr_No_Init a b c -> (getAttr mine (i (f_name bx))):(reOrderFeats bxs (removeAttr mine (i (f_name bx))))
        Attr_Init a b c d -> (getAttr mine (i (f_name bx))):(reOrderFeats bxs (removeAttr mine (i (f_name bx))))
        Method a b c d e -> (getMeth mine (i (f_name bx))):(reOrderFeats bxs (removeMeth mine (i (f_name bx))))
        _ -> []

-- Remove an attribute from a list of features
removeAttr :: [Feature] -> String -> [Feature]
removeAttr [] feat = []
removeAttr (x:xs) feat = do
    case x of
        Attr_No_Init a b c -> do
            if (i (f_name x)) == feat then removeAttr xs feat
            else x:(removeAttr xs feat)
        Attr_Init a b c d -> do
            if (i (f_name x)) == feat then removeAttr xs feat
            else x:(removeAttr xs feat)
        _ -> x:(removeAttr xs feat)

-- retrieve an attribute from a list of features
getAttr :: [Feature] -> String -> Feature
getAttr [] feat = Feat_Error {f_error = "not found"}
getAttr (x:xs) feat = do
    case x of
        Attr_No_Init a b c -> do
            if (i (f_name x)) == feat then x
            else getAttr xs feat
        Attr_Init a b c d -> do
            if (i (f_name x)) == feat then x
            else getAttr xs feat
        _ -> getAttr xs feat