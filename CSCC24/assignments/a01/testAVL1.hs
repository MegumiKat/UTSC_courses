-- How to use: runghc tesAVL.hs

import AVL qualified (insert)
import AVLDef
import TestLib

insert :: (Ord k) => k -> AVL k -> AVL k
insert = AVL.insert

sampleInput :: AVL Integer
sampleInput =
  Node
    ( Node
        (singleton 10)
        20
        ( Node
            (singleton 30)
            40
            (singleton 50)
            2
        )
        3
    )
    60
    ( Node
        Empty
        70
        (singleton 80)
        2
    )
    4

-- If insert 35 into sample input. Triggers a double-rotation.
sampleOutput :: AVL Integer
sampleOutput =
  Node
    ( Node
        ( Node
            (singleton 10)
            20
            Empty
            2
        )
        30
        ( Node
            (singleton 35)
            40
            (singleton 50)
            2
        )
        3
    )
    60
    ( Node
        Empty
        70
        (singleton 80)
        2
    )
    4

-- If insert 90 into sample input. Triggers a double-rotation.
sampleOutput1 :: AVL Integer
sampleOutput1 =
  Node
    ( Node
        ( Node
            (singleton 10)
            20
            Empty
            2
        )
        30
        ( Node
            (singleton 35)
            40
            (singleton 50)
            2
        )
        3
    )
    60
    ( Node
        (singleton 70)
        80
        (singleton 90)
        2
    )
    4

-- insert  75
sampleOutput2 :: AVL Integer
sampleOutput2 =
  Node
    ( Node
        ( Node
            (singleton 10)
            20
            Empty
            2
        )
        30
        ( Node
            (singleton 35)
            40
            (singleton 50)
            2
        )
        3
    )
    60
    ( Node
        (Node Empty 70 (singleton 75) 2)
        80
        (singleton 90)
        3
    )
    4

-- insert  72
sampleOutput3 :: AVL Integer
sampleOutput3 =
  Node
    ( Node
        ( Node
            (singleton 10)
            20
            Empty
            2
        )
        30
        ( Node
            (singleton 35)
            40
            (singleton 50)
            2
        )
        3
    )
    60
    ( Node
        (Node (singleton 70) 72 (singleton 75) 2)
        80
        (singleton 90)
        3
    )
    4

-- insert  79
sampleOutput4 :: AVL Integer
sampleOutput4 =
  Node
    ( Node
        ( Node
            (singleton 10)
            20
            Empty
            2
        )
        30
        ( Node
            (singleton 35)
            40
            (singleton 50)
            2
        )
        3
    )
    60
    ( Node
        (Node (singleton 70) 72 Empty 2)
        75
        (Node (singleton 79) 80 (singleton 90) 2)
        3
    )
    4

-- insert  95
sampleOutput5 :: AVL Integer
sampleOutput5 =
  Node
    ( Node
        ( Node
            (singleton 10)
            20
            Empty
            2
        )
        30
        ( Node
            (singleton 35)
            40
            (singleton 50)
            2
        )
        3
    )
    60
    ( Node
        (Node (singleton 70) 72 Empty 2)
        75
        (Node (singleton 79) 80 (Node Empty 90 (singleton 95) 2) 3)
        4
    )
    5

-- insert  100
sampleOutput6 :: AVL Integer
sampleOutput6 =
  Node
    ( Node
        ( Node
            (singleton 10)
            20
            Empty
            2
        )
        30
        ( Node
            (singleton 35)
            40
            (singleton 50)
            2
        )
        3
    )
    60
    ( Node
        (Node (singleton 70) 72 Empty 2)
        75
        (Node (singleton 79) 80 (Node (singleton 90) 95 (singleton 100) 2) 3)
        4
    )
    5

tests =
  [ "sample" ~: insert 95 sampleOutput4 ~?= sampleOutput5
  ]

main = testlibMain tests
