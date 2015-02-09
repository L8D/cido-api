module Cido.Api (api) where

import Happstack.Server
import Control.Monad       (mzero)
import Cido.Types          (Api)

api :: Api Response
api = mzero
