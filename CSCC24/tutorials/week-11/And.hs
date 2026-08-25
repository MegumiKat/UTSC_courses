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
-- should not cause an error.
interp (Prim2 AndBool e1 e2) =
    interp e1 >>= \v1 -> case v1 of
        VB False -> pure (VB False)
        VB True  -> interp e2 >>= \v2 -> case v2 of
            VB b -> pure (VB b)
            _    -> raise TypeError
        _        -> raise TypeError


-- Short-circuiting logical-and, but flexible in types.  If the 1st operand
-- evaluates to boolean false, don't evaluate the 2nd operand; else (regardless
-- of type) proceed to evaluate the second operand and use its result as the
-- overall result.  There is no restriction on types.
interp (Prim2 AndFlex e1 e2) =
    interp e1 >>= \v1 -> case v1 of
        VB False -> pure (VB False)
        _        -> interp e2

