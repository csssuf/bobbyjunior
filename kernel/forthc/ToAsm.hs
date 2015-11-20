import qualified Data.ByteString.Lazy as L
import System.Environment
import Text.Printf
import System.IO
import Data.List

main = do [name] <- getArgs
          hSetBinaryMode stdin True
          c <- getContents
          printf "global %s\n" name
          printf "%s: db %s\n"
                 name 
                 (intercalate ", " 
                              (map (show . fromEnum) c))
