module Cido.Api (api) where

import Rest.Api

import qualified Cido.Types.Server   as S
import qualified Cido.Resources.User as User

api :: Api S.Api
api = [(mkVersion 1 0 0, Some1 router)]

router :: Router S.Api S.Api
router = root -/ user where user = route User.resource
