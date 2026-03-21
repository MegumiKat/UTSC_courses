-- How to use: runghc testMutualDiag.hs

import TestLib
import ExprInterp
import MutualDiag (buildString, buildExpr)

f n = if n == 0 then 0 else 3 * f (n - 1) - g (n - 1)
g n = if n == 0 then 1 else g (n - 1) + 2 * f (n - 1)

expected x y = Success (VN (f x * g y))

checkStructure x y = checkCond MkCond{cond = p, condName = "expected structure"}
  where
    p (Let [_,_] (Prim2 Mul (App _ (Num a)) (App _ (Num b)))) = x==a && y==b
    p _ = False

tests =
    [ "test" ~:
      let e = buildExpr 9 8
      in checkStructure 9 8 e ~&&
         mainInterp e ~?= expected 9 8
    ]

main = testlibMain tests
