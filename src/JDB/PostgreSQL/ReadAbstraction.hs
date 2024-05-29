{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.PostgreSQL.ReadAbstraction
  ( persistenceReadCall,
    fetchOpinions,
    fetchArtworks,
    fetchComments,
  )
where

import Data.UUID hiding (fromString)
import Data.Vector qualified as V
import Hasql.Decoders as D
import Hasql.Encoders as E
import Hasql.Pool qualified
import Hasql.Session qualified
import Hasql.Statement (Statement (..))
import RIO hiding (Vector, (^.))
import RIO.ByteString.Lazy qualified as BL
import RIO.Map qualified as Map
import RIO.Text qualified as T
import RIO.Time

persistenceReadCall ::
  (MonadIO m) =>
  Hasql.Pool.Pool ->
  Hasql.Session.Session b1 ->
  ([a] -> b2) ->
  (b1 -> [a]) ->
  m b2
persistenceReadCall pool sessionCreateF responseCreateF vectorParseF = do
  eitherItems <- liftIO $ Hasql.Pool.use pool sessionCreateF
  either
    ( \err -> do
        BL.putStrLn . fromString . show $ err
        pure $ responseCreateF []
    )
    (pure . responseCreateF . vectorParseF)
    eitherItems
