{-# LANGUAGE
    TemplateHaskell
  , GeneralizedNewtypeDeriving
  , DeriveGeneric
  #-}

module Cido.Types.NewUser where

import GHC.Generics
import Data.Aeson

import qualified Cido.Types.User as U

data NewUser = NewUser
    { username :: U.Username
    , password :: U.Password
    } deriving (Show, Eq, Ord, Generic)

instance FromJSON NewUser
instance ToJSON   NewUser
