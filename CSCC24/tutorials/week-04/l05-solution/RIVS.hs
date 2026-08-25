module RIVS where

import RIVSDef

-- Make R2 an instance of RIVS.
instance RIVS R2 where
    zero = MkR2 0 0
    plus (MkR2 x1 x2) (MkR2 y1 y2) = MkR2 (x1 + y1) (x2 + y2)
    scale r (MkR2 x1 x2) = MkR2 (r*x1) (r*x2)
    dot (MkR2 x1 x2) (MkR2 y1 y2) = x1*y1 + x2*y2
    -- need just one of the following two
    minus (MkR2 x1 x2) (MkR2 y1 y2) = MkR2 (x1 - y1) (x2 - y2)
    neg (MkR2 x1 x2) = MkR2 (- x1) (- x2)

-- Make R5L an instance of RIVS. You can use map, zipWith, sum.
instance RIVS R5L where
    zero = MkR5L [0, 0, 0, 0, 0]
    plus (MkR5L v) (MkR5L w) = MkR5L (zipWith (+) v w)
    scale r (MkR5L v) = MkR5L (map (\x -> r*x) v)
    dot (MkR5L v) (MkR5L w) = sum (zipWith (*) v w)
    -- need just one of the following two
    minus (MkR5L v) (MkR5L w) = MkR5L (zipWith (-) v w)
    neg (MkR5L v) = MkR5L (map negate v)

