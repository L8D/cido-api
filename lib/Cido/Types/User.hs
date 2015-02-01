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

type Username = Text
type Password = Text

data User = User
  { user_id   :: Int
  , user_name :: Username
  , user_pass :: Password
  } deriving (Eq, Generic, Ord, Show, Typeable)

deriveAll ''User "PFUser"
type instance PF User = PFUser

instance JSONSchema User where schema  = gSchema
instance FromJSON   User
instance ToJSON     User
