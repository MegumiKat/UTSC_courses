module ExprInterp (Expr(..), Op2(..), Value(..), ExprInterp(..), mainInterp) where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Prelude hiding ((>>=), pure)

-- Result type of interpreter: Possibility of errors.
-- More general/abstract thinking: Type of interpreter, model of possible effects.
data ExprInterp a = Error ErrorType | Success a
    deriving (Eq, Show)
data ErrorType = TypeError | VarNotFound
    deriving (Eq, Show)

-- Give an answer. Simply "Success" for ExprInterp, but can be more complex for
-- other interpreters.
pure :: a -> ExprInterp a
pure a = Success a

-- Raise an error. Simply "Error" for ExprInterp, but can be more complex for
-- other interpreters.
raise :: ErrorType -> ExprInterp a
raise e = Error e

-- Sequential composition of two interpreter stages: Check success of
-- 1st stage, and if success, pass answer to 2nd stage.
(>>=) :: ExprInterp a -> (a -> ExprInterp b) -> ExprInterp b
Error msg >>= _ = Error msg
Success a >>= k = k a


data Expr
    = Num Integer
    | Bln Bool
    | Var String
    | Prim2 Op2 Expr Expr          -- Prim2 op operand operand
    | Cond Expr Expr Expr          -- Cond test then-branch else-branch
    | Let [(String, Expr)] Expr    -- Let [(name, rhs), ...] eval-me
    | Lambda String Expr           -- Lambda argname body
    | App Expr Expr                -- App func param
    deriving (Eq, Show)

data Op2 = Eq | Plus | Minus | Mul
    deriving (Eq, Show)

-- The type of possible values from the interpreter.
data Value
  = VN Integer
  | VB Bool
  | VClosure (Map String Value) String Expr
  deriving (Eq, Show)

mainInterp :: Expr -> ExprInterp Value
mainInterp expr = interp expr Map.empty

-- Helper to expect the VN case (failure if not) and return the integer.
intOrDie :: Value -> ExprInterp Integer
intOrDie (VN i) = pure i
intOrDie _ = raise TypeError

interp :: Expr -> Map String Value -> ExprInterp Value

interp (Num i) _ = pure (VN i)

interp (Bln b) _ = pure (VB b)

interp (Prim2 Plus e1 e2) env =
    interp e1 env
    >>= \a -> intOrDie a
    >>= \i -> interp e2 env
    >>= \b -> intOrDie b
    >>= \j -> pure (VN (i+j))

interp (Prim2 Minus e1 e2) env =
    interp e1 env
    >>= \a -> intOrDie a
    >>= \i -> interp e2 env
    >>= \b -> intOrDie b
    >>= \j -> pure (VN (i-j))

interp (Prim2 Mul e1 e2) env =
    interp e1 env
    >>= \a -> intOrDie a
    >>= \i -> interp e2 env
    >>= \b -> intOrDie b
    >>= \j -> pure (VN (i*j))

interp (Prim2 Eq e1 e2) env =
    interp e1 env
    >>= \a -> intOrDie a
    >>= \i -> interp e2 env
    >>= \b -> intOrDie b
    >>= \j -> pure (VB (i == j))

interp (Cond test eThen eElse) env =
    interp test env
    >>= \a -> case a of
      VB True -> interp eThen env
      VB False -> interp eElse env
      _ -> raise TypeError

interp (Var v) env = case Map.lookup v env of
  Just a -> pure a
  Nothing -> raise VarNotFound

interp (Let eqns evalMe) env =
    extend eqns env
    >>= \env' -> interp evalMe env'
  where
    extend [] e = pure e
    extend ((v,rhs) : eqns) e =
        interp rhs env
        >>= \a ->
        let e' = Map.insert v a e
        in extend eqns e'

interp (Lambda v body) env = pure (VClosure env v body)

interp (App f e) env =
    interp f env
    >>= \c -> case c of
      VClosure fEnv v body ->
          interp e env
          >>= \eVal ->
          let bEnv = Map.insert v eVal fEnv  -- fEnv, not env
          in interp body bEnv
      _ -> raise TypeError
