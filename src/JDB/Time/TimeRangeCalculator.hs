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

  let advancedRanges =
        map (mkAdvanceRange timeZone . warpNDaysAtMidnight timeZone today) [0 .. daysInAdvanceToShow]
      previousRanges =
        map (mkPreviousRange timeZone . warpNDaysAtMidnight timeZone today) [daysInPastToShow .. 0]

  pure $ previousRanges ++ advancedRanges
  where
    daysInAdvanceToShow = 60
    daysInPastToShow = -2
    mkPreviousRange timeZone moment =
      TimeRange
        { slotStart = addSecondsToZonedTime timeZone (-86400) moment,
          slotEnd = moment
        }
    mkAdvanceRange timeZone moment =
      TimeRange
        { slotStart = moment,
          slotEnd = addSecondsToZonedTime timeZone 86400 moment
        }
-- availabilityFromMode Hourly = do
--   now <- liftIO getZonedTime
--   timeZone <- liftIO getCurrentTimeZone

--   let advancedRanges =
--         map (mkAdvanceRange timeZone . warpNHours timeZone now) [0 .. hoursInAdvanceToShow]
--       previousRanges =
--         map (mkPreviousRange timeZone . warpNHours timeZone now) [hoursInPastToShow .. 0]

--   pure $ previousRanges ++ advancedRanges
--   where
--     hoursInAdvanceToShow = 5
--     hoursInPastToShow = -4
--     mkPreviousRange timeZone moment =
--       TimeRange
--         { slotStart = addSecondsToZonedTime timeZone (-3600) moment,
--           slotEnd = moment
--         }
--     mkAdvanceRange timeZone moment =
--       TimeRange
--         { slotStart = moment,
--           slotEnd = addSecondsToZonedTime timeZone 3600 moment
--         }
availabilityFromMode _ = pure []

addSecondsToZonedTime :: TimeZone -> Pico -> ZonedTime -> ZonedTime
addSecondsToZonedTime zone seconds x = utcToZonedTime zone (addUTCTime (secondsToNominalDiffTime seconds) (zonedTimeToUTC x))

warpNHours :: TimeZone -> ZonedTime -> Pico -> ZonedTime
warpNHours zone moment hours = addSecondsToZonedTime zone (hours * 3600) moment

warpNDaysAtMidnight :: TimeZone -> Day -> Integer -> ZonedTime
warpNDaysAtMidnight timeZone today daysToAdd =
  localTimeToZoned $
    LocalTime
      { localDay = addDays daysToAdd today,
        localTimeOfDay = midnight
      }
  where
    localTimeToZoned = utcToZonedTime timeZone . localTimeToUTC timeZone
