module WexprDef where

data Wexpr
  = Nat Integer
  | Var String
  | Neg Wexpr -- unary minus
  | Plus Wexpr Wexpr
  | Minus Wexpr Wexpr
  | Times Wexpr Wexpr
  | Where Wexpr [(String, Wexpr)]
  deriving (Eq, Show)
