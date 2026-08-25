module TryMeDef where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Prelude hiding (pure, (>>=))

data Stmt
    = Assign String Expr          -- the String is for the LHS variable
    | Compound [Stmt]             -- { stmt, ... }
    | Try [Stmt]                  -- try-block
          [(Exception, [Stmt])]   -- exception handler(s)
    deriving (Eq, Show)

data Expr
    = Lit Integer
    | Var String
    | Add Expr Expr
    | Div Expr Expr
    deriving (Eq, Show)

data Exception = DivByZero | VarUninit
    deriving (Eq, Show)

class TryMeModel m where
    -- Give an answer.
    pure :: a -> m a
    -- Sequential composition.
    (>>=) :: m a -> (a -> m b) -> m b
    -- Throw the given exception.
    raise :: Exception -> m a
    -- Try, then report exception or success.
    reifyException :: m a -> m (Either Exception a)
    -- Init/Write a variable.
    putVar :: String -> Integer -> m ()
    -- Read a variable. Throws VarUninit if not found.
    getVar :: String -> m Integer

data TC a = MkTC (Map String Integer -> (Map String Integer, Either Exception a))

unTC :: TC a -> Map String Integer -> (Map String Integer, Either Exception a)
unTC (MkTC stf) = stf

