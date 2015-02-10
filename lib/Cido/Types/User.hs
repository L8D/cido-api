{-# LANGUAGE
    TemplateHaskell
  , GeneralizedNewtypeDeriving
  , DeriveGeneric
  #-}

module Cido.Types.User where

import Happstack.Server.Internal.Types (FromReqURI(..))

import GHC.Generics
import Data.String  (IsString)
import Data.Aeson
import Text.Read    (readMaybe)
import Data.Time    (UTCTime)
import Data.Text    (Text)
import Data.UUID    (UUID)
import Hasql.Postgres
import Hasql.Backend
import Util         ()

newtype UserId   = UserId   { unUserId   :: UUID }
    deriving (Show, Eq, Ord, Generic, Read, CxValue Postgres)
newtype Username = Username { unUsername :: Text }
    deriving (Show, Eq, Ord, Generic, IsString, CxValue Postgres)
newtype Password = Password { unPassword :: Text }
    deriving (Show, Eq, Ord, Generic, IsString, CxValue Postgres)

instance ToJSON   UserId
instance FromJSON UserId
instance ToJSON   Username
instance FromJSON Username
instance ToJSON   Password
instance FromJSON Password

instance FromReqURI UserId where
    fromReqURI = readMaybe

data User = User
    { id         :: UserId
    , username   :: Username
    , password   :: Password
    , created_at :: UTCTime
    , updated_at :: UTCTime
    } deriving (Show, Eq, Ord, Generic)

instance FromJSON User
instance ToJSON   User
