-- | Contains assertions about JS objects using deep diffs. Useful for checking
-- | validity of types, data corruption, and detecting invalid structure,
-- | especially when unsafe code is used.
module Test.Spec.Assertions.DeepDiff
  ( deepDiffsShouldBeEqual
  , deepDiffsShouldNotBeEqual
  , deepDiff
  , getFirstChange
  , getFirstChangeFromDiff
  , ObjectDiff
  , Change
  ) where

import Prelude

import Control.Monad.Aff           (Aff())
import Test.Spec.Assertions (fail)
import Data.Maybe (Maybe(..), maybe)

foreign import data ObjectDiff :: Type

foreign import deepDiff :: forall obj1 obj2. obj1 -> obj2 -> ObjectDiff

type Change =
  { changeType :: String
  , path :: String
  }

foreign import _getFirstChange
  :: (Change -> Maybe Change) -> Maybe Change -> ObjectDiff -> Maybe Change

-- | Get the path to the first change in a diff, and the type of that change.
-- | E.g., { path: "key1.subkey1", changeType: "changed" }
getFirstChangeFromDiff :: ObjectDiff -> Maybe Change
getFirstChangeFromDiff = _getFirstChange (Just) (Nothing)

-- | Take two raw objects, diff them and return the path to the first difference
-- | alongside the type of that difference (changed, deleted, created).
getFirstChange :: forall obj1 obj2. obj1 -> obj2 -> Maybe Change
getFirstChange o1 o2 = getFirstChangeFromDiff $ deepDiff o1 o2

-- | Ensure that deep diffs of two JS objects are equal
deepDiffsShouldBeEqual :: forall obj1 obj2 r. obj1 -> obj2 -> Aff r Unit
deepDiffsShouldBeEqual obj1 obj2 =
  maybe
    (pure unit)
    (\p -> fail $ "Objects differ. Path '" <> p.path <>  "' " <> p.changeType)
    (getFirstChange obj1 obj2)

-- | Ensure that deep diffs of two JS objects are not equal
deepDiffsShouldNotBeEqual :: forall obj1 obj2 r. obj1 -> obj2 -> Aff r Unit
deepDiffsShouldNotBeEqual obj1 obj2 =
  maybe
    (fail "Object diff is identical. Expected them to be different.")
    (const $ pure unit)
    (getFirstChange obj1 obj2)
