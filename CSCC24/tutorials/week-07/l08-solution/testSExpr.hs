{-
How to use:

    runghc testSExpr.hs
-}

import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
import TestLib
import ParserLib
import SExprDef
import SExpr (sexpr)

tests = [ "var"                 -- 1 mark
          ~: runParser sexpr "myname" ~?= Just (Ident "myname")
        , "singleton list"      -- 1 mark
          ~: runParser sexpr "(doggy)" ~?= Just (List [Ident "doggy"])
        , "list of two vars"     -- 1 mark
          ~: runParser sexpr "(doggy kitteh)"
             ~?= Just (List [Ident "doggy", Ident "kitteh"])
        , "empty list banned"   -- 1 mark
          ~: runParser sexpr "()" ~?= Nothing
        , "general"             -- 1 mark
          ~: runParser sexpr "(  f  ( g  x1 y1)  (h))  "
             ~?= Just (List [ Ident "f"
                            , List [Ident "g",Ident "x1",Ident "y1"]
                            , List [Ident "h"]])
        ]

main = testlibMain tests
