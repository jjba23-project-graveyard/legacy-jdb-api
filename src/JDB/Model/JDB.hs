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
    Env (..),
    GetActivitiesResponse (..),
    show,
    Prelude.read,
  )
where

import Data.Aeson hiding (Success)
import Data.OpenApi
import Data.Time
import Data.UUID
import Hasql.Pool qualified
import JDB.Model.Config
import Optics
import Relude
import Prelude qualified

data Env = Env
  { pool :: Hasql.Pool.Pool,
    cfg :: AppConfig,
    processStartedAt :: ZonedTime
  }

makeFieldLabelsNoPrefix ''Env

--

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
  deriving (Eq, Generic, FromJSON, ToJSON, ToSchema)

instance Show TimeslotGenMode where
  show Monthly = "Monthly"
  show Daily = "Daily"
  show WorkDays = "WorkDays"
  show Weekends = "Weekends"
  show Hourly = "Hourly"
  show FiveMinutes = "FiveMinutes"
  show Minute = "Minute"
  show TenMinutes = "TenMinutes"
  show FifteenMinutes = "FifteenMinutes"

instance Read TimeslotGenMode where
  readsPrec _ "Monthly" = [(Monthly, "")]
  readsPrec _ "Daily" = [(Daily, "")]
  readsPrec _ "WorkDays" = [(WorkDays, "")]
  readsPrec _ "Weekends" = [(Weekends, "")]
  readsPrec _ "Hourly" = [(Hourly, "")]
  readsPrec _ "FiveMinutes" = [(FiveMinutes, "")]
  readsPrec _ "Minute" = [(Minute, "")]
  readsPrec _ "TenMinutes" = [(TenMinutes, "")]
  readsPrec _ "FifteenMinutes" = [(FifteenMinutes, "")]
  readsPrec _ _ = []

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

data GetActivitiesResponse = GetActivitiesResponse
  { activities :: Map UUID ActivityResponse,
    sortOrder :: [UUID]
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''GetActivitiesResponse
