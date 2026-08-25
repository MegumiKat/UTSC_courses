-- How to use: runghc testAnd.hs

import TestLib

import AndDef
import And (interp)

tests =
    [ "AndBool false 4"  -- 0.5 marks
        ~: interp (Prim2 AndBool (Bln False) (Num 4))
        ~?= Success (VB False)
    , "AndBool false true"  -- 0.5
        ~: interp (Prim2 AndBool (Bln False) (Bln True))
        ~?= Success (VB False)
    , "AndBool true false"  -- 0.5
      ~: interp (Prim2 AndBool (Bln True) (Bln False))
      ~?= Success (VB False)
    , "AndBool true true"  -- 0.5
      ~: interp (Prim2 AndBool (Bln True) (Bln True))
      ~?= Success (VB True)
    , "AndBool true 4 (type error)"  -- 0.5
      ~: interp (Prim2 AndBool (Bln True) (Num 4))
      ~?= Error TypeError
    , "AndBool 4 false (type error)"  -- 0.5
      ~: interp (Prim2 AndBool (Num 4) (Bln False))
      ~?= Error TypeError
    , "AndFlex false 4"  -- 1
      ~: interp (Prim2 AndFlex (Bln False) (Num 4))
      ~?= Success (VB False)
    , "AndFlex true 10"  -- 0.5
      ~: interp (Prim2 AndFlex (Bln True) (Num 10))
      ~?= Success (VN 10)
    , "AndFlex 4 10"  -- 0.5
      ~: interp (Prim2 AndFlex (Num 4) (Num 10))
      ~?= Success (VN 10)
    ]

main = testlibMain tests
