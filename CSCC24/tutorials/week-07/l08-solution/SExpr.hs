module SExpr where

import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
import ParserLib
import SExprDef

-- [6 marks]
-- Lisp and Scheme use S-expressions. A basic version of the grammar in EBNF is:
--
--     S ::= var
--         | "(" S { S } ")"
--
-- `var` can be done by `identifier` in ParserLib.hs for simplicity, and we
-- don't have reserved words in this lab.
--
-- Implement `sexpr` below for this grammar.  Produce an AST of type `SExpr`
-- (defined in SExprDef.hs).
--
-- How (code structure): Since this grammar does not have left recursion, your
-- code structure can closely follow the recursive structure of the grammar:
--
-- * Call sexpr (recursive call) to read one S.
--
-- * `S { S }` means "one or more S's". We have a connective for exactly that.
--
-- * Review what these can do for you: `<|>`, `<*`, `*>`, `fmap`.
--
-- Spaces: Follow our convention for token-level parsers: Assume no spaces
-- before, skip spaces after.  If you stick to the token-level parsers (rather
-- than examining individual characters yourself), you're set.  Note that
-- ParserLib.hs has `openParen` and `closeParen` too.
--
-- Example:
--
--   runParser sexpr "(  f  ( g  x1 y1)  (h))  junk"
-- = Just (List [Ident "f",List [Ident "g",Ident "x1",Ident "y1"],List [Ident "h"]])
--
-- (If you're curious about initial leading spaces, see `mainParser` below.)

sexpr :: Parser SExpr
sexpr = fmap Ident (identifier [])
        <|>
        openParen *> fmap List (some sexpr) <* closeParen
        -- Some more ways:
        -- 
        -- liftA3 (\_ es _ -> List es)
        --     openParen
        --     (some sexpr)
        --     closeParen
        --
        -- openParen
        -- *>  some sexpr
        -- >>= \es -> closeParen
        -- *>  pure (List es)


-- If you're interested: Initial leading spaces, as well as (lack of) trailing
-- junk, are handled by having a "main parser":

mainParser :: Parser SExpr
mainParser = whitespaces *> sexpr <* eof
