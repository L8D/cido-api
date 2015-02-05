{-# LANGUAGE
    DeriveDataTypeable
  , DeriveGeneric
  , TemplateHaskell
  , TypeFamilies
  #-}

module Cido.Types.User where

import Data.Aeson
import Data.JSON.Schema
import Data.Text        (Text)
import Data.Typeable
import GHC.Generics
import Generics.Regular

type UserId = Int
type Username = Text

data User = User
  { user_id   :: UserId
  , user_name :: Username
  } deriving (Eq, Generic, Ord, Show, Typeable)

deriveAll ''User "PFUser"
type instance PF User = PFUser

instance JSONSchema User where schema  = gSchema
instance FromJSON   User
instance ToJSON     User
