-- | Library of parser definition and operations.
module ParserLib (
    -- * Representation
    Parser, runParser, traceP,
    -- * Character-Level Primitives
    anyChar, char, satisfy, eof,
    -- * Connectives
    fmap, liftA2, (<*), (*>), (<*>), liftA3, pure, (>>=),
    (<|>), empty, optional, many, some,
    -- * Token-Level Primitives
    whitespace, whitespaces,
    natural, identifier, keyword, anyOperator, operator,
    openParen, closeParen,
    -- * Right/Left Associative Infix Operators
    chainr1, chainl1,
) where

import Data.Char
import Debug.Trace
import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
-- In the future, we will learn that they are methods of some standard type
-- classes.  For now, I don't want to talk about those classes, I pretend they
-- are specific to parsing.


-----------------
-- Representation
-----------------

-- | Internal representation: Function from input string to:
--
-- * Nothing, if failure (syntax error);
-- * Just (unconsumed input, answer), if success.
--
-- But an extra Int parameter for indentation level of debugging messages.
data Parser a = MkParser (Int -> String -> Maybe (String, a))

-- | Unwrapper.
unParser :: Parser a -> Int -> String -> Maybe (String, a)
unParser (MkParser sf) = sf

-- | Using a parser on an input string.
runParser :: Parser a -> String -> Maybe a
runParser (MkParser sf) inp = case sf 0 inp of
                                Nothing -> Nothing
                                Just (_, a) -> Just a

-- | Add debugging messages before and after a parser.
--
-- Example:
--
-- foo = runParser (traceP "outer label"
--                         (liftA2 (\x y -> [x,y])
--                                (traceP "inner #1" anyChar)
--                                (traceP "inner #2" anyChar)))
--                 "abc123"
--
-- Debugging output:
--
-- begin outer label
--   input: "abc123"
--   begin inner #1
--     input: "abc123"
--     rest:  "bc123"
--     ret:   'a'
--   end inner #1
--   begin inner #2
--     input: "bc123"
--     rest:  "c123"
--     ret:   'b'
--   end inner #2
--   rest:  "c123"
--   ret:   "ab"
-- end outer label
traceP :: Show a => String -> Parser a -> Parser a
traceP label (MkParser stf) = MkParser stf2
  where
    stf2 n inp =
        trace (indent ++ "begin " ++ label ++ "\n"
               ++ indent1 ++ "input: " ++ show inp)
        (case stf (n+1) inp of
            Nothing -> trace (indent1 ++ "failed\n" ++ end)
                       Nothing
            j@(Just (inp2, a)) -> trace (indent1 ++ "rest:  " ++ show inp2 ++ "\n"
                                         ++ indent1 ++ "ret:   " ++ show a ++ "\n"
                                         ++ end)
                                  j)
      where
        indent = replicate (n*2) ' '
        indent1 = "  " ++ indent
        end = indent ++ "end " ++ label


-----------------------------
-- Character-level primitives
-----------------------------

-- | Read a character. Failure if input is empty.
anyChar :: Parser Char
anyChar = MkParser sf
  where
    sf _ "" = Nothing
    sf _ (c:cs) = Just (cs, c)

-- | Read a character and check against the given character.
char :: Char -> Parser Char
char wanted = MkParser sf
  where
    sf _ (c:cs) | c == wanted = Just (cs, c)
    sf _ _ = Nothing

-- | Read a character and check against the given predicate.
satisfy :: (Char -> Bool) -> Parser Char
satisfy pred = MkParser sf
  where
    sf _ (c:cs) | pred c = Just (cs, c)
    sf _ _ = Nothing

-- | Expect the input to be empty.
eof :: Parser ()
eof = MkParser sf
  where
    sf _ "" = Just ("", ())
    sf _ _ = Nothing


-- But you have to compose smaller parsers to build larger parsers and to return
-- more interesting answers, e.g., abstract syntax trees.

-- | Convert parser's answer by a given function.
fmap :: (a -> b) -> Parser a -> Parser b
fmap f (MkParser sf) = MkParser sfb
  where
    sfb n inp = case sf n inp of
                  Nothing -> Nothing
                  Just (rest, a) -> Just (rest, f a)

-- | Compose two parsers sequentially (unconsumed input from 1st is fed to 2nd).
-- Combine their answers by a binary operator/function.
liftA2 :: (a -> b -> c) -> Parser a -> Parser b -> Parser c
liftA2 op (MkParser sf1) p2 = MkParser g
  where
    g n inp = case sf1 n inp of
                Nothing -> Nothing
                Just (middle, a) ->
                    case unParser p2 n middle of
                      Nothing -> Nothing
                      Just (rest, b) -> Just (rest, op a b)

-- | Compose two parsers sequentially.  Yield 1st parser's answer.
(<*) :: Parser a -> Parser b -> Parser a
pa <* pb = liftA2 (\a _ -> a) pa pb

-- | Compose two parsers sequentially.  Yield 2nd parser's answer.
(*>) :: Parser a -> Parser b -> Parser b
pa *> pb = liftA2 (\_ b -> b) pa pb

infixl 4 <*, *>

-- | Compose two parsers sequentially.  1st parser yields a function, apply it
-- to the answer of 2nd parser.
(<*>) :: Parser (a -> b) -> Parser a -> Parser b
pf <*> pa = liftA2 (\f a -> f a) pf pa

infixl 4 <*>

-- | Compose 3 parsers sequentially. Like liftA2 but 3.  In general every liftAn
-- can be done by pure and <*>.
liftA3 :: (a -> b -> c -> d) -> Parser a -> Parser b -> Parser c -> Parser d
liftA3 f pa pb pc = ((pure f <*> pa) <*> pb) <*> pc
-- Note: Those parentheses are redundant, <*> is left-associative.

-- | A "trivial" parser that yields the specified answer without consuming input.
--
-- Kind of identity of liftA2 and (<*>):
--
-- liftA2 op (pure a) pb = fmap (\b -> op a b) pb
-- liftA2 op pa (pure b) = fmap (\a -> op a b) pa
-- pure f <*> pa = fmap f pa
-- pf <*> pure a = fmap (\f -> f a) pf
pure :: a -> Parser a
pure a = MkParser (\_ inp -> Just (inp, a))

-- | Compose two parsers sequentially.  2nd parser varies over answer from 1st
-- parser.
--
-- pure is kind of identity too:
--
-- pure a >>= k = k a
-- k >>= pure = k
(>>=) :: Parser a -> (a -> Parser b) -> Parser b
MkParser sf1 >>= k = MkParser g
  where
    g n inp = case sf1 n inp of
                Nothing -> Nothing
                Just (rest, a) -> unParser (k a) n rest

infixl 1 >>=

-- | Alternation. Try 1st parser. If success, done; if failure, 2nd parser.
(<|>) :: Parser a -> Parser a -> Parser a
MkParser sf1 <|> p2 = MkParser g
  where
    g n inp = case sf1 n inp of
                Nothing -> unParser p2 n inp
                j -> j        -- the Just case

infixl 3 <|>

-- | Always fail. Identity of <|>.
empty :: Parser a
empty = MkParser (\_ _ -> Nothing)

-- | 0 or 1 time.
optional :: Parser a -> Parser (Maybe a)
optional p = fmap Just p <|> pure Nothing
-- Try 1 time. If success, tag with Just; if failure, answer Nothing.

-- | 0 or more times, maximum munch, collect the answers into a list.
many :: Parser a -> Parser [a]
many p = some p <|> pure []
-- Explanation: To repeat 0 or more times, first try 1 or more
-- times!  If that fails, then we know it's 0 times, and the answer is the
-- empty list.

-- | 1 or more times, maximum munch, collect the answers into a list.
some :: Parser a -> Parser [a]
some p = liftA2 (:) p (many p)
-- Explanation: To repeat 1 or more times, do 1 time, then 0 or more times!


-------------------------
-- Token-level primitives
-------------------------

-- | Space or tab or newline (unix and windows).
whitespace :: Parser Char
whitespace = satisfy (\c -> c `elem` ['\t', '\n', '\r', ' '])

-- | Consume zero or more whitespaces, maximum munch.
whitespaces :: Parser String
whitespaces = many whitespace

-- | Read a natural number (non-negative integer), then skip trailing spaces.
natural :: Parser Integer
natural = fmap read (some (satisfy isDigit)) <* whitespaces
-- read :: Read a => String -> a
-- For converting string to your data type, assuming valid string.  Integer
-- is an instance of Read, and our string is valid, so we can use read.

-- | Read an identifier, then skip trailing spaces.  The list is a list of
-- reserved words to avoid.
identifier :: [String] -> Parser String
identifier keywords =
    satisfy isAlpha
    >>= \c -> many (satisfy isAlphaNum)
    >>= \cs -> whitespaces
    *> let str = c:cs
    in if str `elem` keywords then empty else pure str

-- | Read the wanted reserved word, then skip trailing spaces.
keyword :: String -> Parser String
keyword wanted =
    satisfy isAlpha
    >>= \c -> many (satisfy isAlphaNum)
    >>= \cs -> whitespaces
    *> if c:cs == wanted then pure wanted else empty

-- | Read something that looks like an operator, then skip trailing spaces.
anyOperator :: Parser String
anyOperator = some (satisfy symChar) <* whitespaces
  where
    symChar c = c `elem` "!#$%&*+-./:<=>?@\\^|~"

-- | Read the wanted operator, then skip trailing spaces.
operator :: String -> Parser String
operator wanted =
    anyOperator
    >>= \sym -> if sym == wanted then pure wanted else empty

-- | Open and close parentheses.
openParen, closeParen :: Parser Char
openParen = char '(' <* whitespaces
closeParen = char ')' <* whitespaces


---------------------------------------
-- Canned solutions for infix operators
---------------------------------------

-- | One or more operands separated by an operator. Apply the operator(s) in a
-- right-associating way.
chainr1 :: Parser a               -- ^ operand parser
        -> Parser (a -> a -> a)   -- ^ operator parser
        -> Parser a               -- ^ whole answer
chainr1 getArg getOp = getArg
                       >>= \x ->     (getOp
                                      >>= \op -> chainr1 getArg getOp
                                      >>= \y -> pure (op x y))
                                 <|>
                                     pure x

-- | One or more operands separated by an operator. Apply the operator(s) in a
-- left-associating way.
chainl1 :: Parser a               -- ^ operand parser
        -> Parser (a -> a -> a)   -- ^ operator parser
        -> Parser a               -- ^ whole answer
chainl1 getArg getOp = getArg
                       >>= \x -> many (liftA2 (,) getOp getArg)
                       >>= \opys -> pure (foldl (\accum (op,y) -> op accum y) x opys)
