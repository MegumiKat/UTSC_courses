-- How to use: runghc testHex2.hs

import ParserLib
import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
import TestLib

import Hex2 (hex2)

tests =
    [ "0x4c" ~: runParser hex2 "0x4c" ~?= Just (4*16 + 12)
    , "0xd7" ~: runParser hex2 "0xd7" ~?= Just (13*16 + 7)
    , "0x93" ~: runParser hex2 "0x93" ~?= Just (9*16 + 3)
    , "0xbe" ~: runParser hex2 "0xbe" ~?= Just (11*16 + 14)
    , "0xhi" ~: runParser hex2 "0xhi" ~?= Nothing
    , "93" ~: runParser hex2 "93" ~?= Nothing
    ]

main = testlibMain tests
