{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDBAPI.Boot
  ( boot,
  )
where

import Control.Monad
import Network.Wai.Handler.Warp
import Optics
import System.Environment
import JDBAPI.Config
import JDBAPI.Protolude
import JDBAPI.Servant.ApiSetup

boot :: (MonadIO m) => m ()
boot = do
  args <- liftIO getArgs
  let maybeConfigPath = fmap pack (headMaybe args)
  case maybeConfigPath of
    Nothing -> crashWithNoConfigFile args
    Just configPath -> do
      cfg <- readConfig configPath
      liftIO $ either crashWithBadConfig doRun cfg
  where
    crashWithNoConfigFile args = error $ "No path to a config file was specified! Args: " <> show args
    crashWithBadConfig e = error ("Bad config could not be parsed! " <> show e)
    doRun cfg = do
      startJDBAPIAPI cfg

startJDBAPIAPI :: (MonadIO m) => AppConfig ->  m ()
startJDBAPIAPI cfg  = do
  liftIO . BL.putStrLn $ "Starting REST API ..."
  liftIO $ runSettings apiSettings =<< mkApp cfg
  where
    apiSettings = setPort (cfg ^. #servant % #port) defaultSettings
