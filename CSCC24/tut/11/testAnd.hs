-- How to use: runghc testAnd.hs

import TestLib

import AndDef
import And (interp)

tests =
    [ "AndBool left identity"
      ~: interp (Prim2 AndBool (Bln False) (Num 4))
      ~?= Success (VB False)
    , "AndBool right"
      ~: interp (Prim2 AndBool (Bln True) (Bln False))
      ~?= Success (VB False)
    , "AndBool type error 1st operand"
      ~: interp (Prim2 AndBool (Num 4) (Bln True))
      ~?= Error TypeError
    , "AndBool type error 2nd operand"
      ~: interp (Prim2 AndBool (Bln True) (Num 4))
      ~?= Error TypeError
    , "AndFlex left identity"
      ~: interp (Prim2 AndFlex (Bln False) (Num 4))
      ~?= Success (VB False)
    , "AndFlex right"
      ~: interp (Prim2 AndFlex (Num 4) (Num 10))
      ~?= Success (VN 10)
    ]
-- More tests when marking.

main = testlibMain tests
