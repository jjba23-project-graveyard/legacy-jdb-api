{-# OPTIONS_GHC -fno-warn-orphans #-}

module JDBAPI.Clock.LiveClock () where

import Data.Text (pack)
import Data.Time
import Free.AlaCarte
import Relude
import JDBAPI.Free.Clock

instance Exec Clock where
  {-# INLINEABLE execAlgebra #-}
  execAlgebra (TimeElapsedUntilNow fromTime f) = do
    diffWithNow fromTime >>= f
  execAlgebra (Now f) = do
    getCurrentTime >>= f

diffWithNow :: (MonadIO m) => UTCTime -> m Text
diffWithNow fromTime = do
  now' <- liftIO getCurrentTime
  pure $ pack . show $ diffUTCTime now' fromTime
    
