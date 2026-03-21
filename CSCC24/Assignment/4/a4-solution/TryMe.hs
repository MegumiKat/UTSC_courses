module TryMe where

import Data.List qualified as List
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Prelude hiding (pure, (>>=))
import TryMeDef

instance TryMeModel TC where
    pure a = MkTC (\s -> (s, Right a))

    MkTC stf >>= k = MkTC (\s0 -> case stf s0 of
                              (s1, Left e) -> (s1, Left e)
                              (s1, Right a) -> unTC (k a) s1)

    raise e = MkTC (\s -> (s, Left e))

    reifyException (MkTC stf1) = MkTC stf2
      where
        stf2 s0 = case stf1 s0 of (s1, ea) -> (s1, Right ea)

    putVar v x = MkTC (\s -> (Map.insert v x s, Right ()))

    getVar v = MkTC (\s -> case Map.lookup v s of
                        Nothing -> (s, Left VarUninit)
                        Just x -> (s, Right x))

run :: Stmt -> (Map String Integer, Either Exception ())
run stmt = runWith stmt Map.empty

runWith :: Stmt -> Map String Integer -> (Map String Integer, Either Exception ())
runWith stmt s0 = unTC (interp stmt) s0

interp :: TryMeModel m => Stmt -> m ()

interp (Assign var expr) =
    eval expr
    >>= \x -> putVar var x

interp (Compound stmts) = compound stmts

interp (Try stmts handlers) =
    reifyException (compound stmts)
    >>= \ea -> case ea of
                Right a -> pure a
                Left exc -> case List.lookup exc handlers of
                  Nothing -> raise exc
                  Just stmts -> compound stmts

compound [] = pure ()
compound (stmt : stmts) = interp stmt >>= \_ -> compound stmts

eval :: TryMeModel m => Expr -> m Integer
eval (Lit i) = pure i
eval (Var v) = getVar v
eval (Add e1 e2) =
    eval e1
    >>= \x1 -> eval e2
    >>= \x2 -> pure (x1 + x2)
eval (Div e1 e2) =
    eval e1
    >>= \x1 -> eval e2
    >>= \x2 -> if x2 == 0 then raise DivByZero
               else pure (div x1 x2)
