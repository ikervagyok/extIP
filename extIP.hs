import Control.Monad (forM_)
import Data.Word (Word8,Word16)
import Data.Maybe (fromMaybe)
import Data.List (intercalate)
import Network.HTTP 

newtype Conformant    = Conformant    String deriving Show
newtype NonConformant = NonConformant String deriving Show

data Address = IP {a,b,c,d :: Word8, port :: Maybe Word16, path :: String}
             | URL String

type Provider = (Address, NonConformant -> Conformant)

providers :: [Provider]
providers =
  [ (URL "http://ipecho.net/plain", \(NonConformant x) -> Conformant x)
--  , (URL "http://ifconfig.me/ip", \(NonConformant x) -> Conformant . init $ x)
  , (URL "http://checkip.dyndns.org", \(NonConformant x) -> Conformant x)
  ]

getIP :: Provider -> IO Conformant -- Provider -> IO Address
getIP provider = let
    (addr, f) = provider
    url' = case addr of
      URL url -> url
      IP a b c d port path -> let
          ip = intercalate "." (map show [a,b,c,d])
          port' = fromMaybe "" (((":" ++).show) <$> port)
        in ip ++ port' ++ path
  in do
    reply <- simpleHTTP $ getRequest url'
    body <- getResponseBody reply
    return . f $ NonConformant body
    
    
main :: IO ()
main = forM_ providers $ do
  (\x -> getIP x >>= print)
    
