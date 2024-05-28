module Main (main) where

import Control.Monad.IO.Class
import JDB.Boot qualified
import JDB.Protolude

main :: (MonadIO m) => m ()
main = liftIO $ JDB.Boot.boot
