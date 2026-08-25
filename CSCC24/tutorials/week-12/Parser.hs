module Parser(readExpr, expr) where

import ExprInterp (Expr(..), Op2(..))
import ParserLib
import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))


readExpr :: String -> Expr
readExpr inp = case runParser (whitespaces *> expr <* eof) inp of
  Just x -> x
  Nothing -> error ("syntax error: " ++ inp)

expr :: Parser Expr
expr = local <|> lambda <|> ifelse <|> comparative

var = identifier ["let", "in", "if", "then", "else"]

local = pure (\_ eqns _ e -> Let eqns e)
        <*> keyword "let"
        <*> many equation
        <*> keyword "in"
        <*> expr

equation = var
           >>= \v -> operator "="
           *> expr
           >>= \e -> semicolon
           *> pure (v, e)

semicolon = char ';' <* whitespaces

lambda = operator "\\"
         *> var
         >>= \v -> operator "->"
         *> expr
         >>= \e -> pure (Lambda v e)

ifelse = keyword "if"
         *> expr
         >>= \cond -> keyword "then"
         *> expr
         >>= \e1 -> keyword "else"
         *> expr
         >>= \e2 -> pure (Cond cond e1 e2)

comparative = chainl1 additive op
  where
    op = (operator "==" *> pure (Prim2 Eq))

additive = chainl1 multiplicative op
  where
    op = (operator "+" *> pure (Prim2 Plus)) <|> (operator "-" *> pure (Prim2 Minus))

multiplicative = chainl1 app op
  where
    op = (operator "*" *> pure (Prim2 Mul))

app = chainl1 atom (pure App)

atom = fmap Var var
       <|>
       fmap Num natural
       <|>
       (openParen *> expr <* closeParen)
