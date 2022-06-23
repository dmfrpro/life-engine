module Types where

import qualified CodeWorld
import Common (cellSize)
import Data.Function (on)
import Data.Map (Map)
import qualified Data.Map as Map
import System.Random (StdGen)
import Utilities (bimap)

-- | (X, Y) coordinates
type Coords = (Int, Int)

data Direction
  = North
  | East
  | South
  | West
  deriving (Eq)

-- | State which cell could take
data CellState
  = Mouth
  | Producer
  | Mover
  | Killer
  | Armor
  | Eye
  | Food
  | Empty
  | Wall
  deriving (Eq)

-- | Cell
data Cell = Cell
  { state :: CellState,
    coords :: Coords
  }

-- | Organism
-- TODO: write comments to describe each field
data Organism = Organism
  { anatomy :: [Cell],
    health :: Int,
    direction :: Direction,
    foodCollected :: Int,
    lifetime :: Int,
    mutationFactor :: Double,
    lifespanFactor :: Int,
    lookRange :: Int,
    randomGen :: StdGen
  }

-- | World
data World = World
  { -- | Stores only non organism cells (Walls, food & empty cells)
    grid :: Map Coords Cell,
    -- | Organisms
    organisms :: Map [Coords] Organism
  }

data Engine = Engine
  { world :: World,
    fps :: Int
  }

class Drawable a where
  draw :: a -> CodeWorld.Picture

instance Drawable Cell where
  draw cell = positioned figure
    where
      positioned =
        let (x', y') = bimap ((*) cellSize . fromIntegral) (coords cell)
         in CodeWorld.translated x' y'
      figure =
        let square = CodeWorld.solidRectangle cellSize cellSize
            colored = CodeWorld.colored
            rgb = CodeWorld.RGB
         in case state cell of
              -- pink mouth
              Mouth -> colored CodeWorld.pink square
              -- green producer
              Producer -> colored CodeWorld.green square
              -- blue mover
              Mover -> colored (rgb 0.2 0.2 0.8) square
              -- red killer
              Killer -> colored (rgb 0.8 0.2 0.2) square
              -- yellow armor
              Armor -> colored (rgb 0.8 0.8 0.2) square
              -- gray eye
              Eye -> colored (rgb 0.5 0.5 0.5) square
              -- dark blue food
              Food -> colored (rgb 0.2 0.2 0.8) square
              -- black empty
              Empty -> colored CodeWorld.black square
              -- black wall
              Wall -> colored (rgb 0 0 0) square

instance Drawable World where
  draw w = ((<>) `on` CodeWorld.pictures) (livingCells w) (nonLivingCells w)
    where
      livingCells = concatMap (map draw . anatomy) . Map.elems . organisms
      nonLivingCells = map draw . Map.elems . grid

instance Drawable Engine where
  draw = draw . world