module Test.Spec.Assertions.DeepDiffSpec
  ( deepDiffSpec
  ) where

import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Runner (RunnerEffects)
import Data.Maybe (isJust, maybe)

import Test.Spec.Assertions.DeepDiff (findFirstDifference)

deepDiffSpec :: ∀ e. Spec (RunnerEffects e) Unit
deepDiffSpec =
  describe "Test" $
    describe "Spec" $
      describe "Assertions" do
	describe "DeepDiff" do
	  it "detects changed value" do
	    let c = findFirstDifference { k1: "v1" } { k1: "vChanged" }
	    isJust c `shouldEqual` true
	    maybe (pure unit) (\c' -> c'.changeType `shouldEqual` "changed") c
	    maybe (pure unit) (\c' -> c'.path `shouldEqual` "k1") c
	  it "returns nothing when objects are identical" do
	    let c = findFirstDifference { k1: "v1" } { k1: "v1" }
	    isJust c `shouldEqual` false
	  it "returns nothing when nested objects are identical" do
	    let obj1 = { k1: { n1: { nn1: "nn1v" } } }
	        obj2 = { k1: { n1: { nn1: "nn1v" } } }
                c = findFirstDifference obj1 obj2
	    isJust c `shouldEqual` false
