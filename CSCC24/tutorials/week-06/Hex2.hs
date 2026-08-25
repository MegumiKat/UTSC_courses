module Hex2 where

import Data.Char
import ParserLib
import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))

hexDigitValue :: Char -> Int
hexDigitValue c
  | '0' <= c && c <= '9' = ord c - ord '0'
  | 'a' <= c && c <= 'f' = ord c - ord 'a' + 10
  | otherwise = error "invalid hex digit"

-- String parser that matches a specific string.
string :: String -> Parser String
string [] = pure []
string (x:xs) = char x *> string xs *> pure (x:xs)

-- Parser that accepts a single hexadecimal digit.
hexDigit :: Parser Char
hexDigit = satisfy (\c -> ('0' <= c && c <= '9') || ('a' <= c && c <= 'f'))
-- Write a parser that accepts the 0x notation for exactly 2 hexadecimal digits.
-- In BNF it would be
--
-- hex2 ::= "0x" digit digit
-- digit ::= '0' | ... | '9' | 'a' | ... | 'f'
--
-- The parser should return the number instead of the string, e.g., with "0x1a"
-- return the Int 26 (1*16 + 10).  See also the sample test cases.
--
-- If the input string has more digits, e.g., "0x123", it's OK, just consume
-- "0x12".
--
-- Don't worry about uppercase X or A-F (won't be tested). But "0xhi" should
-- definitely be rejected.
hex2 :: Parser Int
hex2 = string "0x" *> liftA2 combine hexDigit hexDigit
  where
    combine d1 d2 = hexDigitValue d1 * 16 + hexDigitValue d2

