{-# OPTIONS_GHC -fno-warn-orphans #-}

module JDB.Time.TimeRangeCalculator () where

import Data.Fixed (Pico)
import Data.Time
import Free.AlaCarte
import JDB.Free.JDB
import JDB.Model.JDB
import Relude

instance Exec TimeRangeCalculator where
  execAlgebra (RangesFromMode mode next) = next =<< availabilityFromMode mode

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
