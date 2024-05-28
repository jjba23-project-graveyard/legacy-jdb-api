{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDBAPI.Config (readConfig) where

import Data.Text.Encoding qualified
import Relude
import Data.ByteString.Lazy qualified as BL
import Optics
import Data.Text(pack, unpack, strip)
import Toml
import JDBAPI.Model.Config
import JDBAPI.Protolude

readConfig :: (MonadIO m) => Text -> m (Either Text AppConfig)
readConfig filePath = do
  parseResult <- liftIO $ decodeFileEither appConfigCodec (unpack filePath)
  case parseResult of
    Left e -> pure . Left $ prettyTomlDecodeErrors e
    Right r -> readSecrets r <&> Right

readSecrets :: (MonadIO m) => AppConfig -> m AppConfig
readSecrets cfg = do
  postgresqlPassword <- readSecretFromFile cfg (^. #postgresql % #passwordFile)
  redisPassword <- readSecretFromFile cfg (^. #redis % #passwordFile)
  mailPassword <- readSecretFromFile cfg (^. #mail % #passwordFile)
  let withRedisCfg = cfg & #redis .~ ((cfg ^. #redis) & #password ?~ redisPassword)
      withPostgresCfg =
        withRedisCfg
          & #postgresql
            .~ ((withRedisCfg ^. #postgresql) & #password ?~ postgresqlPassword)
      finalCfg =
        withPostgresCfg
          & #mail
            .~ ((withPostgresCfg ^. #mail) & #password ?~ mailPassword)
  pure finalCfg

readSecretFromFile :: (MonadIO m) => t -> (t -> Text) -> m Text
readSecretFromFile cfg getFilePath = do
  passwordFileContents <- liftIO . BL.readFile . unpack . getFilePath $ cfg
  pure
    . strip
    . Data.Text.Encoding.decodeUtf8
    . BL.toStrict
    $ passwordFileContents
