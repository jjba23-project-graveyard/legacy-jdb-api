module Main (main) where

import Control.Monad.IO.Class
import JDBAPI.Boot qualified
import JDBAPI.Protolude

main :: (MonadIO m) => m ()
main = liftIO $ JDBAPI.Boot.boot
