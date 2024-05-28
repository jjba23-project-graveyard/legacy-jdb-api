{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.Config.JDB (Request, validateRequest) where

import Data.Aeson hiding (Success)
import Data.OpenApi
import Data.UUID
import Keuringsdienst
import Keuringsdienst.Helpers
import Optics
import RIO hiding ((^.))
import RIO.Time
import Relude
import Text.Read
import WikiMusic.Model.Thread

validateRequest :: Request -> ValidationResult
validateRequest x =
  (x ^. #identifier)
    |?| isNonEmptyText
    <> (x ^. #clientIdentifier)
      |?| isNonEmptyText
    <> (x ^. #activityIdentifier)
      |?| isNonEmptyText

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
