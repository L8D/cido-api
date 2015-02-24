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
    { email    :: U.EmailAddr
    , password :: U.RawPassword
    } deriving (Show, Eq, Ord, Generic)

instance FromJSON NewUser
instance ToJSON   NewUser
