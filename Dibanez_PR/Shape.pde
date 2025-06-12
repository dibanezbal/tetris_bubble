// Clase para representar una pieza del juego.

class Shape {
  // Definición de las 7 formas (Tetrominos).
  // Cada forma es un array de 4x4 con coordenadas (x,y).
  // Formas basadas en: https://en.wikipedia.org/wiki/Tetromino   
  int[][] I = {{0,0}, {1,0}, {2,0}, {3,0}};
  int[][] O = {{0,0}, {1,0}, {0,1}, {1,1}};
  int[][] T = {{0,0}, {1,0}, {2,0}, {1,1}};
  int[][] J = {{0,0}, {1,0}, {0,1}, {2,0}};
  int[][] L = {{0,0}, {1,0}, {2,0}, {2,1}};
  int[][] S = {{0,1}, {1,0}, {1,1}, {2,0}};
  int[][] Z = {{0,0}, {1,0}, {1,1}, {2,1}}; 
  
  // Array de la forma actual de la pieza.
  int[][] figura, originalShape;

  // Índice de la forma elegida aleatoriamente.
  int choice;
  
  // Color de la pieza
  color shapeColor;
  
  // Indica si la pieza está activa - Moviéndose en el panel/rejilla
  boolean isActive = true; 
  
  // Tamaño de la burbuja/celda con la que se crea la figura.
  float bubbleSize = min(width/2, height-40)/10;
  
  // Contadores para el desplazamiento hacia abajo y la rotación
  int counter, rotationCounter;
  
  // Posición la pieza en la rejilla
  int gridPosX = 4;  // Columna inicial
  int gridPosY = 0;  // Fila inicial

  // Constructor: elige aleatoriamente una de las 7 formas, le asigna aleatoriamente un color de la paleta
  // y verifica colisiones iniciales. 
  
  Shape(){
    choice = (int)random(7); // Elige aleatoriamente una forma.
    shapeColor = paleta[(int)random(paleta.length)]; // Color aleatorio de la paleta.
    
    switch(choice){
      case 0: figura = O; break;
      case 1: figura = I; break;
      case 2: figura = T; break;
      case 3: figura = J; break;
      case 4: figura = L; break;
      case 5: figura = S; break;
      case 6: figura = Z; break;
    }
    
    originalShape = figura;   // Guardamos una copia de la forma original.
    rotationCounter = 0;      // Inicializa las rotaciones.
        
    // Comprobar si la nueva pieza colisiona con otra al aparecer
    for (int i = 0; i < 4; i++) {
      int x = figura[i][0] + gridPosX;
      int y = figura[i][1] + gridPosY;
      if (gameBoard.filled[x][y]) {
        isGameOver = true;
        isActive = false;
        return;
      }
    }    
  }
  
  // Método para pintar la pieza en la pantalla
  void display(){
    fill(shapeColor);
    for(int i = 0; i < 4; i++){
      float x = (figura[i][0] + gridPosX) * bubbleSize + gameBoard.marginX;
      float y = (figura[i][1] + gridPosY) * bubbleSize + gameBoard.marginY;
      circle(x, y, bubbleSize);
    }
  }
  
  // Método para mover las piezas (izquierda, derecha, abajo) si no choca con los bordes ni con otra pieza.
  void move(String direction){
    if(checkEdges(direction)){
      if(direction == "RIGHT") gridPosX++;
      if(direction == "LEFT")  gridPosX--;
      if(direction == "DOWN")  gridPosY++; // Aumenta velocidad en la caída
    }
  }
  
  // Función para que la pieza baje automáticamente.
  void moveDown() {
    if (!isActive) return; // No hacer nada si la pieza ya está bloqueada en el tablero.
    
    // Calcular la velocidad de la caída
    if (counter % 50 == 0) { 
      if (!reachedBottom()) {
        gridPosY++;
      } else {
        // Si ha llegado al final:
        gameBoard.lockShape(this); // Bloquea la pieza.
        isActive = false; // Desactiva la pieza para que no se mueva más.       
        activeShape = nextShape;   // Usamos la pieza que estaba en espera.
        nextShape = new Shape();   // Generamos una nueva para mostrar.        
      }
    }
    counter++; // Aumenta el contador de fotogramas para que se mueva.
  }
  
  // Método para cambiar de color => Se utiliza para la siguiente pieza.  
  void cambiarColor() {
    shapeColor = paleta[(int)random(paleta.length)];
  }

  // Método para controlar la rotación 90grados hacia la derecha.
  void rotate() {    
    int centerX = figura[1][0]; // Centro X relativo
    int centerY = figura[1][1]; // Centro Y relativo
  
    int[][] rotated = new int[4][2];
    
    // Si la figura es el cuadrado (O), no rota
    if (figura == O) return;
      
    // Aplicar rotación en sentido horario  
    for (int i = 0; i < 4; i++) {
      int x = figura[i][0] - centerX;
      int y = figura[i][1] - centerY;
      rotated[i][0] = centerX - y;
      rotated[i][1] = centerY + x;
    }
  
    // Si la rotación es válida, actualiza la figura.
    if (isValidRotation(rotated)) {
      figura = rotated;
      rotationCounter++;
    }
  }
  
  // Comprueba si la pieza puede moverse sin colisionar con una pieza ni los bordes.
  boolean checkEdges(String direction){
    for(int i = 0; i < 4; i++){
      int newX = figura[i][0] + gridPosX;
      int newY = figura[i][1] + gridPosY;
      
      if(direction == "RIGHT") newX++;
      if(direction == "LEFT")  newX--;
      if(direction == "DOWN")  newY++;
  
      if (newX < 0 || newX >= 10 || newY < 0 || newY >= 20) return false;
      if (gameBoard.filled[newX][newY]) return false;  // Colisión con otra pieza
    }
    return true;
  }
   
      // Compruba si laa rotación es coorrecta (no colisionaa ni sale del tablero)
  boolean isValidRotation(int[][] rotated) {
    for (int i = 0; i < 4; i++) {
      int x = rotated[i][0] + gridPosX;
      int y = rotated[i][1] + gridPosY;
      if (x < 0 || x >= 10 || y < 0 || y > 19) return false;
      if (gameBoard.filled[x][y]) return false;  // Validar colisión
    }
    return true;
  }

  // Comprobar si la pieza ha llegado al final
  boolean reachedBottom() {
    for (int i = 0; i < 4; i++) {
      int x = figura[i][0] + gridPosX;
      int y = figura[i][1] + gridPosY + 1;
      if (y > 19) return true; // Límite inferior del grid
      if (gameBoard.filled[x][y]) return true;
    }
    return false;
  }
}
