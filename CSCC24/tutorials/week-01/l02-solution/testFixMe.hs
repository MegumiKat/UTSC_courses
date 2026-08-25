{-
How to use:

* All tests: runghc testFixMe.hs

* Individual test e.g. 2nd: runghc testFixMe.hs 1
-}

import TestLib
import FixMe (powmod)

tests = [ "7^0 mod 10" ~:
          powmod 10 7 0 ~?= 1
        , "29^6941 mod 1473" ~:
          powmod 1473 29 6941 ~?= 749
        , "17^(3^20) mod 10^20" ~:
          fromIntegral (powmod (10^20) 17 (3^20)) ~?=
          (56414801472039584017 :: Integer)
        ]

-- There is 1 mark for just getting your code to compile! (check-syntax.sh)

main = testlibMain tests
