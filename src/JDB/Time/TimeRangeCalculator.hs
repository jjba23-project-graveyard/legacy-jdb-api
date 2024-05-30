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

  _ <- traceM ("daily ranges: " <> show (length previousRanges, length advancedRanges))

  pure $ previousRanges ++ advancedRanges
  where
    daysInAdvanceToShow = 60
    daysInPastToShow = -2
    mkPreviousRange timeZone moment =
      TimeRange
        { slotStart = addSecondsToZonedTime timeZone moment (-86400),
          slotEnd = moment
        }
    mkAdvanceRange timeZone moment =
      TimeRange
        { slotStart = moment,
          slotEnd = addSecondsToZonedTime timeZone moment 86400
        }
availabilityFromMode Hourly = do
  now <- liftIO getZonedTime
  timeZone <- liftIO getCurrentTimeZone

  -- 3600 * 1024h
  let advanced = [0, 3600 .. 3686400]
      advancedRanges =
        map (mkAdvanceRange timeZone . addSecondsToZonedTime timeZone now) advanced
      -- 3600 * 48h
      previous = [-172800, -169200 .. 0]
      previousRanges =
        map (mkPreviousRange timeZone . addSecondsToZonedTime timeZone now) previous

  pure $ previousRanges ++ advancedRanges
  where
    mkPreviousRange timeZone moment =
      TimeRange
        { slotStart = addSecondsToZonedTime timeZone moment (-3600),
          slotEnd = moment
        }
    mkAdvanceRange timeZone moment =
      TimeRange
        { slotStart = moment,
          slotEnd = addSecondsToZonedTime timeZone moment 3600
        }
availabilityFromMode _ = pure []

addSecondsToZonedTime :: TimeZone -> ZonedTime -> Pico -> ZonedTime
addSecondsToZonedTime zone x seconds = utcToZonedTime zone (addUTCTime (secondsToNominalDiffTime seconds) (zonedTimeToUTC x))

warpNDaysAtMidnight :: TimeZone -> Day -> Integer -> ZonedTime
warpNDaysAtMidnight timeZone today daysToAdd =
  localTimeToZoned $
    LocalTime
      { localDay = addDays daysToAdd today,
        localTimeOfDay = midnight
      }
  where
    localTimeToZoned = utcToZonedTime timeZone . localTimeToUTC timeZone
