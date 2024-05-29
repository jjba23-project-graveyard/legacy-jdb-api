{-# LANGUAGE QuasiQuotes #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module JDB.PostgreSQL.ActivityQuery () where

import Data.Time
import Data.Vector qualified as V
import Data.UUID (UUID)
import Data.UUID.V4
import Free.AlaCarte
import JDB.Free.JDB
import JDB.Model.JDB
import NeatInterpolation
import Relude
import Hasql.Decoders as D
import Hasql.Encoders as E
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))

instance Exec ActivityQuery where
  execAlgebra (GetActivities env next) = do
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
    next . fromList $ []

activityFromRow (identifier, displayName, description, timeslotGenMode, unitCost, createdBy, createdAt, updatedAt) = Activity {..}

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


           
    -- uid <- liftIO nextRandom
    -- now <- liftIO getZonedTime
    -- anotherUid <- liftIO nextRandom
    -- zone <- liftIO getCurrentTimeZone

    -- let m =
    --       [ ( uid,
    --           ( ActivityResponse
    --               { activity =
    --                   Activity
    --                     { identifier = uid,
    --                       displayName = "Some Activity you can Book",
    --                       description = "Do I really want to write something in the description ?",
    --                       timeslotGenMode = Daily,
    --                       unitCost = "20",
    --                       createdBy = anotherUid,
    --                       createdAt = now,
    --                       updatedAt = Nothing
    --                     },
    --                 availabilities =
    --                   [ ( TimeRange
    --                         { slotStart = addSecondsToZonedTime zone 12 now,
    --                           slotEnd = addSecondsToZonedTime zone (123456 * 2) now
    --                         }
    --                     ),
    --                     ( TimeRange
    --                         { slotStart = addSecondsToZonedTime zone (12 * 3) now,
    --                           slotEnd = addSecondsToZonedTime zone (123456 * 3) now
    --                         }
    --                     ),
    --                     ( TimeRange
    --                         { slotStart = addSecondsToZonedTime zone (12 * 4) now,
    --                           slotEnd = addSecondsToZonedTime zone (123456 * 4) now
    --                         }
    --                     )
    --                   ]
    --               }
    --           )
    --         )
    --       ]

    -- next . fromList $ m
