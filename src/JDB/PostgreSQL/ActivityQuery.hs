{-# OPTIONS_GHC -fno-warn-orphans #-}

module JDB.PostgreSQL.ActivityQuery () where

import Data.Time
import Data.UUID (UUID)
import Data.UUID.V4
import Free.AlaCarte
import JDB.Free.JDB
import JDB.Model.JDB
import Relude

instance Exec ActivityQuery where
  execAlgebra (GetActivities env next) = do
    uid <- liftIO nextRandom
    now <- liftIO getZonedTime
    anotherUid <- liftIO nextRandom
    zone <- liftIO getCurrentTimeZone

    let m =
          [ ( uid,
              ( ActivityResponse
                  { activity =
                      Activity
                        { identifier = uid,
                          displayName = "Some Activity you can Book",
                          description = "Do I really want to write something in the description ?",
                          timeslotGenMode = Daily,
                          unitCost = "20",
                          createdBy = anotherUid,
                          createdAt = now,
                          updatedAt = Nothing
                        },
                    availabilities =
                      [ ( TimeRange
                            { slotStart = addSecondsToZonedTime zone 12 now,
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
              )
            )
          ]

    next . fromList $ m

addSecondsToZonedTime zone seconds x = utcToZonedTime zone (addUTCTime (secondsToNominalDiffTime seconds) (zonedTimeToUTC x))
