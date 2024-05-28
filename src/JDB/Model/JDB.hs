{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.Model.JDB (Request, validateRequest) where

import Data.Aeson hiding (Success)
import Data.OpenApi
import Data.Time
import Data.UUID
import Keuringsdienst
import Keuringsdienst.Helpers
import Optics
import Relude

data Request = Request
  { identifier :: UUID,
    clientIdentifier :: UUID,
    slotStart :: UTCTime,
    slotEnd :: UTCTime,
    activityIdentifier :: UUID,
    createdAt :: UTCTime
  }
  deriving (Eq, Show, Generic, FromJSON, ToJSON, ToSchema)

makeFieldLabelsNoPrefix ''Request

validateRequest :: Request -> ValidationResult
validateRequest x =
  show (x ^. #identifier)
    |?| isNonEmptyText
    <> show (x ^. #clientIdentifier)
      |?| isNonEmptyText
    <> show (x ^. #activityIdentifier)
      |?| isNonEmptyText
