{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.Boot
  ( boot,
  )
where

import Control.Monad
import Data.ByteString.Lazy qualified as BL
import Data.Text (pack, unpack)
import JDB.Config
import JDB.Model.Config
import JDB.Servant.ApiSetup
import Network.Wai.Handler.Warp
import Optics
import Relude

boot :: (MonadIO m) => m ()
boot = do
  args <- liftIO getArgs
  case nonEmpty args of
    Just (x :| []) -> do
      cfg <- readConfig (pack x)
      liftIO $ either crashWithBadConfig doRun cfg
    _ -> crashWithNoConfigFile args
  where
    crashWithNoConfigFile args = error $ "No path to a config file was specified! Args: " <> show args
    crashWithBadConfig e = error ("Bad config could not be parsed! " <> show e)
    doRun cfg = do
      startJDBAPI cfg

startJDBAPI :: (MonadIO m) => AppConfig -> m ()
startJDBAPI cfg = do
  _ <- liftIO . BL.putStr $ "Starting REST API ..."
  liftIO $ runSettings apiSettings =<< mkApp cfg
  where
    apiSettings = setPort (cfg ^. #servant % #port) defaultSettings
