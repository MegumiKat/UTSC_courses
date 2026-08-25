-- How to use: runghc testTryMe.hs

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Prelude hiding (pure, (>>=))
import TestLib
import TryMe (interp)
import TryMeDef

testBind =
    [ "bind 1" ~:
      unTC (MkTC (\s -> (Map.delete "a" s, Right 27))
            >>= \a -> MkTC (\s -> (Map.insert "b" a s, Right (even a))))
           (Map.fromList [("a",7), ("c",5)])
      ~?= (Map.fromList [("b",27), ("c",5)], Right False)
    , "bind 2" ~:
      unTC (MkTC (\s -> (Map.delete "a" s, Left DivByZero))
            >>= \a -> MkTC (\s -> (Map.insert "b" a s, Left VarUninit)))
           (Map.fromList [("a",7), ("c",5)])
      ~?= (Map.fromList [("c",5)], Left DivByZero :: Either Exception ())
    ]

testPutVar =
    [ "putVar init" ~:
      unTC (putVar "a" 9) (Map.fromList [("c",5)])
      ~?= (Map.fromList [("a",9), ("c",5)], Right ())
    , "putVar update" ~:
      unTC (putVar "c" 9) (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",9)], Right ())
    ]

testGetVar =
    [ "getVar exists" ~:
      unTC (getVar "c") (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",5)], Right 5)
    , "getVar uninit" ~:
      unTC (getVar "a") (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",5)], Left VarUninit)
    ]

testRaise =
    [ "raise divbyzero" ~:
      unTC (raise DivByZero) (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",5)], Left DivByZero :: Either Exception ())
    , "rasie varuninit" ~:
      unTC (raise VarUninit) (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",5)], Left VarUninit :: Either Exception ())
    ]

type E2 a = Either Exception (Either Exception a)
testReifyException =
    [ "reifyException (throw divbyzero)" ~:
      unTC (reifyException (MkTC (\s -> (s, Left DivByZero))))
           (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",5)], Right (Left DivByZero) :: E2 ())
    , "reifyException (no throw)" ~:
      unTC (reifyException (MkTC (\s -> (s, Right 7))))
           (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",5)], Right (Right 7) :: E2 Integer)
    ]

run :: Stmt -> (Map String Integer, Either Exception ())
run stmt = runWith stmt Map.empty

runWith :: Stmt -> Map String Integer -> (Map String Integer, Either Exception ())
runWith stmt s0 = unTC (interp stmt) s0

testAssign =
    [ "assign a:=1" ~:
      runWith (Assign "a" (Lit 1)) (Map.fromList [("c",5)])
      ~?= (Map.fromList [("a",1), ("c",5)], Right ())
    , "assign divbyzero" ~:
      runWith (Assign "a" (Div (Lit 8) (Lit 0))) (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",5)], Left DivByZero)
    , "assign varuninit" ~:
      runWith (Assign "a" (Var "b")) (Map.fromList [("c",5)])
      ~?= (Map.fromList [("c",5)], Left VarUninit)
    ]

testCompound =
    [ "compound assigns" ~:
      runWith (Compound [ Assign "a" (Lit 2)
                        , Assign "b" (Lit 27)
                        , Assign "c" (Var "b")
                        ])
              (Map.fromList [("c", 5)])
      ~?= (Map.fromList [("a",2), ("b",27), ("c",27)], Right ())
    , "compound exception in the middle" ~:
      runWith (Compound [ Assign "a" (Lit 2)
                        , Assign "b" (Var "k")
                        , Assign "c" (Lit 27)
                        ])
              (Map.fromList [("c", 5)])
      ~?= (Map.fromList [("a",2), ("c",5)], Left VarUninit)
    ]

testTry =
    [ "try caught" ~:
      runWith (Try [ Assign "a" (Lit 2)
                   , Assign "b" (Var "n")
                   , Assign "c" (Lit 27)
                   ]
                   [(VarUninit, [ Assign "v" (Lit 16) ])])
              (Map.fromList [("c", 5)])
      ~?= (Map.fromList [("a",2), ("v",16), ("c",5)], Right ())
    , "try not caught" ~:
      runWith (Try [ Assign "a" (Lit 2)
                   , Assign "b" (Div (Lit 3) (Lit 0))
                   , Assign "c" (Lit 27)
                   ]
                   [(VarUninit, [ Assign "v" (Lit 16) ])])
              (Map.fromList [("c", 5)])
      ~?= (Map.fromList [("a",2), ("c",5)], Left DivByZero)
    , "exceptions inside handler not caught by this try" ~:
      runWith (Try [ Assign "a" (Lit 2)
                   , Assign "b" (Var "n")
                   , Assign "c" (Lit 27)
                   ]
                   [ (VarUninit, [ Assign "b" (Div (Lit 3) (Lit 0)) ])
                   , (DivByZero, [ Assign "b" (Lit 16) ])
                   ])
              (Map.fromList [("c", 5)])
      ~?= (Map.fromList [("a",2), ("c",5)], Left DivByZero)
    ]

tests = testBind ++ testPutVar ++ testGetVar ++ testRaise ++ testReifyException
        ++ testAssign ++ testCompound ++ testTry

main = testlibMain tests
