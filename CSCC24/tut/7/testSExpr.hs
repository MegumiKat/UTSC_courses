{-
How to use:

    runghc testSExpr.hs
-}

import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
import TestLib
import ParserLib
import SExprDef
import SExpr (sexpr)

tests = [ "sample" ~:
          runParser sexpr "(  f  ( g  x1 y1)  (h))  junk"
          ~?= Just (List [ Ident "f"
                         , List [Ident "g",Ident "x1",Ident "y1"]
                         , List [Ident "h"]])
        , "base case" ~:
          runParser sexpr "x1 y "
          ~?= Just (Ident "x1")
        ]
-- More tests when marking.

main = testlibMain tests
