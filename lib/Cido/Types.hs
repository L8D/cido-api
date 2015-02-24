{-# LANGUAGE GeneralizedNewtypeDeriving, OverloadedStrings #-}

module Cido.Types ( Api(..)
                  , ApiError(..)
                  , HTTPFailure(..)
                  , errorHandler
                  ) where

import Control.Monad.Trans (MonadIO)
import Control.Monad.Error (ErrorT, MonadError)
import Control.Applicative (Applicative, Alternative)
import Happstack.Server
import Control.Monad       (MonadPlus)
import Data.Aeson
import Data.Text           (pack)
import Util                ()
import Hasql
import Hasql.Postgres
import Control.Monad.Trans.Error (Error(..))

newtype Api a = Api
    { unApi :: ServerPartT (ErrorT ApiError (Session Postgres IO)) a }
    deriving ( Monad
             , Functor
             , MonadIO
             , MonadPlus
             , Applicative
             , Alternative
             , ServerMonad
             , MonadError ApiError
             , HasRqData
             )

errorHandler :: Monad m => ApiError -> m Response
errorHandler x@(ApiError f _) = setRsCode c $ toResponse $ toJSON x
    where c = toResponseCode f

data ApiError = ApiError HTTPFailure (Maybe String)

data HTTPFailure
    = BadRequest
    | NotFound
    | UnprocessableEntity
    | InternalServerError

instance Error ApiError where
    noMsg  = ApiError InternalServerError Nothing
    strMsg = ApiError InternalServerError . Just

instance ToJSON ApiError where
    toJSON err@(ApiError f _) = object
        [ "error" .= object
            [ "code" .= toResponseCode f
            , "message" .= pack (toErrorMessage err)
            ]
        ]

toResponseCode :: HTTPFailure -> Int
toResponseCode BadRequest          = 400
toResponseCode NotFound            = 404
toResponseCode UnprocessableEntity = 422
toResponseCode InternalServerError = 500

toErrorMessage :: ApiError -> String
toErrorMessage (ApiError e Nothing) = case e of
    BadRequest          -> "Bad Request"
    NotFound            -> "Not Found"
    InternalServerError -> "Internal Server Error"
    UnprocessableEntity -> "Unprocessable Entity"
toErrorMessage (ApiError _ (Just s)) = s
