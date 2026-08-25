-- How to use: runghc testHex2.hs

import ParserLib
import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
import TestLib

import Hex2 (hex2)

tests =
    [ "0x1a" ~: runParser hex2 "0x1a" ~?= Just (1*16 + 10)
    , "0xb2" ~: runParser hex2 "0xb2" ~?= Just (11*16 + 2)
    , "0x41" ~: runParser hex2 "0x41" ~?= Just (4*16 + 1)
    , "0xfc" ~: runParser hex2 "0xfc" ~?= Just (15*16 + 12)
    , "0xhi" ~: runParser hex2 "0xhi" ~?= Nothing
    , "12" ~: runParser hex2 "12" ~?= Nothing
    ]

main = testlibMain tests
