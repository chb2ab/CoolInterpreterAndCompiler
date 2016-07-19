module Check_misc where
import Data.Ord
import Data.List
import AST_nodes

-- Check the miscellaneous type rules not covered in the typing rules for expressions
checkClassesForError1 :: [Class] -> String
checkClassesForError1 classes = do
    let names = [(i (c_name x)) | x <- classes]
    let names_ln = [(i_ln (c_name x)) | x <- classes]
    let err_string = checkValidInh names classes
    if err_string == "" then do
        let err_string = checkForMainMethod classes classes
        if err_string == "" then do
            -- Check that a class doesn't redefine a method
            let err_string = checkForRedefiningOwnThing classes
            if err_string == "" then do
                -- Check for properly named classes
                let err_string = checkDups ("0":names_ln) ("SELF_TYPE":names) []
                if err_string == "" then do
                    let err_string = checkForCycles classes classes
                    if err_string == "" then do
                        let err_string = checkRedefinitionAttr classes classes
                        if err_string == "" then do
                            let err_string = checkDuplicateParams classes
                            if err_string == "" then do
                                let err_string = checkRedefinitionMeth classes classes
                                if err_string == "" then do
                                    let err_string = checkForUnknownTypeAndself classes names
                                    if err_string == "" then
                                        ""
                                    else
                                        err_string
                                else
                                    err_string
                            else
                                err_string
                        else
                            err_string
                    else
                        err_string
                else
                    err_string
            else
                err_string
        else
            err_string
    else
        err_string

-- Check that all inheritances are valid
checkValidInh :: [String] -> [Class] -> String
checkValidInh names [] = ""
checkValidInh names (x:xs) = do
    case x of
        Class_Non_Inh a b -> checkValidInh names xs
        Class_Inh a b c d -> do
            if (elem (i (inherited x)) names) then
                if (elem (i (inherited x)) ["Bool", "String", "Int"]) then
                    "ERROR: "++(read $ show (i_ln (inherited x)))++": Type-Check: Inheriting from bool, string, or int"
                else checkValidInh names xs
            else
                "ERROR: "++(read $ show (i_ln (inherited x)))++": Type-Check: Inheriting from unknown class"
        _ -> checkValidInh names xs

-- Check that main method is well defined
checkForMainMethod :: [Class] -> [Class] -> String
checkForMainMethod classes [] = "ERROR: 0: Type-Check: No Main class"
checkForMainMethod classes (x:xs) | (i (c_name x)) == "Main" = checkMain (getParentsMeth classes x)
checkForMainMethod classes (x:xs) = checkForMainMethod classes xs

-- Check that main method exists with 0 parameters
checkMain :: [Feature] -> String
checkMain [] = "ERROR: 0: Type-Check: No main method with 0 params"
checkMain (x:xs) = do
    case x of
        Method a b c d e -> do
            if (i (f_name x)) == "main" && (length (f_formals x)) == 0 then
                ""
            else checkMain xs
        _ -> checkMain xs

-- Get inherited methods
getParentsMeth :: [Class] -> Class -> [Feature]
getParentsMeth classes clas = do
    case clas of
        Class_Non_Inh a b -> (getMethods (features (lookFor classes "Object")))++getMethods (features clas)
        Class_Inh a b c d ->  (getParentsMeth classes (getParent classes clas))++(getMethods (features clas))
        _ -> []

-- Check if a class in a list of classes redefines one of its methods
checkForRedefiningOwnThing :: [Class] -> String
checkForRedefiningOwnThing [] = ""
checkForRedefiningOwnThing (x:xs) = do
    let err_string = checkForRedefiningOwnThingClass x
    if err_string == "" then
        checkForRedefiningOwnThing xs
    else err_string

-- Check a specific class if it redefines one of its methods
checkForRedefiningOwnThingClass :: Class -> String
checkForRedefiningOwnThingClass clas = do
    let attr = getAttributes (features clas)
    let err_string = checkDups [(i_ln (f_name atr)) | atr <- attr] [(i (f_name atr)) | atr <- attr] []
    if err_string == "" then do
        let methods = getMethods (features clas)
        checkDups [(i_ln (f_name meth)) | meth <- methods] [(i (f_name meth)) | meth <- methods] []
    else err_string

-- Compare a list of strings to see if one string is contained in the other list. Also passes in a list of line numbers for error reporting
checkDups :: [String] -> [String] -> [String] -> String
checkDups [] [] x = ""
checkDups (x_ln:xs_ln) (x:xs) prev | (elem x prev) && (elem x ["Object", "IO", "Int", "String", "Bool", "SELF_TYPE"]) = "ERROR: "++(read $ show x_ln)++": Type-Check: Can't redefine a default class"
checkDups (x_ln:xs_ln) (x:xs) prev | (elem x prev) = "ERROR: "++(read $ show x_ln)++": Type-Check: Multiple definitions of a something"
checkDups (x_ln:xs_ln) (x:xs) prev = checkDups xs_ln xs (x:prev)

-- Check for inheritance cycle by visiting each class, traveling up its inheritance hierarchy, and seeing if a class gets visited repeatedly
checkForCycles :: [Class] -> [Class] -> String
checkForCycles classes [] = ""
checkForCycles classes (x:xs) | checkCycle classes [] x = "ERROR: 0: Type-Check: Inheritance cycle"
checkForCycles classes (x:xs) = checkForCycles classes xs

-- Check specific class to see if it is in a cycle, if it is return True
checkCycle :: [Class] -> [String] -> Class -> Bool
checkCycle classes visited current = do
    case current of
        Class_Non_Inh a b -> False
        Class_Inh a b c d -> do
            if (elem (i (inherited current)) visited) then
                True
            else
                checkCycle classes ((i (c_name current)):visited) (getParent classes current)
        _ -> False
-- Get the parent of a class
getParent :: [Class] -> Class -> Class
getParent classes current = do
    case current of 
        Class_Non_Inh a b -> lookFor classes "Object"
        Class_Inh a b c d -> lookFor classes (i (inherited current))
        _ -> (Class_Err {err = "error"})

-- Check if a class redefines an attribute
checkRedefinitionAttr :: [Class] -> [Class] -> String
checkRedefinitionAttr classes [] = ""
checkRedefinitionAttr classes (x:xs) = do
    let parAttr = getParentsAttr classes (getParent classes x)
    let parAttrNames = [(i (f_name atr)) | atr <- parAttr]
    let myAttr = getAttributes (features x)
    let err_string = uniqueAttr parAttrNames myAttr
    if err_string == "" then
        checkRedefinitionAttr classes xs
    else
        err_string
-- get the attributes of the parent class
getParentsAttr :: [Class] -> Class -> [Feature]
getParentsAttr classes clas = do
    case clas of
        Class_Non_Inh a b -> getAttributes (features clas)
        Class_Inh a b c d ->  (getParentsAttr classes (getParent classes clas))++(getAttributes (features clas))
        _ -> []

-- get the unique attributes of parent class
uniqueAttr :: [String] -> [Feature] -> String
uniqueAttr parents [] = ""
uniqueAttr parents (x:xs) | elem (i (f_name x)) parents =  "ERROR: "++(read $ show (i_ln (f_name x)))++": Type-Check: Redefining Attribute"
uniqueAttr parents (x:xs) = uniqueAttr parents xs

-- Check for duplicated formal parameter in method definition
checkDuplicateParams :: [Class] -> String
checkDuplicateParams [] = ""
checkDuplicateParams (x:xs) = do
    let err_string = cdp (features x)
    if err_string == "" then
        checkDuplicateParams xs
    else err_string

-- Check for duplicated parameter in method definition
cdp :: [Feature] -> String
cdp [] = ""
cdp (x:xs) = do
    case x of
        Method a b c d e -> do
            let err_string = checkDups [(i_ln (fo_name f)) | f <- (f_formals x)] [(i (fo_name f)) | f <- (f_formals x)] []
            if err_string == "" then
                cdp xs
            else err_string
        _ -> cdp xs

-- look for a class
lookFor :: [Class] -> String -> Class
lookFor [] nm = (Class_Err {err = "error"})
lookFor (x:xs) nm | (i (c_name x)) == nm = x
lookFor (x:xs) nm = lookFor xs nm

-- get the attributes from a list of features
getAttributes :: [Feature] -> [Feature]
getAttributes [] = []
getAttributes (x:xs) = do
    case x of
        Attr_No_Init a b c -> x:(getAttributes xs)
        Attr_Init a b c d ->  x:(getAttributes xs)
        _ -> getAttributes xs

-- get initialized attributes from a list of features
getInitAttributes :: [Feature] -> [Feature]
getInitAttributes [] = []
getInitAttributes (x:xs) = do
    case x of
        Attr_Init a b c d ->  x:(getInitAttributes xs)
        _ -> getInitAttributes xs

-- get the methods from a list of methods
getMethods :: [Feature] -> [Feature]
getMethods [] = []
getMethods (x:xs) = do
    case x of
        Method a b c d e -> x:(getMethods xs)
        _ -> getMethods xs

-- get a specific method in a list of methods
getMethod :: [Feature] -> String -> Feature
getMethod [] nme = Feat_Error {f_error = "error"}
getMethod (x:xs) nme = do
    case x of
        Method a b c d e -> do
            if (i (f_name x)) == nme then x
            else getMethod xs nme
        _ -> getMethod xs nme

-- Check if a method is redefined improperly
checkRedefinitionMeth :: [Class] -> [Class] -> String
checkRedefinitionMeth classes [] = ""
checkRedefinitionMeth classes (x:xs) = do
    let parMeth = (getParentsMeth classes (getParent classes x))
    let myMeth = getMethods (features x)
    let err_string = compareMethods parMeth myMeth
    if err_string == "" then
        checkRedefinitionMeth classes xs
    else
        err_string

-- Compare parents and childs methods to verify a method is not improperly redefined
compareMethods :: [Feature] -> [Feature] -> String
compareMethods parents [] = ""
compareMethods parents (x:xs) = do
    let err_string = compareMethod parents x
    if err_string == "" then
        compareMethods parents xs
    else err_string

-- Compare a specific method out of the childs methods to all of the parents methods
compareMethod :: [Feature] -> Feature -> String
compareMethod [] feat = ""
compareMethod (x:xs) feat | (i (f_name x)) == (i (f_name feat)) = methodCompare x feat
compareMethod (x:xs) feat = compareMethod xs feat

-- Compare a redefined method to see if it is redefined correctly
methodCompare :: Feature -> Feature -> String
methodCompare f1 f2 = do
    if (length (f_formals f1)) == (length (f_formals f2)) then
        if (i (f_type f1)) == (i (f_type f2)) then
            compareFormals (f_formals f1) (f_formals f2)
        else "ERROR: "++(read $ show (i_ln (f_type f2)))++": Type-Check: Redefined method with different return type"
    else "ERROR: "++(read $ show (i_ln (f_name f2)))++": Type-Check: Redefined method with different number of attributes"

-- Compare formal parameters of method to see if it is redefined correctly
compareFormals :: [Formal] -> [Formal] -> String
compareFormals [] [] = ""
compareFormals (x1:xs1) (x2:xs2) | (i (fo_type x1)) == (i (fo_type x2)) = compareFormals xs1 xs2
compareFormals (x1:xs1) (x2:xs2) = "ERROR: "++(read $ show (i_ln (fo_name x2)))++": Type-Check: Redefined method with different types"

-- Check for the use of an unknown type and the incorrect use of the self identifier, return an error string if found
checkForUnknownTypeAndself :: [Class] -> [String] -> String
checkForUnknownTypeAndself [] types = ""
checkForUnknownTypeAndself (x:xs) types = do
    let err_str = checkUnknownTypeFeaturesAndself (features x) types
    if err_str == "" then checkForUnknownTypeAndself xs types
    else err_str

-- Check a list of formals for unknown type or incorrect self usage
checkUnknownTypeFormalsAndself :: [Formal] -> [String] -> String
checkUnknownTypeFormalsAndself [] types = ""
checkUnknownTypeFormalsAndself (x:xs) types = do
    if (i (fo_name x)) == "self" then "ERROR: "++(read $ show (i_ln (fo_name x)))++": Type-Check: Formal parameter named self"
    else do
        if elem (i (fo_type x)) types then
            checkUnknownTypeFormalsAndself xs types
        else "ERROR: "++(read $ show (i_ln (fo_type x)))++": Type-Check: Formal parameter with unknown type"

-- Check case elements for unknown type or incorrect self usage
checkUnknownTypeCaseElementsAndself :: [Case_Element] -> [String] -> String
checkUnknownTypeCaseElementsAndself [] types = ""
checkUnknownTypeCaseElementsAndself (x:xs) types = do
    if (i (c_variable x)) == "self" then "ERROR: "++(read $ show (i_ln (c_variable x)))++": Type-Check: Case element named self"
    else do
        if elem (i (c_typ x)) types then do
            let err_str = checkUnknownTypeExprAndself (c_body x) types
            if err_str == "" then checkUnknownTypeCaseElementsAndself xs types
            else err_str
        else "ERROR: "++(read $ show (i_ln (c_typ x)))++": Type-Check: Case element with unknown type"

-- Check let bindings for unknown type or incorrect self usage
checkUnknownTypeBindingsAndself :: [Binding] -> [String] -> String
checkUnknownTypeBindingsAndself [] types = ""
checkUnknownTypeBindingsAndself (x:xs) types = do
    if (i (b_variable x)) == "self" then "ERROR: "++(read $ show (i_ln (b_variable x)))++": Type-Check: Let binding named self"
    else do
        case x of
            Binding_No_Init a b -> do
                if elem (i (b_typ x)) (types++["SELF_TYPE"]) then
                    checkUnknownTypeBindingsAndself xs types
                else "ERROR: "++(read $ show (i_ln (b_typ x)))++": Type-Check: Let binding with unknown type"
            Binding_Init a b c -> do
                if elem (i (b_typ x)) (types++["SELF_TYPE"]) then do
                    let err_string = checkUnknownTypeExprAndself (b_value x) types
                    if err_string == "" then checkUnknownTypeBindingsAndself xs types
                    else err_string
                else "ERROR: "++(read $ show (i_ln (b_typ x)))++": Type-Check: Let binding with unknown type"
            _ -> checkUnknownTypeBindingsAndself xs types

-- Check expressions for unknown type or incorrect self usage
checkUnknownTypeExprAndself :: Expression -> [String] -> String
checkUnknownTypeExprAndself ex types = do
    case ex of
        E_Assign a1 a2 a3 a4 -> do
            if (i (var ex)) == "self" then "ERROR: "++(read $ show (i_ln (var ex)))++": Type-Check: Can't assign to self"
            else checkUnknownTypeExprAndself (rhs ex) types
        E_Dynamic_Dispatch a1 a2 a3 a4 a5 -> do
            let err_string = checkUnknownTypeExprAndself (e ex) types
            if err_string == "" then checkUnknownTypeExprsAndself (args ex) types
            else err_string
        E_Static_Dispatch a1 a2 a3 a4 a5 a6 -> do 
            if elem (i (typ ex)) types then do
                let err_string = checkUnknownTypeExprAndself (e ex) types
                if err_string == "" then checkUnknownTypeExprsAndself (args ex) types
                else err_string
            else "ERROR: "++(read $ show (i_ln (typ ex)))++": Type-Check: static dispatch with unknown type"
        E_Self_Dispatch a1 a2 a3 a4 -> checkUnknownTypeExprsAndself (args ex) types
        E_If a1 a2 a3 a4 a5 -> do
            let err_string = checkUnknownTypeExprAndself (predicate ex) types
            if err_string == "" then do
                let err_string = checkUnknownTypeExprAndself (thenn ex) types
                if err_string == "" then checkUnknownTypeExprAndself (elsee ex) types
                else err_string
            else err_string
        E_While a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeExprAndself (predicate ex) types
            if err_string == "" then checkUnknownTypeExprAndself (body ex) types
            else err_string
        E_Block a1 a2 a3 -> (checkUnknownTypeExprsAndself (bodies ex) types)
        E_New a1 a2 a3 -> do
            if elem (i (clas ex)) (types++["SELF_TYPE"]) then ""
            else "ERROR: "++(read $ show (i_ln (clas ex)))++": Type-Check: new with unknown type"
        E_Isvoid a1 a2 a3 -> (checkUnknownTypeExprAndself (e ex) types)
        E_Plus a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeExprAndself (x ex) types
            if err_string == "" then checkUnknownTypeExprAndself (y ex) types
            else err_string
        E_Minus a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeExprAndself (x ex) types
            if err_string == "" then checkUnknownTypeExprAndself (y ex) types
            else err_string
        E_Times a1 a2 a3 a4 ->  do
            let err_string = checkUnknownTypeExprAndself (x ex) types
            if err_string == "" then checkUnknownTypeExprAndself (y ex) types
            else err_string
        E_Divide a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeExprAndself (x ex) types
            if err_string == "" then checkUnknownTypeExprAndself (y ex) types
            else err_string
        E_Lt a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeExprAndself (x ex) types
            if err_string == "" then checkUnknownTypeExprAndself (y ex) types
            else err_string
        E_Le a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeExprAndself (x ex) types
            if err_string == "" then checkUnknownTypeExprAndself (y ex) types
            else err_string
        E_Eq a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeExprAndself (x ex) types
            if err_string == "" then checkUnknownTypeExprAndself (y ex) types
            else err_string
        E_Not a1 a2 a3 -> (checkUnknownTypeExprAndself (x ex) types)
        E_Negate a1 a2 a3 -> (checkUnknownTypeExprAndself (x ex) types)
        E_Let a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeBindingsAndself (bindings ex) types
            if err_string == "" then checkUnknownTypeExprAndself (body ex) types
            else err_string
        E_Case a1 a2 a3 a4 -> do
            let err_string = checkUnknownTypeExprAndself (expr ex) types
            if err_string == "" then checkUnknownTypeCaseElementsAndself (case_elements ex) types
            else err_string
        _ -> ""

-- Check a list of expressions for unknown type or incorrect self usage
checkUnknownTypeExprsAndself :: [Expression] -> [String] -> String
checkUnknownTypeExprsAndself [] types = ""
checkUnknownTypeExprsAndself (x:xs) types = do
    let err_string = checkUnknownTypeExprAndself x types
    if err_string == "" then checkUnknownTypeExprsAndself xs types
    else err_string

-- Check a list of features for unknown type or incorrect self usage
checkUnknownTypeFeaturesAndself :: [Feature] -> [String] -> String
checkUnknownTypeFeaturesAndself [] types = ""
checkUnknownTypeFeaturesAndself (x:xs) types = do
    case x of
        Method a b c d e -> do
            if elem (i (f_type x)) (types++["SELF_TYPE"]) then do
                let err_string = checkUnknownTypeFormalsAndself (f_formals x) types
                if err_string == "" then do 
                    let err_string = checkUnknownTypeExprAndself (f_body x) types
                    if err_string == "" then checkUnknownTypeFeaturesAndself xs types
                    else err_string
                else err_string
            else "ERROR: "++(read $ show (i_ln (f_type x)))++": Type-Check: Method with unknown return type"++(i (f_type x))
        _ -> do
            if (i (f_name x)) == "self" then "ERROR: "++(read $ show (i_ln (f_name x)))++": Type-Check: Attribute named self"
            else do
                if elem (i (f_type x)) (types++["SELF_TYPE"]) then
                    checkUnknownTypeFeaturesAndself xs types
                else "ERROR: "++(read $ show (i_ln (f_type x)))++": Type-Check: Attribute with unknown type"


-- Populate the inherited features for a list of classes
populateInheritances :: [Class] -> [Class] -> [Class]
populateInheritances classes [] = []
populateInheritances classes (x:xs) = (populateInheritance classes x):(populateInheritances classes xs)

-- Populate the inherited features for a given class
populateInheritance :: [Class] -> Class -> Class
populateInheritance classes clas = do
    case clas of
        Class_Non_Inh a b -> clas
        Class_Inh a b c d -> do
            let par = populateInheritance classes (getParent classes clas)
            let parAttr = features par
            let combined = combineAttr parAttr (features clas)
            let updated = clas {features = combined}
            updated

-- Get parents attributes and methods for a given class
getParentsAttrAndMeth :: [Class] -> Class -> [Feature]
getParentsAttrAndMeth classes clas = do
    case clas of
        Class_Non_Inh a b -> features clas
        Class_Inh a b c d -> (getParentsAttrAndMeth classes (getParent classes clas))++(features clas)


-- Combine attributes of parent and child. the first list is the parents attributes and the second is the childs. The child overrides the parents when an attribute is redefined
combineAttr :: [Feature] -> [Feature] -> [Feature]
combineAttr [] mine = mine
combineAttr (px:pxs) mine = do
    case px of
        Method a b c d e -> do
            if containsMeth mine px then
                (getMeth mine (i (f_name px))):(combineAttr pxs (removeMeth mine (i (f_name px))))
            else px:(combineAttr pxs mine)
        _ -> px:(combineAttr pxs mine)

-- Check if a least of features contains a specific method
containsMeth :: [Feature] -> Feature -> Bool
containsMeth [] feat = False
containsMeth (x:xs) feat = do
    case x of
        Method a b c d e -> do
            if (i (f_name x)) == (i (f_name feat)) then True
            else containsMeth xs feat
        _ -> containsMeth xs feat

-- Remove a method from a list of features
removeMeth :: [Feature] -> String -> [Feature]
removeMeth [] feat = []
removeMeth (x:xs) feat = do
    case x of
        Method a b c d e -> do
            if (i (f_name x)) == feat then removeMeth xs feat
            else x:(removeMeth xs feat)
        _ -> x:(removeMeth xs feat)

-- Get a method from a list of methods
getMeth :: [Feature] -> String -> Feature
getMeth [] feat = Feat_Error {f_error = "not found"}
getMeth (x:xs) feat = do
    case x of
        Method a b c d e -> do
            if (i (f_name x)) == feat then x
            else getMeth xs feat
        _ -> getMeth xs feat

-- Sort classes by name
instance Ord Identifier where
    compare x y = compare (i x) (i y)
sortClassesByName :: [Class] -> [Class]
sortClassesByName = sortBy (comparing c_name)

-- split a string on a delimeter
splitArg :: String -> String
splitArg "" = ""
splitArg (x:xs) | x == '.' = ""
splitArg (x:xs) = x:(splitArg xs)

-- Add default classes to a list of classes
addDefaultClasses :: [Class] -> [Class]
addDefaultClasses x = [(Class_Non_Inh {c_name = Identifier {i_ln = "0", i = "Object"}, features = [Method {f_definer = "Object", f_name = Identifier {i_ln = "0", i = "abort"}, f_formals = [], f_type = Identifier {i_ln = "0", i = "Object"}, f_body = E_String {e_type = "", e_ln = "0", s_const = "abort body placeholder"}}, Method {f_definer = "Object", f_name = Identifier {i_ln = "0", i = "copy"}, f_formals = [], f_type = Identifier {i_ln = "0", i = "SELF_TYPE"}, f_body = E_Identifier {e_type = "", e_ln = "0", var = Identifier {i = "self", i_ln = "0"}}}, Method {f_definer = "Object", f_name = Identifier {i_ln = "0", i = "type_name"}, f_formals = [], f_type = Identifier {i_ln = "0", i = "String"}, f_body = E_String {e_type = "", e_ln = "0", s_const = "type_name body placeholder"}}]}), (Class_Inh {c_name = Identifier {i_ln = "0", i = "IO"}, inherited = Identifier {i_ln = "0", i = "Object"}, features = [Method {f_definer = "IO", f_name = Identifier {i_ln = "0", i = "in_int"}, f_formals = [], f_type = Identifier {i_ln = "0", i = "Int"}, f_body = E_Integer {e_type = "", e_ln = "0", i_const = "in_int body placeholder"}}, Method {f_definer = "IO", f_name = Identifier {i_ln = "0", i = "in_string"}, f_formals = [], f_type = Identifier {i_ln = "0", i = "String"}, f_body = E_String {e_type = "", e_ln = "0", s_const = "in_string body placeholder"}}, Method {f_definer = "IO", f_name = Identifier {i_ln = "0", i = "out_int"}, f_formals = [Formal {fo_name = Identifier {i_ln = "0", i = "x"}, fo_type = Identifier {i_ln = "0", i = "Int"}}], f_type = Identifier {i_ln = "0", i = "SELF_TYPE"}, f_body = E_Identifier {e_type = "", e_ln = "0", var = Identifier {i = "self", i_ln = "0"}}}, Method {f_definer = "IO", f_name = Identifier {i_ln = "0", i = "out_string"}, f_formals = [Formal {fo_name = Identifier {i_ln = "0", i = "x"}, fo_type = Identifier {i_ln = "0", i = "String"}}], f_type = Identifier {i_ln = "0", i = "SELF_TYPE"}, f_body = E_Identifier {e_type = "", e_ln = "0", var = Identifier {i = "self", i_ln = "0"}}}], obj_inh = True}), (Class_Inh {c_name = Identifier {i_ln = "0", i = "Int"}, inherited = Identifier {i_ln = "0", i = "Object"}, features = [], obj_inh = True}), (Class_Inh {c_name = Identifier {i_ln = "0", i = "String"}, inherited = Identifier {i_ln = "0", i = "Object"}, features = [Method {f_definer = "String", f_name = Identifier {i_ln = "0", i = "concat"}, f_formals = [Formal {fo_name = Identifier {i_ln = "0", i = "s"}, fo_type = Identifier {i_ln = "0", i = "String"}}], f_type = Identifier {i_ln = "0", i = "String"}, f_body = E_String {e_type = "", e_ln = "0", s_const = "concat body placeholder"}}, Method {f_definer = "String", f_name = Identifier {i_ln = "0", i = "length"}, f_formals = [], f_type = Identifier {i_ln = "0", i = "Int"}, f_body = E_Integer {e_type = "", e_ln = "0", i_const = "length body placeholder"}}, Method {f_definer = "String", f_name = Identifier {i_ln = "0", i = "substr"}, f_formals = [Formal {fo_name = Identifier {i_ln = "0", i = "i"}, fo_type = Identifier {i_ln = "0", i = "Int"}}, Formal {fo_name = Identifier {i_ln = "0", i = "l"}, fo_type = Identifier {i_ln = "0", i = "Int"}}], f_type = Identifier {i_ln = "0", i = "String"}, f_body = E_String {e_type = "", e_ln = "0", s_const = "substr body placeholder"}}], obj_inh = True}), (Class_Inh {c_name = Identifier {i_ln = "0", i = "Bool"}, inherited = Identifier {i_ln = "0", i = "Object"}, features = [], obj_inh = True})]++x