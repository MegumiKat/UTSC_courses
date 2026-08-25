module RIVS where

import RIVSDef

-- Make R2 an instance of RIVS.
instance RIVS R2 where
    zero = MkR2 0 0

    plus (MkR2 x1 y1) (MkR2 x2 y2) = MkR2 (x1 + x2) (y1 + y2)

    neg (MkR2 x y) = MkR2 (-x) (-y)

    scale s (MkR2 x y) = MkR2 (s * x) (s * y)

    dot (MkR2 x1 y1) (MkR2 x2 y2) = x1 * x2 + y1 * y2


-- Make R5L an instance of RIVS. You can use map, zipWith, sum.
instance RIVS R5L where
    zero = MkR5L [0, 0, 0, 0, 0]

    plus (MkR5L v1) (MkR5L v2) = MkR5L (zipWith (+) v1 v2)

    neg (MkR5L v) = MkR5L (map negate v)

    scale s (MkR5L v) = MkR5L (map (s *) v)

    dot (MkR5L v1) (MkR5L v2) = sum (zipWith (*) v1 v2)
