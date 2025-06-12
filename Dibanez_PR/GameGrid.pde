// Clase que representa la rejilla (tablero) del juego.

class GameGrid {
  // Número de columnas y filas del tablero.
  int cols = 10;
  int rows = 20;
  
  // Tamaño de cada celda y márgenes para centrar la rejilla.
  float cellSize; 
  float marginX, marginY;
  
  // Arrays para almacenar el estado de cada celda
  boolean[][] filled = new boolean[cols][rows]; // Indicar si la celda está rellena
  color[][] cells = new color[cols][rows]; // Colores de las celdas

  // Constructor: calcula el tamaño de celda y los márgenes para centrar la rejilla
  GameGrid(){
    cellSize = min(width/2, height-40)/10;
    marginX = width/4 + 18; 
    marginY = 8;         
  }
  
  // Función para pintar las celdas del color correspondiente o transparente
  void display(){
    strokeWeight(1);
    stroke(100);
    
    for(int i = 0; i < cols; i++){
      for(int j = 0; j < rows; j++){
        float xPos = marginX + i * cellSize;
        float yPos = marginY + j * cellSize;
  
        // Si la celda está ocupada, se pinta el círculo con su color correspondiente
        if (filled[i][j]) {
          fill(cells[i][j]);
          circle(xPos, yPos, cellSize);
        } else {
          // Si no está ocupada, se deja el círculo transparente.
          fill(81, 23, 99, 100);
          circle(xPos, yPos, cellSize);
        }
      }
    }
  }
  
  // Función booleana para comprobar si todas las celdas de la fila son del mismo color
  boolean isSameColor(int row) {
    color reference = cells[0][row];
    for (int i = 1; i < cols; i++) {
      if (!filled[i][row] || cells[i][row] != reference) {
        return false;
      }
    }
    return true;
  }
  
    // Función para eliminar la fila y bajar las filas superiores
  void removeLine(int line) {
    for (int j = line; j > 0; j--) {
      for (int i = 0; i < cols; i++) {
        filled[i][j] = filled[i][j - 1];
        cells[i][j] = cells[i][j - 1];
      }
    }
  
    // Limpiar la fila superior
    for (int i = 0; i < cols; i++) {
      filled[i][0] = false;
      cells[i][0] = color(0); // Color por defecto
    }
  }
  
  // Revisa si alguna fila está completamente llena y la elimina si es así
  // Si es así, la borra y vuelve a revisar la misma fila para bajar todo.
  // Devuelve la puntuación obtenida por las filas eliminadas

  int checkFullLines() {
    int totalScore = 0;
    
    for (int j = 0; j < rows; j++) {
      boolean fullLine = true;
      
      // Verificamos si la fila está completa
      for (int i = 0; i < cols; i++) {
        if (!filled[i][j]) {
          fullLine = false;
          break;
        }
      }
      
      // Si la línea está llena:
      if (fullLine) {
        boolean sameColor = isSameColor(j); // Comprueba si la fila es de un color
        removeLine(j); // Elimina la fila
        j--; // Revisa de nuevo la misma fila ya que han bajado las de encima.
        
        // Asignar puntuaciones: 10 cualquier línea, 20 si es del mismo color
        totalScore += sameColor ? 20 : 10;
        linesCount++; // Contador de líneas eliminadas
        colorLinesCount += sameColor ? 1 : 0; // Contador de líneas de un solo color.
      }
    }
    
    return totalScore;
  }

  // Función para bloquear las piezas para que no baje más
  void lockShape(Shape s) {
    for (int i = 0; i < 4; i++) {
      int x = s.figura[i][0] + s.gridPosX;
      int y = s.figura[i][1] + s.gridPosY;
      
      // Confirmar que las piezas se encuentran dentro de los límites de la rejilla/tablero.
      if (x >= 0 && x < cols && y >= 0 && y < rows) {
        filled[x][y] = true;
        cells[x][y] = s.shapeColor;
      }
    }
    
    // Actualizar putuación global tras revisar líneas completas.
    score += checkFullLines();
  }
}
