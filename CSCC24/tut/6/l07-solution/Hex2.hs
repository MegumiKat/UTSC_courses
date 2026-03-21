module Hex2 where

import Data.Char
import ParserLib
import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))

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
hex2 = char '0' *> char 'x' *>
       liftA2 (\d1 d0 -> 16 * digitToInt d1 + digitToInt d0)
              (satisfy isHexDigit)
              (satisfy isHexDigit)
