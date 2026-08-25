module WexprParser where

import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
import ParserLib
import WexprDef
import Debug.Trace

debug :: Show a => String -> Parser a -> Parser a
debug label parser = MkParser $ \n inp ->
  trace (label ++ ": input = " ++ show inp) (unParser parser n inp)

-- Parser for natural numbers
natParser :: Parser Wexpr
natParser = fmap Nat natural

-- Parser for variables (excluding reserved words)
varParser :: Parser Wexpr
varParser = identifier ["where", "and"] >>= \var -> pure (Var var)

-- Parser for negation (allowing multiple negations)
negParser :: Parser Wexpr
negParser = many (operator "-") >>= \negs -> 
            term >>= \t -> 
            pure (foldr (const Neg) t negs)
  where
    term = natParser <|> varParser <|> parens wexpr

-- Helper parser for whitespace
whitespaces1 :: Parser String
whitespaces1 = some whitespace

-- Parser for binary operations
plusParser, minusParser, timesParser :: Parser (Wexpr -> Wexpr -> Wexpr)
plusParser = operator "+" *> pure Plus
minusParser = operator "-" *> pure Minus
timesParser = operator "*" *> pure Times

-- Parser for 'Where' expressions
whereParser :: Parser (Wexpr -> [(String, Wexpr)] -> Wexpr)
whereParser = keyword "where" *> whitespaces *> pure Where

-- Parser for 'and' keyword in bindings
andParser :: Parser String
andParser = keyword "and" *> whitespaces *> pure "and"

-- Parser for bindings inside 'Where' expressions
binding :: Parser (String, Wexpr)
binding = identifier ["where", "and"] >>= \var -> char '=' *> whitespaces *> wexpr >>= \expr -> pure (var, expr)
-- binding = debug "binding" $ identifier ["where", "and"] >>= \var -> char '=' *> whitespaces *> wexpr >>= \expr -> pure (var, expr)

-- Parser for a list of bindings separated by 'and'
bindings :: Parser [(String, Wexpr)]
-- bindings = some (binding <* optional (andParser *> whitespaces))
bindings = debug "bindings" $ some (binding <* optional (andParser *> whitespaces))
-- bindings = some (binding <* optional (andParser *> whitespaces) <* checkDelimiter)
--   where
--     checkDelimiter :: Parser ()
--     checkDelimiter = (char ',' *> pure ()) <|> (char '(' *> pure ()) <|> (char ')' *> pure ()) <|> failParse


-- Parser for addition and subtraction (left-associative)
addSubParser :: Parser Wexpr
addSubParser = chainl1 mulParser (plusParser <|> minusParser)

-- Parser for multiplication (left-associative)
mulParser :: Parser Wexpr
mulParser = chainl1 negParser timesParser

-- Parser for expressions in parentheses
parens :: Parser a -> Parser a
parens p = openParen *> p <* closeParen

-- Main parser for 'wexpr'
wexpr :: Parser Wexpr
wexpr = whitespaces *> (whereExpr <|> addSubParser)

-- Parser for 'where' expressions with debugging
whereExpr :: Parser Wexpr
whereExpr = addSubParser >>= restOfWhere
  where
    restOfWhere :: Wexpr -> Parser Wexpr
    restOfWhere e1 = 
      (whereParser *> bindings >>= \bs -> 
        (keyword "where" *> empty) <|> restOfWhere (Where e1 bs))
      <|> pure e1



