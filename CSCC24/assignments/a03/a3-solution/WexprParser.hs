module WexprParser where

import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
import ParserLib
import WexprDef

wexpr :: Parser Wexpr
wexpr = expr
        >>= \e -> optional (keyword "where" *> defs)
        >>= \md -> case md of
                     Nothing -> pure e
                     Just ds -> pure (Where e ds)

defs = chainr1 def (keyword "and" *> pure (++))

-- def returns a singleton list to blend nicely with the (++) above.
def = liftA3 (\v _ e -> [(v,e)]) var (operator "=") expr

expr = plusminuses

plusminuses = chainl1 times pm
  where
    pm = operator "+" *> pure Plus
         <|>
         operator "-" *> pure Minus

times = chainl1 negs (operator "*" *> pure Times)

negs = (operator "-" *> fmap Neg negs)
       <|>
       atom

atom = fmap Var var
       <|> fmap Nat natural
       <|> (openParen *> wexpr <* closeParen)

var = identifier ["and", "where"]
