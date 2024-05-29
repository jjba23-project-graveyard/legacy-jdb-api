{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE QuasiQuotes #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module JDB.PostgreSQL.ActivityQuery () where

import Data.Map qualified as Map
import Data.Time
import Data.Vector qualified as V
import Free.AlaCarte
import Hasql.Decoders as D
import Hasql.Encoders as E
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))
import JDB.Free.JDB
import JDB.Model.JDB
import JDB.PostgreSQL.ReadAbstraction qualified as ReadAbstraction
import NeatInterpolation
import Optics
import Relude

instance Exec ActivityQuery where
  execAlgebra (GetActivities env next) = do
    zone <- getCurrentTimeZone
    let parseActivityRows = do
          map
            ( \row ->
                let activityResponse = activityFromRow zone row
                 in (activityResponse ^. #activity % #identifier, activityResponse)
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
    r <-
      ReadAbstraction.persistenceReadCall
        (env ^. #pool)
        (Session.statement 1000 stmt)
        (\queryResults -> (Map.fromList queryResults, map fst queryResults))
        (parseActivityRows . V.toList)
    next $ GetActivitiesResponse {activities = fst r, sortOrder = snd r}

activityFromRow zone (identifier, displayName, description, _, unitCost, createdBy, createdAt, updatedAt) =
  ActivityResponse
    { activity =
        Activity
          { identifier = identifier,
            displayName = displayName,
            description = description,
            timeslotGenMode = Daily,
            unitCost = unitCost,
            createdBy = createdBy,
            createdAt = utcToZonedTime zone createdAt,
            updatedAt = fmap (utcToZonedTime zone) updatedAt
          },
      availabilities = []
    }

-- addSecondsToZonedTime zone seconds x = utcToZonedTime zone (addUTCTime (secondsToNominalDiffTime seconds) (zonedTimeToUTC x))

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
