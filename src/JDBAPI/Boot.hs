{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDBAPI.Boot
  ( boot,
  )
where

import Control.Monad
import Database.Redis qualified as Redis
import Hasql.Connection qualified
import Hasql.Pool qualified
import Hasql.Session qualified
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
      pool <- makePostgresPool cfg
      redisConn <- makeRedisConn cfg
      startJDBAPIAPI cfg pool redisConn

startJDBAPIAPI :: (MonadIO m) => AppConfig -> Hasql.Pool.Pool -> Redis.Connection -> m ()
startJDBAPIAPI cfg pool redisConn = do
  maybeRunMigrations
  liftIO . BL.putStrLn $ "Starting REST API ..."
  liftIO $ runSettings apiSettings =<< mkApp cfg pool redisConn
  where
    apiSettings = setPort (cfg ^. #servant % #port) defaultSettings
    maybeRunMigrations = do
      when (cfg ^. #postgresql % #runMigrations) $ do
        liftIO . BL.putStrLn $ "Starting database migrations ..."
        ex <- liftIO . runJDBAPIMigrations $ pool
        liftIO . BL.putStrLn . fromString . show $ ex
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
  pool <- liftIO $ Hasql.Pool.acquire (cfg ^. #postgresql % #poolSize) 10 10 10 dbConnectionSettings

  let healthSess = Hasql.Session.sql "SELECT 1"
  s <- liftIO $ Hasql.Pool.use pool healthSess
  either (BL.putStrLn . fromString . show) pure s

  pure pool
  where
    dbConnectionSettings =
      Hasql.Connection.settings
        (fromString . unpack $ cfg ^. #postgresql % #host)
        (fromIntegral $ cfg ^. #postgresql % #port)
        (fromString . unpack $ cfg ^. #postgresql % #user)
        (maybe "" (fromString . unpack) (cfg ^. #postgresql % #password))
        (fromString . unpack $ cfg ^. #postgresql % #name)
