module Test.Main where

import Prelude (class Eq, class Show, Unit, bind, ($))

import Browser.WebStorage (WebStorage)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import Data.Argonaut.Decode (class DecodeJson, gDecodeJson)
import Data.Argonaut.Encode (class EncodeJson, gEncodeJson)
import Data.Generic (class Generic, gEq, gShow)
import Data.Maybe (Maybe(..))
import Test.Spec (describe, it)
import Test.Spec.Runner (Process, run)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)

import Browser.SafeStorage

data UserStorageKey = UserStorageKey

instance storageKeyUser :: StorageKey UserStorageKey
  where storageKey _ = "user"

newtype User = User { name :: String
                    , password :: String }

derive instance genericUser :: Generic User
instance showUser :: Show User where show = gShow
instance eqUser :: Eq User where eq = gEq
instance encodeJsonUser :: EncodeJson User where encodeJson = gEncodeJson
instance decodeJsonUser :: DecodeJson User where decodeJson = gDecodeJson

instance canStoreUser :: CanStore UserStorageKey User where
    -- setItem :: forall eff . UserStorageKey -> User -> Eff (webStorage :: WebStorage | eff) Unit
    setItem = setItemJson
    -- getItem :: forall eff . UserStorageKey -> Eff (webStorage :: WebStorage | eff) (Maybe User)
    getItem = getItemJson

-- TODO: This currently doesn't compile because it uses WebStorage.
-- Maybe look into testing with selenium...?
main :: forall e. Eff (process :: Process, console :: CONSOLE, webStorage :: WebStorage | e) Unit
main = run [consoleReporter] $
    describe "Web.SafeStorage" $
        it "can save and get item" $ do
            let user = User { name: "username", password: "foofoo" }
            liftEff $ setItem UserStorageKey user
            maybeUserFromStorage <- liftEff $ getItem UserStorageKey
            case maybeUserFromStorage of
                 Nothing -> fail "the user doesn't exist in storage even though we just saved it"
                 Just userFromStorage -> user `shouldEqual` userFromStorage
