-- How to use: runghc testParser.hs

import ParserLib
import Prelude hiding (fmap, pure, (<*>), (<*), (*>), (>>=))
import TestLib
import WexprDef
import WexprParser (wexpr)

mainParser :: Parser Wexpr
mainParser = whitespaces *> wexpr <* eof

-- Tired of writing "runParser mainParser inp" heh.
runMain = runParser mainParser

bases =
    [ "natural" ~: runMain "148" ~?= Just (Nat 148)
    , "var" ~: runMain "inverse" ~?= Just (Var "inverse")
    , "\"and\" is not var" ~: runMain "and" ~?= Nothing
    , "\"where\" is not var" ~: runMain "where" ~?= Nothing
    ]

operators =
    [ "97 + 35"
      ~: runMain "97 + 35" ~?= Just (Plus (Nat 97) (Nat 35))
    , "time + money"
      ~: runMain "time + money" ~?= Just (Plus (Var "time") (Var "money"))
    , "83 - 61"
      ~: runMain "83 - 61" ~?= Just (Minus (Nat 83) (Nat 61))
    , "time - money"
      ~: runMain "time - money" ~?= Just (Minus (Var "time") (Var "money"))
    , "19 * 10"
      ~: runMain "19 * 10" ~?= Just (Times (Nat 19) (Nat 10))
    , "time * money"
      ~: runMain "time * money" ~?= Just (Times (Var "time") (Var "money"))
    , "- 97"
      ~: runMain "- 97" ~?= Just (Neg (Nat 97))
    , "- money"
      ~: runMain "- money" ~?= Just (Neg (Var "money"))
    ]

associativities =
    [ "56 + 12 + 53"
      ~: runMain "56 + 12 + 53" ~?= Just (Plus (Plus (Nat 56) (Nat 12)) (Nat 53))
    , "12 - 76 - 44"
      ~: runMain "12 - 76 - 44" ~?= Just (Minus (Minus (Nat 12) (Nat 76)) (Nat 44))
    , "56 + 12 - 53"
      ~: runMain "56 + 12 - 53" ~?= Just (Minus (Plus (Nat 56) (Nat 12)) (Nat 53))
    , "12 - 76 + 44"
      ~: runMain "12 - 76 + 44" ~?= Just (Plus (Minus (Nat 12) (Nat 76)) (Nat 44))
    , "57 * 97 * 21"
      ~: runMain "57 * 97 * 21" ~?= Just (Times (Times (Nat 57) (Nat 97)) (Nat 21))
    ]

precedences =
    [ "58 * 35 + 59 * 83"
      ~: runMain "58 * 35 + 59 * 83" ~?= Just (Plus (Times (Nat 58) (Nat 35))
                                                    (Times (Nat 59) (Nat 83)))
    , "58 * 35 - 59 * 83"
      ~: runMain "58 * 35 - 59 * 83" ~?= Just (Minus (Times (Nat 58) (Nat 35))
                                                     (Times (Nat 59) (Nat 83)))
    , "- 58 * 35"
      ~: runMain "- 58 * 35" ~?= Just (Times (Neg (Nat 58)) (Nat 35))
    , "58 + (35 + 59)"
      ~: runMain "58 + (35 + 59)" ~?= Just (Plus (Nat 58) (Plus (Nat 35) (Nat 59)))
    , "58 - (35 - 59)"
      ~: runMain "58 - (35 - 59)" ~?= Just (Minus (Nat 58) (Minus (Nat 35) (Nat 59)))
    , "(58 + 35) * (59 + 83)"
      ~: runMain "(58 + 35) * (59 + 83)" ~?= Just (Times (Plus (Nat 58) (Nat 35))
                                                         (Plus (Nat 59) (Nat 83)))
    , "- (58 + 35)"
      ~: runMain "- (58 + 35)" ~?= Just (Neg (Plus (Nat 58) (Nat 35)))
    ]

unaryminus =
    [ "27 + -1" ~: runMain "27 + -1" ~?= Just (Plus (Nat 27) (Neg (Nat 1)))
    , "27 * -1" ~: runMain "27 * -1" ~?= Just (Times (Nat 27) (Neg (Nat 1)))
    , "- - 20" ~: runMain "- - 20" ~?= Just (Neg (Neg (Nat 20)))
    , "-- 94" ~: runMain "-- 94" ~?= Nothing
    , "22 +-51" ~: runMain "22 +-51" ~?= Nothing
    ]

wher =
    [ "7 where a = 6"
      ~: runMain "7 where a = 6"
      ~?= Just (Where (Nat 7) [("a", Nat 6)])
    , "time where a = 6"
      ~: runMain "time where a = 6"
      ~?= Just (Where (Var "time") [("a", Nat 6)])
    , "where and"
      ~: runMain "time where a = 6 and c = 0"
      ~?= Just (Where (Var "time") [("a", Nat 6), ("c", Nat 0)])
    , "where and and"
      ~: runMain "time where a = 6 and c = 0 and money = 7"
      ~?= Just (Where (Var "time") [("a", Nat 6), ("c", Nat 0), ("money", Nat 7)])
    ]

nestedwher =
    [ "good nested where"
      ~: runMain "(time where y = 5) where z = (b where b = 1)"
      ~?= Just (Where (Where (Var "time") [("y", Nat 5)])
                      [("z", Where (Var "b") [("b", Nat 1)])])
    , "bad nested where"
      ~: runMain "time where y = 5 where z = b where b = 1" ~?= Nothing
    , "(z where z=0) * (g where g=1)"
      ~: runMain "(z where z=0) * (g where g=1)"
      ~?= Just (Times (Where (Var "z") [("z",Nat 0)])
                      (Where (Var "g") [("g",Nat 1)]))
    ]

large =
    [ "combined example"
      ~: runMain "(85 - z) * (z + 91) + (z * (11 + 20)) * ((28 - z) * 12) where z = 9 * 30 * 11 + 28 * 12"
      ~?= Just (Where (Plus (Times (Minus (Nat 85) (Var "z"))
                                   (Plus (Var "z") (Nat 91)))
                            (Times (Times (Var "z") (Plus (Nat 11) (Nat 20)))
                                   (Times (Minus (Nat 28) (Var "z")) (Nat 12))))
                [("z", Plus (Times (Times (Nat 9) (Nat 30)) (Nat 11))
                            (Times (Nat 28) (Nat 12)))])
    ]

tests = [Group bases, Group operators, Group associativities,
         Group precedences, Group unaryminus, Group wher, Group nestedwher,
         Group large]

main = testlibMain tests
