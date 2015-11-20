import qualified Data.ByteString.Lazy as L
import Text.Printf
import System.IO
import Data.Word
import Data.Char
import Data.Bits

insts :: [(String, Word8)]
insts = [("+", 0)
        ,("-", 1)
        ,("*", 2)
        ,("/%", 3)
        ,("r>", 7)
        ,(">r", 8)
        ,("and", 9)
        ,("or", 10)
        ,("xor", 11)
        ,("<", 12)
        ,("u<", 13)
        ,(".c", 15)
        ,("halt", 16)]

trunc :: Word16 -> Word8
trunc = toEnum . fromEnum

iconst :: Word16 -> [Word8]
iconst v = [14, trunc v, trunc (shiftR v 8)]

compile :: [String] -> [Word8]
compile [] = []
compile (word : ws) =
  case lookup word insts of
    Just b -> b : compile ws
    Nothing -> if all isDigit word
                  then iconst (read word) ++ compile ws
                  else error (printf "No such word %s\n" word)

main = do c <- getContents
          L.putStr (L.pack (compile (words c)))
