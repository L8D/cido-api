{-# LANGUAGE
    DeriveDataTypeable
  , DeriveGeneric
  , TemplateHaskell
  , TypeFamilies
  #-}

module Cido.Types.User ( User(..)
                       , Id
                       , Username
                       , AuthenticatedUser(..)
                       ) where

import Data.Aeson
import Data.JSON.Schema
import Data.Text        (Text)
import Data.Typeable
import GHC.Generics
import Generics.Regular

type Id       = Int
type Username = Text

data User = User
    { id       :: Id
    , username :: Username
    } deriving (Eq, Generic, Ord, Show, Typeable)

newtype AuthenticatedUser = AuthenticatedUser User

deriveAll ''User "PFUser"
type instance PF User = PFUser

instance JSONSchema User where schema  = gSchema
instance FromJSON   User
instance ToJSON     User
