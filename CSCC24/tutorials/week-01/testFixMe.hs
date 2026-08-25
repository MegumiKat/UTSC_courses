{-
How to use:

* All tests: runghc testFixMe.hs

* Individual test e.g. 2nd: runghc testFixMe.hs 1
-}

import TestLib
import FixMe (powmod)

tests = [ "7^0 mod 10" ~:
          powmod 10 7 0 ~?= 1
        , "23^31337 mod 10000" ~:
          powmod 10000 23 31337 ~?= 5703
        , "23^31337 mod 2^65" ~:
          fromIntegral (powmod (2^65) 23 31337) ~?= 5246753368606586071
        -- more tests during marking
        ]

main = testlibMain tests
