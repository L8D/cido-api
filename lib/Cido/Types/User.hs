{-# LANGUAGE
    TemplateHaskell
  , GeneralizedNewtypeDeriving
  , DeriveGeneric
  #-}

module Cido.Types.User where

import Happstack.Server.Internal.Types (FromReqURI(..))

import Text.Email.Validate (EmailAddress)
import GHC.Generics
import Data.Aeson
import Text.Read           (readMaybe)
import Data.Time           (UTCTime)
import Data.Text           (Text)
import Data.UUID           (UUID)
import Hasql.Postgres
import Hasql.Backend
import Util                ()

newtype UserId   = UserId   { unUserId   :: UUID }
    deriving
        (Show, Eq, Ord, Generic, CxValue Postgres, ToJSON, FromJSON)

newtype EmailAddr = EmailAddr { unEmailAddr :: EmailAddress }
    deriving
        (Show, Eq, Ord, Generic, CxValue Postgres, ToJSON, FromJSON)

newtype HashedPassword = HashedPassword { unHashedPassword :: Text }
    deriving
        (Show, Eq, Ord, Generic, CxValue Postgres, FromJSON)

newtype RawPassword = RawPassword { unRawPassword :: Text }
    deriving
        (Show, Eq, Ord, Generic, CxValue Postgres, FromJSON)

instance FromReqURI UserId where
    fromReqURI = readMaybe

instance Read UserId where
    readsPrec d r = map f (readsPrec d r) where f (i, s) = (UserId i, s)

instance ToJSON RawPassword where
    toJSON _ = Null

instance ToJSON HashedPassword where
    toJSON _ = Null

data User = User
    { id         :: UserId
    , email      :: EmailAddr
    , password   :: HashedPassword
    , created_at :: UTCTime
    , updated_at :: UTCTime
    } deriving (Show, Eq, Ord, Generic)

instance FromJSON User
instance ToJSON   User
