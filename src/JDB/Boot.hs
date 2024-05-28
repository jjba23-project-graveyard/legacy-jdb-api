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
import Database.Redis qualified as Redis
import Hasql.Connection qualified
import Hasql.Pool qualified
import Hasql.Session qualified
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

makeRedisConn :: (MonadIO m) => AppConfig -> m Redis.Connection
makeRedisConn cfg = liftIO $ Redis.checkedConnect redisConnectionSettings
  where
    redisConnectionSettings =
      Redis.defaultConnectInfo
        { Redis.connectPort = Redis.PortNumber (fromIntegral $ cfg ^. #redis % #port),
          Redis.connectAuth = fmap (fromString . unpack) (cfg ^. #redis % #password)
        }

makePostgresPool :: (MonadIO m) => AppConfig -> m Hasql.Pool.Pool
makePostgresPool cfg = do
  pool <- liftIO $ Hasql.Pool.acquire (cfg ^. #postgresql % #poolSize) 10 10 10 dbConnectionSettings

  let healthSess = Hasql.Session.sql "SELECT 1"
  s <- liftIO $ Hasql.Pool.use pool healthSess
  either (BL.putStr . fromString . show) pure s

  pure pool
  where
    dbConnectionSettings =
      Hasql.Connection.settings
        (fromString . unpack $ cfg ^. #postgresql % #host)
        (fromIntegral $ cfg ^. #postgresql % #port)
        (fromString . unpack $ cfg ^. #postgresql % #user)
        (maybe "" (fromString . unpack) (cfg ^. #postgresql % #password))
        (fromString . unpack $ cfg ^. #postgresql % #name)
