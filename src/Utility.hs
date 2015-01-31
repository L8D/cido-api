{-# OPTIONS_GHC -fno-warn-orphans #-}

-- this is for the random typeclass
-- instance declarations for 3rd
-- party libraries. All these poor
-- orphans :(

module Utility () where

import Data.Aeson
import Data.UUID
import Data.Text
import Data.JSON.Schema
import Rest.Types.Info

instance ToJSON UUID where
    toJSON = String . pack . toString

instance FromJSON UUID where
    parseJSON = withText "UUID" $ maybe (fail "could not parse UUID") return
                                . fromString
                                . unpack

instance JSONSchema UUID where
    schema _ = Value LengthBound { lowerLength = Just 18
                                 , upperLength = Just 18
                                 }

instance Info UUID where
    describe _ = "uuid"
