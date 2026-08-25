-- In this lab exercise, you try your hands at formulating a short-circuiting
-- operator: logical-and.
--
-- There are two versions: AndBool, AndFlex.  The difference: AndBool wants
-- booleans only, but AndFlex is much more flexible; see the comments below for
-- details.  (Dynamically typed languages such as shells and Scheme prefer the
-- AndFlex way, it serves as a control flow construct.)
--
-- For simplicity there are no other language features to worry about.

module And where

import AndDef
import Prelude hiding ((>>=), pure)

interp :: Expr -> ExprInterp Value

interp (Num i) = pure (VN i)

interp (Bln b) = pure (VB b)

-- Short-circuiting boolean logical-and.  If the 1st operand evaluates to false,
-- don't evaluate the 2nd operand.  Evaluated operands are checked to give
-- boolean values (use "raise TypeError" for type errors); unevaluated operands
-- are not checked.
interp (Prim2 AndBool e1 e2) =
    interp e1
    >>= \v1 -> boolOrDie v1
    >>= \b1 -> case b1 of
                 False -> pure (VB False)
                 True -> interp e2
                         >>= \v2 -> boolOrDie v2
                         >>= \b2 -> pure (VB b2)

-- Short-circuiting logical-and, but flexible in types.  If the 1st operand
-- evaluates to boolean false, don't evaluate the 2nd operand; else (regardless
-- of type) proceed to evaluate the second operand and use its result as the
-- overall result.  There is no restriction on types.
interp (Prim2 AndFlex e1 e2) =
    interp e1
    >>= \v1 -> case v1 of
                 VB False -> pure (VB False)
                 _ -> interp e2

-- Helper to expect the VB case (failure if not) and unwrap the boolean.
boolOrDie :: Value -> ExprInterp Bool
boolOrDie (VB b) = pure b
boolOrDie _ = raise TypeError
