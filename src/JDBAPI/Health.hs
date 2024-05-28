{-# OPTIONS_GHC -fno-warn-orphans #-}
module JDBAPI.Health (
  
                     ) where




import Data.Text
import Data.Time
import Free.AlaCarte
import GHC.Show
import Relude hiding (Show, show)
import JDBAPI.Free.JDBAPI

instance Exec Health where
  {-# INLINEABLE execAlgebra #-}
  execAlgebra (Health next) = pure "UP" >>= next

