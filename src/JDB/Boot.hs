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
import Hasql.Pool
import Hasql.Pool.Config
import Hasql.Pool.Config qualified as Config
import Hasql.Pool.Config.Defaults qualified as Defaults
import Hasql.Session qualified as Session
import Hasql.Statement qualified as Statement
import JDB.Config
import JDB.Model.Config
import JDB.PostgreSQL.Migration
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
      pool <- makePostgresPool cfg
      redisConn <- makeRedisConn cfg
      startJDBAPI cfg pool redisConn

startJDBAPI :: (MonadIO m) => AppConfig -> Hasql.Pool.Pool -> Redis.Connection -> m ()
startJDBAPI cfg pool redisConn = do
  maybeRunMigrations
  liftIO . BL.putStr $ "Starting REST API ..."
  liftIO $ runSettings apiSettings =<< mkApp cfg pool redisConn
  where
    apiSettings = setPort (cfg ^. #servant % #port) defaultSettings
    maybeRunMigrations = do
      when (cfg ^. #postgresql % #runMigrations) $ do
        liftIO . BL.putStr $ "Starting database migrations ..."
        ex <- liftIO . runJDBMigrations $ pool
        liftIO . BL.putStr . fromString . show $ ex
        pure ()

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
  pool <-
    liftIO $
      Hasql.Pool.acquire
        ( Hasql.Pool.Config.settings
            [ Config.staticConnectionSettings dbConnectionSettings
            ]
        )
  let healthSess = Session.sql "SELECT 1"
  s <- liftIO $ Hasql.Pool.use pool healthSess
  either (liftIO . BL.putStr . fromString . show) pure s

  pure pool
  where
    dbConnectionSettings =
      Hasql.Connection.settings
        (fromString . unpack $ cfg ^. #postgresql % #host)
        (fromIntegral $ cfg ^. #postgresql % #port)
        (fromString . unpack $ cfg ^. #postgresql % #user)
        (maybe "" (fromString . unpack) (cfg ^. #postgresql % #password))
        (fromString . unpack $ cfg ^. #postgresql % #name)
