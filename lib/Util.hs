{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE OverloadedStrings #-}

module Util () where

import Happstack.Server
import Data.Aeson
import Data.Aeson.Encode       (encodeToByteStringBuilder)
import Data.ByteString.Builder (toLazyByteString)
import Data.UUID.Aeson         ()

instance ToMessage Value where
    toContentType _ = "application/json; charset=utf-8"
    toMessage = toLazyByteString . encodeToByteStringBuilder
    toResponse x = toResponseBS (toContentType x) (toMessage x)
