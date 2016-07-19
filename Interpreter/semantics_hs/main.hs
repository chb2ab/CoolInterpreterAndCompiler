-- Cool Typechecker, Crispin Bernier, chb2ab
import System.IO  
import System.Environment  
import Data.List
import Data.Map
import AST_nodes
import Deserializer
import Serealizer
import Check_misc
import Type_checker

main = do
    -- Input file given as command line argument
    args <- getArgs
    let r_filename = head args
    let w_filename = (splitArg r_filename)++".cl-type"
    let list = []
    r_handle <- openFile r_filename ReadMode
    w_handle <- openFile w_filename WriteMode
    contents <- hGetContents r_handle
    let singlewords = lines contents
    -- Read the ast into a list of classes
    let orig_classes = readAST singlewords
    let classes_unsort = addDefaultClasses orig_classes
    -- Check for errors not involving expressions and output an error string if found
    let err_string = checkClassesForError1 classes_unsort
    if err_string == "" then do
        -- Type check expressions and output an error string if found
        let classes_inh = populateInheritances classes_unsort classes_unsort
        let (err_string, annotated_classes) = typeCheck classes_inh
        if err_string == "" then do
            -- Output the various maps
            let sorted_classes = sortClassesByName classes_inh
            let sorted_annotated_classes = sortClassesByName annotated_classes
            let c_mp = createClassMap sorted_annotated_classes
            let class_map = "class_map":(show (length sorted_annotated_classes)):c_mp
            let i_mp = createImplementationMap sorted_annotated_classes
            let imp_map = "implementation_map":(show (length sorted_annotated_classes)):i_mp
            let p_map = createParentMap sorted_classes
            let parent_map = "parent_map":(show ((length sorted_classes)-1)):p_map
            let annotated_classes_ni = takeOutInheritanceFromClasses annotated_classes
            let a_c_ni_reordered = reOrderClassFeats orig_classes annotated_classes_ni
            let aast = createAnnotatedAST a_c_ni_reordered
            let maps = class_map++imp_map++parent_map++aast
            mapM_ (hPutStrLn w_handle) maps
        else putStrLn err_string
    else putStrLn err_string
    hClose r_handle
    hClose w_handle