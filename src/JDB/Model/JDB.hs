{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.Model.JDB
  ( Request,
    Activity (..),
    OfflineRange (..),
    ActivityResponse (..),
    TimeRange (..),
    TimeslotGenMode (..),
  )
where

import Data.Aeson hiding (Success)
import Data.OpenApi
import Data.Time
import Data.UUID
import Optics
import Relude

data TimeRange = TimeRange
  { slotStart :: ZonedTime,
    slotEnd :: ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''TimeRange

data TimeslotGenMode
  = Monthly
  | Daily
  | WorkDays
  | Weekends
  | Hourly
  | FiveMinutes
  | Minute
  | TenMinutes
  | FifteenMinutes
  deriving (Eq, Show, Generic, FromJSON, ToJSON, ToSchema)

data PaymentStatus
  = Paid
  | ConfirmedNotReceived
  | Pending
  deriving (Eq, Show, Generic, FromJSON, ToJSON, ToSchema)

--

data Client = Client
  { identifier :: UUID,
    displayName :: Text,
    phoneNumber :: Text,
    emailAddress :: Text,
    passwordHash :: Text,
    passwordResetToken :: Maybe Text,
    createdAt :: ZonedTime,
    updatedAt :: Maybe ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Client

data Activity = Activity
  { identifier :: UUID,
    displayName :: Text,
    description :: Text,
    timeslotGenMode :: TimeslotGenMode,
    unitCost :: Text,
    createdBy :: UUID,
    createdAt :: ZonedTime,
    updatedAt :: Maybe ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Activity

data Request = Request
  { identifier :: UUID,
    createdBy :: UUID,
    activityIdentifier :: UUID,
    timeRange :: TimeRange,
    requestAmount :: Int,
    createdAt :: ZonedTime,
    updatedAt :: Maybe ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Request

data Payment = Payment
  { identifier :: UUID,
    requestIdentifier :: UUID,
    paymentAmount :: Text,
    currency :: Text,
    paymentStatus :: PaymentStatus,
    createdAt :: ZonedTime,
    updatedAt :: Maybe ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Payment

data Reservation = Reservation
  { identifier :: UUID,
    clientIdentifier :: UUID,
    paymentIdentifier :: UUID,
    activityIdentifier :: UUID,
    timeRange :: TimeRange,
    createdAt :: ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Reservation

data Manager = Manager
  { identifier :: UUID,
    displayName :: Text,
    phoneNumber :: Text,
    emailAddress :: Text,
    passwordHash :: Text,
    passwordResetToken :: Maybe Text,
    createdAt :: ZonedTime,
    updatedAt :: Maybe ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Manager

data OfflineRange = OfflineRange
  { identifier :: UUID,
    activityIdentifier :: UUID,
    timeRange :: TimeRange,
    createdBy :: UUID,
    createdAt :: ZonedTime,
    updatedAt :: Maybe ZonedTime
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''OfflineRange

--

data ActivityResponse = ActivityResponse
  { activity :: Activity,
    availabilities :: [TimeRange]
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''ActivityResponse
