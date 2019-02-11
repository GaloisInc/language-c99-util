module Language.C99.Util.Expr
  ( digit
  , nonzerodigit
  , nondigit
  , ident
  , litbool
  , litint
  ) where

import Data.Char (isDigit)

import Language.C99.AST

-- A digit in Haskell, not C
type HSDigit = Int

digit :: Int -> Digit
digit i = case i of
  0 -> DZero
  1 -> DOne
  2 -> DTwo
  3 -> DThree
  4 -> DFour
  5 -> DFive
  6 -> DSix
  7 -> DSeven
  8 -> DEight
  9 -> DNine
  _ -> error $ show i ++ " is not a digit"

nonzerodigit :: Int -> NonZeroDigit
nonzerodigit i = case i of
  1 -> NZOne
  2 -> NZTwo
  3 -> NZThree
  4 -> NZFour
  5 -> NZFive
  6 -> NZSix
  7 -> NZSeven
  8 -> NZEight
  9 -> NZNine
  _ -> error $ show i ++ " is not a non-zero digit"

nondigit :: Char -> IdentNonDigit
nondigit c = IdentNonDigit $ case c of
  '_' -> NDUnderscore
  'a' -> NDa ;      'A' -> NDA
  'b' -> NDb ;      'B' -> NDB
  'c' -> NDc ;      'C' -> NDC
  'd' -> NDd ;      'D' -> NDD
  'e' -> NDe ;      'E' -> NDE
  'f' -> NDf ;      'F' -> NDF
  'g' -> NDg ;      'G' -> NDG
  'h' -> NDh ;      'H' -> NDH
  'i' -> NDi ;      'I' -> NDI
  'j' -> NDj ;      'J' -> NDJ
  'k' -> NDk ;      'K' -> NDK
  'l' -> NDl ;      'L' -> NDL
  'm' -> NDm ;      'M' -> NDM
  'n' -> NDn ;      'N' -> NDN
  'o' -> NDo ;      'O' -> NDO
  'p' -> NDp ;      'P' -> NDP
  'q' -> NDq ;      'Q' -> NDQ
  'r' -> NDr ;      'R' -> NDR
  's' -> NDs ;      'S' -> NDS
  't' -> NDt ;      'T' -> NDT
  'u' -> NDu ;      'U' -> NDU
  'v' -> NDv ;      'V' -> NDV
  'w' -> NDw ;      'W' -> NDW
  'x' -> NDx ;      'X' -> NDX
  'y' -> NDy ;      'Y' -> NDY
  'z' -> NDz ;      'Z' -> NDZ
  _   -> error $ show c ++ " is not a nondigit"

ident :: String -> Ident
ident (c:cs) = foldl char (IdentBase $ nondigit c) cs where
  char cs c | isDigit c = IdentCons         cs (digit (read [c]))
            | otherwise = IdentConsNonDigit cs (nondigit c)

litbool :: Bool -> PrimExpr
litbool False = PrimConst $ ConstEnum $ Enum (ident "false")
litbool True  = PrimConst $ ConstEnum $ Enum (ident "true")

litint :: Integer -> UnaryExpr
litint i | i == 0 = UnaryPostfix $ PostfixPrim $ constzero
         | i >  0 = UnaryPostfix $ PostfixPrim $ constint i
         | i <  0 = UnaryOp UOMin (CastUnary $ litint (abs i))


intdigits :: Integer -> [HSDigit]
intdigits = map (read.return).show

constint :: Integer -> PrimExpr
constint i = PrimConst $ ConstInt $ IntDec (decconst $ intdigits i) Nothing

constzero :: PrimExpr
constzero = PrimConst $ ConstInt $ IntOc Oc0 Nothing

decconst :: [HSDigit] -> DecConst
decconst (d:ds) = foldl step base ds where
  base      = DecBase $ nonzerodigit d
  step xs x = DecCons xs (digit x)
