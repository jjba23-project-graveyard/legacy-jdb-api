{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE QuasiQuotes #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module JDB.PostgreSQL.ActivityQuery () where

import Data.ByteString.Lazy qualified as BL
import Data.Map qualified as Map
import Data.Text (pack, unpack)
import Data.Time
import Data.Vector qualified as V
import Free.AlaCarte
import Hasql.Decoders as D
import Hasql.Encoders as E
import Hasql.Pool qualified
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))
import JDB.Free.JDB
import JDB.Model.JDB
import NeatInterpolation
import Optics
import Relude

instance Exec ActivityQuery where
  execAlgebra (GetActivities env next) = do
    zone <- getCurrentTimeZone
    let parseActivityRows = do
          mapM
            ( \row -> do
                activity <- activityFromRow zone row
                pure (activity ^. #identifier, activity)
            )

    let query =
          [untrimming|
          SELECT activities.identifier, activities.display_name, activities.description,
            activities.timeslot_gen_mode, activities.unit_cost, activities.created_by,
            activities.created_at, activities.updated_at
          FROM activities
          ORDER BY activities.created_at DESC
          LIMIT ($$1)
          |]
        encoder = E.param . E.nonNullable $ E.int8
        stmt = Statement (encodeUtf8 query) encoder activityRowDecoder True
    eitherItems <- liftIO $ Hasql.Pool.use (env ^. #pool) (Session.statement 1000 stmt)
    case eitherItems of
      Left e -> do
        liftIO . BL.putStr . fromString . show $ e
        next Map.empty
      Right queryResults -> do
        let xs = V.toList queryResults
        parsed <- liftIO $ parseActivityRows xs
        next $ Map.fromList parsed

activityFromRow zone (identifier, displayName, description, timeslotGenMode, unitCost, createdBy, createdAt, updatedAt) = do
  pure $
    Activity
      { identifier = identifier,
        displayName = displayName,
        description = description,
        timeslotGenMode = read . unpack $ timeslotGenMode,
        unitCost = unitCost,
        createdBy = createdBy,
        createdAt = utcToZonedTime zone createdAt,
        updatedAt = fmap (utcToZonedTime zone) updatedAt
      }

activityRowDecoder = D.rowVector vector
  where
    vector =
      (,,,,,,,)
        <$> D.column (D.nonNullable D.uuid)
        <*> D.column (D.nonNullable D.text)
        <*> D.column (D.nonNullable D.text)
        <*> D.column (D.nonNullable D.text)
        <*> D.column (D.nonNullable D.text)
        <*> D.column (D.nonNullable D.uuid)
        <*> D.column (D.nonNullable D.timestamptz)
        <*> D.column (D.nullable D.timestamptz)
