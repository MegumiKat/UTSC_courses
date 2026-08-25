#!/bin/sh

loadthis=testFixMe.hs
scanthis=FixMe.hs

# abort at the first failing command
set -e

# First, ask GHC to load the file (and then do nothing).
ghc $loadthis -e ''

# Ah but need to guard against students just deleting code, so let's check for
# some strings.
tr -d '\t\n\r ' < $scanthis | grep -q 'powmod::'
grep -q '==' $scanthis
grep -q 'div' $scanthis
grep -q -i 'mod' $scanthis

