module RIVSDef where

-- A “real inner-product vector space” is a vector space that has an inner
-- product (e.g., dot product for ℝ²), using real numbers (let's say Double) for
-- scalars.  It supports the following operations:

class RIVS a where
    -- zero vector
    zero :: a
    -- adding two vectors
    plus :: a -> a -> a
    -- additive inverse, plus v (neg v) = zero
    neg :: a -> a
    -- subtracting two vectors
    minus :: a -> a -> a
    -- multiplying by scalar
    scale :: Double -> a -> a
    -- inner product
    dot :: a -> a -> Double

    -- Default implementations so you just override one of {minus, neg}
    minus u v = plus u (neg v)
    neg v = minus zero v


-- The benefit of having RIVS is that algorithms for inner-product spaces can be
-- coded up polymorphically, e.g.,

-- Split a vector into two parts: projection on to a subspace, orthogonal part.
-- The subspace is the span of ws. Assume that ws is an orthonormal list of
-- vectors.
resolve :: RIVS a => a -> [a] -> (a, a)
resolve v ws = (prj, minus v prj)
  where
    prj = foldl plus zero [scale (dot v w) w | w <- ws]


-- ℝ² is a well known real inner-product vector space, and is represented by the
-- R2 type below. In RIVS.hs, it is your turn to make it an instance of RIVS.

data R2 = MkR2 Double Double
    deriving (Eq, Show)

-- ℝ⁵ is also a real inner-product space. Here is a representation using a list,
-- and we assume/assure that the length is 5. This is unsatisfactory because the
-- length is not enforced by the type, but we're just doing a toy exercise. :)
-- Advanced Haskell and some advanced languages have a better way.

data R5L = MkR5L [Double]
    deriving (Eq, Show)

