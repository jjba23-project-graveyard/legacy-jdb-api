module JDB.Servant.JDBRoutes (healthRoute, getActivitiesRoute, getActivityRoute) where

import Data.Time
import Data.UUID (UUID)
import Data.UUID.V4
import Free.AlaCarte
import JDB.Free.JDB
import JDB.Health ()
import JDB.Model.JDB
import Relude
import Servant

healthRoute :: Handler Text
healthRoute = liftIO (exec @HealthService $ health)

getActivitiesRoute :: Handler [ActivityResponse]
getActivitiesRoute = do
  now <- liftIO getZonedTime
  _ <- print now
  uid <- liftIO nextRandom
  _ <- print uid
  zone <- liftIO getCurrentTimeZone
  _ <- print zone
  pure
    [ ActivityResponse
        { identifier = uid,
          displayName = "Some Activity you can Book",
          description = "Do I really want to write something in the description ?",
          createdAt = now,
          timeslotGenMode = Daily,
          offlineRanges =
            [ (OfflineRange {identifier = uid, timeRange = TimeRange {slotStart = now, slotEnd = addSecondsToZonedTime zone (123 * 3) now}, createdAt = now, activityIdentifier = uid})
            ],
          availabilities =
            [ ( TimeRange
                  { slotStart = addSecondsToZonedTime zone (12) now,
                    slotEnd = addSecondsToZonedTime zone (123456 * 2) now
                  }
              ),
              ( TimeRange
                  { slotStart = addSecondsToZonedTime zone (12 * 3) now,
                    slotEnd = addSecondsToZonedTime zone (123456 * 3) now
                  }
              ),
              ( TimeRange
                  { slotStart = addSecondsToZonedTime zone (12 * 4) now,
                    slotEnd = addSecondsToZonedTime zone (123456 * 4) now
                  }
              )
            ]
        }
    ]

addSecondsToZonedTime zone seconds x = utcToZonedTime zone (addUTCTime (secondsToNominalDiffTime seconds) (zonedTimeToUTC x))

getActivityRoute :: UUID -> Handler ActivityResponse
getActivityRoute identifier = throwError err404
