module MutualDiag where

import ExprInterp
import Parser (readExpr)

-- Rewrite the following mutual recursive code
--
-- let f = \n -> if n == 0 then 0 else 3 * f (n - 1) - g (n - 1)
--     g = \n -> if n == 0 then 1 else g (n - 1) + 2 * f (n - 1)
-- in f x * g y
--
-- into the toy functional language from lecture without recursion,
-- by extending the diagonal trick to two mutually recursive functions.
--
-- For convenience and actually readable syntax :) just complete the string in
-- buildString below (look for TODO).  Then buildExpr below will parse it into
-- Expr using the provided parser.
--
-- Note: you need to write \\ for each \ in a string literal.
--
-- Note: When defining mkG, you may not use mkF. The interpreter has actually
-- been modified for this (independent bindings).

buildString :: Integer -> Integer -> String
buildString x y =
    "let "
    ++
    "mkF = \\f g -> \\n -> if n==0 then 0 else 3 * f (n-1) - g (n-1) ;"
    ++
    "mkG = \\g f  -> \\n -> if n==0 then 1 else g (n-1) + 2 * f (n-1) ;"
    ++
    "in mkF f " ++ show x ++ " * " ++ "mkG g " ++ show y


buildExpr :: Integer -> Integer -> Expr
buildExpr x y = readExpr (buildString x y)
