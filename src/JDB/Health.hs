{-# OPTIONS_GHC -fno-warn-orphans #-}
module JDB.Health (                     ) where




import Data.Text
import Data.Time
import Free.AlaCarte
import GHC.Show
import Relude hiding (Show, show)
import JDB.Free.JDB

instance Exec HealthService where
  {-# INLINEABLE execAlgebra #-}
  execAlgebra (Health next) = next "UP"

