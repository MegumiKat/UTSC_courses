module AndDef where

import Prelude hiding ((>>=), pure)

-- Abstract syntax tree.
data Expr
    = Num Integer
    | Bln Bool
    | Prim2 Op2 Expr Expr
    deriving (Eq, Show)

data Op2 = AndBool | AndFlex
    deriving (Eq, Show)

-- The type of possible values from the interpreter.
data Value = VN Integer
           | VB Bool
    deriving (Eq, Show)

-- Interpreter model and connectives.
data ExprInterp a = Error ErrorType | Success a
    deriving (Eq, Show)

data ErrorType = TypeError
    deriving (Eq, Show)

pure :: a -> ExprInterp a
pure a = Success a

raise :: ErrorType -> ExprInterp a
raise e = Error e

(>>=) :: ExprInterp a -> (a -> ExprInterp b) -> ExprInterp b
Error msg >>= _ = Error msg
Success a >>= k = k a
