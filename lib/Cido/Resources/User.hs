module Cido.Resources.User (resource) where

import Control.Monad.Reader (ReaderT)
import Control.Monad.Trans  (lift)
import Data.UUID            (UUID)

import Rest
import qualified Rest.Resource   as R

import Cido.Types.Server
import qualified Cido.Queries    as Q

data UserID = ByID UUID

type WithUserID = ReaderT UserID APIQuery

resource :: Resource APIQuery WithUserID UserID () Void
resource = mkResourceReader
  { R.name   = "users"
  , R.schema = withListing () $ named [("id", singleRead ByID )]
  , R.list   = const listUsers
  }

listUsers :: ListHandler APIQuery
listUsers = mkListing (jsonO . someO) $ \(Range o l) -> lift (Q.listUsers o l)
