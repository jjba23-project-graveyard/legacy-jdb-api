{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE QuasiQuotes #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module JDB.PostgreSQL.ActivityQuery () where

import Data.ByteString.Lazy qualified as BL
import Data.Fixed (Pico)
import Data.Map qualified as Map
import Data.Time
import Data.Time.LocalTime
import Data.Vector qualified as V
import Free.AlaCarte
import Hasql.Decoders as D
import Hasql.Encoders as E
import Hasql.Pool qualified
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
          mapM
            ( \row -> do
                activityResponse <- activityFromRow zone row
                pure (activityResponse ^. #activity % #identifier, activityResponse)
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
        next $ GetActivitiesResponse {activities = Map.empty, sortOrder = []}
      Right queryResults -> do
        let xs = V.toList queryResults
        parsed <- liftIO $ parseActivityRows xs
        next $
          GetActivitiesResponse
            { activities = Map.fromList parsed,
              sortOrder = map fst parsed
            }

activityFromRow zone (identifier, displayName, description, _, unitCost, createdBy, createdAt, updatedAt) = do
  availabilities <- availabilityFromMode Daily
  pure $
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
        availabilities = availabilities
      }

availabilityFromMode :: (MonadIO m) => TimeslotGenMode -> m [TimeRange]
availabilityFromMode Daily = do
  now <- liftIO getZonedTime
  timeZone <- liftIO getCurrentTimeZone
  let today = utctDay $ zonedTimeToUTC now

  let mkDayAtMidnight daysToAdd =
        utcToZonedTime timeZone
          . localTimeToUTC timeZone
          $ LocalTime {localDay = addDays daysToAdd today, localTimeOfDay = midnight}

  let advancedRanges =
        map
          ( ( \day ->
                TimeRange
                  { slotStart = day,
                    slotEnd = addSecondsToZonedTime timeZone 86400 day
                  }
            )
              . mkDayAtMidnight
          )
          [0 .. daysInAdvanceToShow]
      previousRanges =
        map
          ( ( \day ->
                TimeRange
                  { slotStart = addSecondsToZonedTime timeZone (-86400) day,
                    slotEnd = day
                  }
            )
              . mkDayAtMidnight
          )
          [daysInPastToShow .. 0]

  pure $ previousRanges ++ advancedRanges
  where
    daysInAdvanceToShow = 10
    daysInPastToShow = -2
availabilityFromMode _ = pure []

addSecondsToZonedTime :: TimeZone -> Pico -> ZonedTime -> ZonedTime
addSecondsToZonedTime zone seconds x = utcToZonedTime zone (addUTCTime (secondsToNominalDiffTime seconds) (zonedTimeToUTC x))

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
