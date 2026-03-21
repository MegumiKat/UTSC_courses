-- How to use: runghc testParser.hs

import TestLib
import ParserLib
import WexprDef
import WexprParser (wexpr)
import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))

mainParser :: Parser Wexpr
mainParser = whitespaces *> wexpr <* eof

-- Tired of writing "runParser mainParser inp" heh.
runMain = runParser mainParser

tests =
    -- [ "natural" ~: runMain "  52  " ~?= Just (Nat 52)
    -- , "var" ~: runMain "  foo  " ~?= Just (Var "foo")
    -- , "reserved word not var" ~: runMain "  and  " ~?= Nothing
    -- , "5 - 4 + 3"
    --   ~: runMain "5 - 4 + 3" ~?= Just (Plus (Minus (Nat 5) (Nat 4)) (Nat 3))
    -- , "5 + -4" ~: runMain "5 + -4" ~?= Just (Plus (Nat 5) (Neg (Nat 4)))
    -- , "- - 5" ~: runMain "- - 5" ~?= Just (Neg (Neg (Nat 5)))
    -- , "-- 5" ~: runMain "-- 5" ~?= Nothing
    -- , "5 +-4" ~: runMain "5 +-4" ~?= Nothing
    -- , "good nested where"
    --   ~: runMain "(foo where y = 5) where z = (b where b = 1)"
    --   ~?= Just (Where (Where (Var "foo") [("y", Nat 5)])
    --                   [("z", Where (Var "b") [("b", Nat 1)])])
    -- , "bad nested where"
    --   ~: runMain "foo where y=5 where z=b where b=1" ~?= Nothing
    
    -- ]
    ["bad nested where"
      ~: runMain "foo where y=5 where z=b where b=1" ~?= Nothing
      , "good nested where"
      ~: runMain "(foo where y = 5) where z = (b where b = 1)"
      ~?= Just (Where (Where (Var "foo") [("y", Nat 5)])
                      [("z", Where (Var "b") [("b", Nat 1)])])
    , "and instance"
      ~: runMain "foo where y = 5 and z = 1"
      ~?= Just (Where (Var "foo") [("y", Nat 5), ("z", Nat 1)])]

main = testlibMain tests
