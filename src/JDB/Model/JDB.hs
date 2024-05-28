{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.Model.JDB
  ( Request,
    validateRequest,
    Activity (..),
    validateActivity,
    OfflineRange (..),
    ActivityResponse (..),
    TimeRange (..),
    TimeslotGenMode (..),
  )
where

import Data.Aeson hiding (Success)
import Data.OpenApi
import Data.Time
import Data.Time.LocalTime
import Data.UUID
import Keuringsdienst
import Keuringsdienst.Helpers
import Optics
import Relude

data TimeRange = TimeRange
  { slotStart :: ZonedTime,
    slotEnd :: ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''TimeRange

data Request = Request
  { identifier :: UUID,
    clientIdentifier :: UUID,
    timeRange :: TimeRange,
    activityIdentifier :: UUID,
    createdAt :: ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Request

validateRequest :: Request -> ValidationResult
validateRequest x =
  show (x ^. #identifier)
    |?| isNonEmptyText
    <> show (x ^. #clientIdentifier)
      |?| isNonEmptyText
    <> show (x ^. #activityIdentifier)
      |?| isNonEmptyText

data TimeslotGenMode = Quarterly | Hourly | Daily
  deriving (Eq, Show, Generic, FromJSON, ToJSON, ToSchema)

data Activity = Activity
  { identifier :: UUID,
    displayName :: Text,
    description :: Text,
    createdAt :: ZonedTime,
    timeslotGenMode :: TimeslotGenMode
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Activity

validateActivity :: Activity -> ValidationResult
validateActivity x =
  show (x ^. #identifier)
    |?| isNonEmptyText
    <> (x ^. #displayName)
      |?| isNonEmptyText
    <> (x ^. #description)
      |?| isNonEmptyText

data OfflineRange = OfflineRange
  { identifier :: UUID,
    timeRange :: TimeRange,
    createdAt :: ZonedTime,
    activityIdentifier :: UUID
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''OfflineRange

data ActivityResponse = ActivityResponse
  { identifier :: UUID,
    displayName :: Text,
    description :: Text,
    createdAt :: ZonedTime,
    timeslotGenMode :: TimeslotGenMode,
    offlineRanges :: [OfflineRange],
    availabilities :: [TimeRange]
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''ActivityResponse
