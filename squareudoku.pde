class Block {
  PVector[] pieces;

  public Block() {
    int numPieces = ceil(random(0, 5));
    pieces = new PVector[numPieces];
    pieces[0] = new PVector(0, 0);
    PVector lastPiece = pieces[0];
    for(int i = 1; i < numPieces; i ++) {
      boolean validPos = false;
      PVector newPos = lastPiece.copy();
      while(!validPos) {
        newPos.add(getOffsetFromDir(floor(random(0, 8))));
        validPos = true;
        for(int j = 0; j < i; j ++) {
          if(pieces[j].equals(newPos)) {
            validPos = false;
          }
        }
      }
      pieces[i] = newPos;
      lastPiece = newPos;
    }
  }

  public Block copy() {
    Block temp = new Block();
    temp.pieces = pieces;
    return temp;
  }

  public PVector getCenter() {
    PVector center = new PVector(0, 0);
    for(PVector p : pieces) {
      center.add(p);
    }
    center.mult(1f / pieces.length);
    return center;
  }
}

PVector getOffsetFromDir(int dir) {
  switch(dir) {
    case 0:
      return new PVector(0, -1);
    case 1:
      return new PVector(1, -1);
    case 2:
      return new PVector(1, 0);
    case 3:
      return new PVector(1, 1);
    case 4:
      return new PVector(0, 1);
    case 5:
      return new PVector(-1, 1);
    case 6:
      return new PVector(-1, 0);
    case 7:
      return new PVector(-1, -1);
    default:
      return new PVector(0, 0);
  }
}

class Board {
  int[][] cells;
  int sectionSize = 3;
  int totalSize = int(pow(sectionSize, 2));

  public Board() {
    cells = new int[totalSize][totalSize];
  }

  public boolean canPlacePiece(Block b, PVector home) {
    for(PVector p : b.pieces) {
      PVector pieceLocationOnBoard = PVector.add(p, home);
      try {
        if(cells[(int)pieceLocationOnBoard.x][(int)pieceLocationOnBoard.y] == 1) {
          return false;
        }
      } catch(ArrayIndexOutOfBoundsException e) {
        return false;
      }
    }
    return true;
  }

  public void placePiece(Block b, PVector home) {
    placePiece(b, home, 1);
  }

  public void placePiece(Block b, PVector home, int state) {
    placePiece(b, home, state, -1);
  }

  public void placePiece(Block b, PVector home, int state, int stateToReplace) {
    for(PVector p : b.pieces) {
      PVector PB = PVector.add(p, home);
      if(cells[(int)PB.x][(int)PB.y] == stateToReplace || stateToReplace == -1) {
        cells[(int)PB.x][(int)PB.y] = state;
      }
    }
  }

  public void checkAll() {
    ArrayList<PVector> fullCells = findAllFull(false);

    for(PVector p : fullCells) {
      cells[int(p.x)][int(p.y)] = 0;
    }
  }

  public ArrayList<PVector> findAllFull() {
    return findAllFull(false);
  }

  public ArrayList<PVector> findAllFull(boolean includePhantom) {
    ArrayList<Integer> fullRows = findFullRows(includePhantom);
    ArrayList<Integer> fullCols = findFullCols(includePhantom);
    ArrayList<PVector> fullSecs = findFullSections(includePhantom);

    ArrayList<PVector> fullCells = new ArrayList<PVector>();

    for(int i : fullRows) {
      for(int j = 0; j < totalSize; j ++) {
        fullCells.add(new PVector(i, j));
      }
    }

    for(int i : fullCols) {
      for(int j = 0; j < totalSize; j ++) {
        PVector fullCell = new PVector(j, i);
        if(notIn(fullCells, fullCell))
          fullCells.add(fullCell);
      }
    }

    for(PVector p : fullSecs) {
    int startX = int(p.x) * sectionSize;
    int endX = startX + sectionSize;
    int startY = int(p.y) * sectionSize;
    int endY = startY + sectionSize;
      for(int i = startX; i < endX; i ++) {
        for(int j = startY; j < endY; j ++) {
          PVector fullCell = new PVector(i, j);
          if(notIn(fullCells, fullCell))
            fullCells.add(fullCell);
        }
      }
    }

    return fullCells;
  }

  public void checkRows() {
    for(int i = 0; i < totalSize; i ++) {
      checkRow(i);
    }
  }

  public ArrayList<Integer> findFullRows() {
    return findFullRows(false);
  }

  public ArrayList<Integer> findFullRows(boolean includePhantom) {
    ArrayList<Integer> fullRows = new ArrayList<Integer>();
    for(int i = 0; i < totalSize; i ++) {
      if(rowIsFull(i, includePhantom)) {
        fullRows.add(i);
      }
    }
    return fullRows;
  }

  public void checkRow(int row) {
    if(rowIsFull(row)) {
      clearRow(row);
    }
  }

  public boolean rowIsFull(int row) {
    return rowIsFull(row, false);
  }

  public boolean rowIsFull(int row, boolean includePhantom) {
    for(int i = 0; i < totalSize; i ++) {
      if(!cellIsFull(row, i, includePhantom)) {
        return false;
      }
    }
    return true;
  }

  public void clearRow(int row) {
    for(int i = 0; i < totalSize; i ++) {
      cells[row][i] = 0;
    }
  }

  public void checkCols() {
    for(int i = 0; i < totalSize; i ++) {
      checkCol(i);
    }
  }

  public ArrayList<Integer> findFullCols() {
    return findFullCols(false);
  }

  public ArrayList<Integer> findFullCols(boolean includePhantom) {
    ArrayList<Integer> fullCols = new ArrayList<Integer>();
    for(int i = 0; i < totalSize; i ++) {
      if(colIsFull(i, includePhantom)) {
        fullCols.add(i);
      }
    }
    return fullCols;
  }

  public void checkCol(int col) {
    if(colIsFull(col)) {
      clearCol(col);
    }
  }

  public boolean colIsFull(int col) {
    return colIsFull(col, false);
  }

  public boolean colIsFull(int col, boolean includePhantom) {
    for(int i = 0; i < totalSize; i ++) {
      if(!cellIsFull(i, col, includePhantom)) {
        return false;
      }
    }
    return true;
  }

  public void clearCol(int col) {
    for(int i = 0; i < totalSize; i ++) {
      cells[i][col] = 0;
    }
  }

  public void checkSections() {
    for(int i = 0; i < sectionSize; i ++) {
      for(int j = 0; j < sectionSize; j ++) {
        checkSection(i, j);
      }
    }
  }

  public ArrayList<PVector> findFullSections() {
    return findFullSections(false);
  }

  public ArrayList<PVector> findFullSections(boolean includePhantom) {
    ArrayList<PVector> fullSecs = new ArrayList<PVector>();
    for(int i = 0; i < sectionSize; i ++) {
      for(int j = 0; j < sectionSize; j ++) {
        if(sectionIsFull(i, j, includePhantom)) {
          fullSecs.add(new PVector(i, j));
        }
      }
    }

    return fullSecs;
  }

  public void checkSection(int x, int y) {
    if(sectionIsFull(x, y)) {
      clearSection(x, y);
    }
  }

  public boolean sectionIsFull(int x, int y) {
    return sectionIsFull(x, y, false);
  }

  public boolean sectionIsFull(int x, int y, boolean includePhantom) {
    int startX = sectionSize * x;
    int endX = startX + sectionSize;
    int startY = sectionSize * y;
    int endY = startY + sectionSize;

    for(int i = startX; i < endX; i ++) {
      for(int j = startY; j < endY; j ++) {
        if(!cellIsFull(i, j, includePhantom)) {
          return false;
        }
      }
    }

    return true;
  }

  public void clearSection(int x, int y) {
    int startX = sectionSize * x;
    int endX = startX + sectionSize;
    int startY = sectionSize * y;
    int endY = startY + sectionSize;

    for(int i = startX; i < endX; i ++) {
      for(int j = startY; j < endY; j ++) {
        cells[i][j] = 0;
      }
    }
  }

  public boolean cellIsFull(int i, int j) {
    return cellIsFull(i, j, false);
  }

  public boolean cellIsFull(int i, int j, boolean includePhantom) {
    int c = cells[i][j];
    return includePhantom ? (c == 1 || c == 2) : c == 1;
  }
}

boolean notIn(ArrayList<PVector> arr, PVector itm) {
  for(PVector p : arr) {
    if(p == itm) {
      return false;
    }
  }
  return true;
}

color hexColor(String r, String g, String b) {
  return color(unhex(r), unhex(g), unhex(b));
}

color hexColor(String rgb) {
  String r = rgb.substring(0, 2);
  String g = rgb.substring(2, 4);
  String b = rgb.substring(4, 6);
  return hexColor(r, g, b);
}

color colorAvg(color a, color b) {
  float rNew = red(a) + red(b);
  float gNew = green(a) + green(b);
  float bNew = blue(a) + blue(b);
  rNew /= 2;
  gNew /= 2;
  bNew /= 2;
  return color(rNew, gNew, bNew);
}

final color boardA = hexColor("7E481C");
final color boardB = hexColor("9A7B4F");

final color filledA = hexColor("102060");
final color filledB = hexColor("102080");

final color phantomA = hexColor("601010");
final color phantomB = hexColor("801010");

Board board;

Block[] options;

Block selPiece;

float cellSize;

PVector lastMousePos = new PVector(0, 0);

void drawBlock(Block b, PVector home, float cellSize, boolean drawAtCenter, boolean centerOfBlock) {
  PVector homeOffset = new PVector(cellSize / 2, cellSize / 2);
  PVector center = b.getCenter();
  center.mult(cellSize);
  for(PVector p : b.pieces) {
    PVector pieceLoc = p.copy();
    pieceLoc.mult(cellSize);
    pieceLoc.add(home);

    if(centerOfBlock) pieceLoc.sub(homeOffset);
    if(drawAtCenter) pieceLoc.sub(center);

    rect(pieceLoc.x, pieceLoc.y, cellSize, cellSize);
  }
}

void drawBlock(Block b, PVector home, float cellSize, boolean drawAtCenter) {
  drawBlock(b, home, cellSize, drawAtCenter, true);
}

void drawBlock(Block b, PVector home, float cellSize) {
  drawBlock(b, home, cellSize, true);
}

void drawBlock(Block b, PVector home) {
  drawBlock(b, home, 25);
}

void drawBlock(Block b) {
  drawBlock(b, new PVector(0, 0));
}

void checkOptions() {
  if(optionsAreEmpty()) {
    newOptions();
  }
}

boolean optionsAreEmpty() {
  for(Block b : options) {
    if(b != null) return false;
  }
  return true;
}

void newOptions() {
  for(int i = 0; i < options.length; i++) {
    options[i] = new Block();
  }
}

void piecePlaced() {
  checkOptions();
  board.checkAll();
}

void setup() {
  size(600, 800);

  options = new Block[3];

  board = new Board();

  checkOptions();

  cellSize = width / board.totalSize;
}

void draw() {
  background(0);

  float optionY = width + (height - width) / 2;

  noStroke();
  fill(255);

  for(int i = 0; i < options.length; i ++) {
    if(options[i] != null) {
      float x = (i + 0.5) * width / 3;
      drawBlock(options[i], new PVector(x, optionY));
    }
  }

  for(int i = 0; i < board.cells.length; i ++) {
    for(int j = 0; j < board.cells[i].length; j ++) {
      float x = i * cellSize;
      float y = j * cellSize;

      stroke(255);

      int sectorX = floor(i / 3);
      int sectorY = floor(j / 3);

      boolean checker = ((sectorX + sectorY) % 2) == 0;

      color fillCol = board.cells[i][j] == 1 ?
      (checker ? filledA : filledB) //Filled
      :
      (board.cells[i][j] == 2 ?
        (checker ? phantomA : phantomB) //Phantom
        :
        (checker ? boardA : boardB) //Empty
      );

      fill(fillCol);

      rect(x, y, cellSize, cellSize);
    }
  }

  noFill();
  stroke(10);

  float sectionCellSize = cellSize * board.sectionSize;

  for(int i = 0; i < board.sectionSize; i ++) {
    for(int j = 0; j < board.sectionSize; j ++) {
      rect(i * sectionCellSize, j * sectionCellSize, sectionCellSize, sectionCellSize);
    }
  }

  if(selPiece != null) {
    PVector oldBV = boardVecFromMousePos(lastMousePos.x, lastMousePos.y);
    if(board.canPlacePiece(selPiece, oldBV)) {
      board.placePiece(selPiece, oldBV, 0, 2);
    }

    int boardX = floor(mouseX / cellSize);
    int boardY = floor(mouseY / cellSize);

    if(board.canPlacePiece(selPiece, new PVector(boardX, boardY))) {
      board.placePiece(selPiece, new PVector(boardX, boardY), 2);

      ArrayList<PVector> possibleFills = board.findAllFull(true);

      noStroke();
      fill(0, 255, 0, 100);

      for(PVector p : possibleFills) {
        rect(p.x * cellSize, p.y * cellSize, cellSize, cellSize);
      }
    } else {
      stroke(255);
      fill(255);
      drawBlock(selPiece, new PVector(mouseX, mouseY), cellSize, false);
    }
  }

  lastMousePos = new PVector(mouseX, mouseY);
}

PVector boardVecFromMousePos(float mx, float my) {
  return new PVector(floor(mx / cellSize), floor(my / cellSize));
}

void mouseClicked() {
  if(mouseY > width) {
    int index = floor(mouseX / (width / 3));
    if(selPiece == null) {
      if(options[index] != null) {
        selPiece = options[index].copy();
        options[index] = null;
      }
    } else {
      if(options[index] == null) {
        options[index] = selPiece.copy();
        selPiece = null;
      } else {
        Block temp = selPiece.copy();
        selPiece = options[index].copy();
        options[index] = temp;
      }
    }
  } else if(selPiece != null) {
    int boardX = floor(mouseX / cellSize);
    int boardY = floor(mouseY / cellSize);

    if(board.canPlacePiece(selPiece, new PVector(boardX, boardY))) {
      board.placePiece(selPiece, new PVector(boardX, boardY));
      selPiece = null;
      piecePlaced();
    }
  }
}
