{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE OverloadedStrings #-}

module Util () where

import Happstack.Server
import Data.Aeson
import Data.Aeson.Encode       (encodeToByteStringBuilder)
import Data.ByteString.Builder (toLazyByteString)
import Data.UUID
import Data.Text

instance ToMessage Value where
    toContentType _ = "application/json; charset=utf-8"
    toMessage = toLazyByteString . encodeToByteStringBuilder
    toResponse x = toResponseBS (toContentType x) (toMessage x)

instance ToJSON UUID where
    toJSON = String . pack . toString

instance FromJSON UUID where
    parseJSON = withText "UUID" $ maybe (fail "could not parse UUID") return
                                . fromString
                                . unpack
