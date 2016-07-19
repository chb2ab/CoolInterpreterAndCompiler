module AST_nodes where

data Identifier = Identifier {
    i_ln :: String,
    i    :: String
} deriving (Eq, Show, Read)

data Binding = Binding_No_Init {
    b_variable :: Identifier,
    b_typ      :: Identifier
} | Binding_Init {
    b_variable :: Identifier,
    b_typ      :: Identifier,
    b_value    :: Expression
} | Binding_Error{
    b_error :: String
} deriving (Eq, Show, Read)

data Case_Element = Case_Element {
    c_variable :: Identifier,
    c_typ      :: Identifier,
    c_body     :: Expression
} | Case_Error{
    c_error :: String
}  deriving (Eq, Show, Read)

data Expression = E_Assign {
    e_type :: String,
    e_ln   :: String,
    var    :: Identifier,
    rhs    :: Expression
} | E_Dynamic_Dispatch {
    e_type :: String,
    e_ln   :: String,
    e      :: Expression,
    method :: Identifier,
    args   :: [Expression]
} | E_Static_Dispatch {
    e_type :: String,
    e_ln   :: String,
    e      :: Expression,
    typ    :: Identifier,
    method :: Identifier,
    args   :: [Expression]
} | E_Self_Dispatch {
    e_type :: String,
    e_ln   :: String,
    method :: Identifier,
    args   :: [Expression]
} | E_If {
    e_type    :: String,
    e_ln      :: String,
    predicate :: Expression,
    thenn     :: Expression,
    elsee     :: Expression
} | E_While {
    e_type    :: String,
    e_ln      :: String,
    predicate :: Expression,
    body      :: Expression
} | E_Block {
    e_type :: String,
    e_ln   :: String,
    bodies :: [Expression]
} | E_New {
    e_type :: String,
    e_ln   :: String,
    clas   :: Identifier
} | E_Isvoid {
    e_type :: String,
    e_ln   :: String,
    e      :: Expression
} | E_Plus {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression,
    y      :: Expression
} | E_Minus {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression,
    y      :: Expression
} | E_Times {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression,
    y      :: Expression
} | E_Divide {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression,
    y      :: Expression
} | E_Lt {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression,
    y      :: Expression
} | E_Le {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression,
    y      :: Expression
} | E_Eq {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression,
    y      :: Expression
} | E_Not {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression
} | E_Negate {
    e_type :: String,
    e_ln   :: String,
    x      :: Expression
} | E_Integer {
    e_type  :: String,
    e_ln    :: String,
    i_const :: String
} | E_String {
    e_type  :: String,
    e_ln    :: String,
    s_const :: String
} | E_Identifier {
    e_type :: String,
    e_ln   :: String,
    var    :: Identifier
} | E_True {
    e_type :: String,
    e_ln   :: String
} | E_False {
    e_type :: String,
    e_ln   :: String
} | E_Let {
    e_type   :: String,
    e_ln     :: String,
    bindings :: [Binding],
    body     :: Expression
} | E_Case {
    e_type        :: String,
    e_ln          :: String,
    expr          :: Expression,
    case_elements :: [Case_Element]
} | E_Error {
    e_error :: String
} deriving (Eq, Show, Read)

data Formal = Formal {
    fo_name :: Identifier,
    fo_type :: Identifier
} | Form_Error {
    fo_error :: String
}  deriving (Eq, Show, Read)

data Feature = Attr_No_Init {
    f_definer  :: String,
    f_name     :: Identifier,
    f_type     :: Identifier
} | Attr_Init {
    f_definer  :: String,
    f_name     :: Identifier,
    f_type     :: Identifier,
    f_init     :: Expression
} | Method {
    f_definer  :: String,
    f_name     :: Identifier,
    f_formals  :: [Formal],
    f_type     :: Identifier,
    f_body     :: Expression
} | Feat_Error{
    f_error :: String
}  deriving (Eq, Show, Read)

data Class = Class_Inh {
    c_name      :: Identifier,
    inherited   :: Identifier,
    features    :: [Feature],
    obj_inh     :: Bool
} | Class_Non_Inh {
    c_name   :: Identifier,
    features    :: [Feature]
} | Class_Err {
    err   :: String
} deriving (Eq, Show, Read)