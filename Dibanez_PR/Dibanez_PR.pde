/*=========================   
  ===== TETRIS BUBBLE =====
  =========================
  Se trata de una versión en inglés del clásico Tetris, utilizando formas circulares e inspirado
  estéticamente en otro juego clásico 'Puzzle Bobble'.
  
  Referencias para la lógica y comprender las rotaciones:
  - https://github.com/techiew/Tetris
  - https://www.youtube.com/watch?v=wQpnzWvmkOQ
  - https://gamedev.stackexchange.com/questions/17974/how-to-rotate-blocks-in-tetris
  - https://tetris.wiki/Super_Rotation_System
  
  Ejemplo de estética visual:
  - https://github.com/techiew/Tetris
  
  Documentación de Processing: 
  - https://processing.org/reference/
  
  Tipografías:
  - Título: https://www.dafont.com/es/bubble-bobble.font
  - Juego: https://fontstruct.com/fontstructions/show/2373883/bust-a-move-front
  
  Variaciones y física:
  - Las piezas (tetrominos) están formadas por círculos de colores en lugar de cuadrados.
  - El color de la siguiente pieza se puede cambiar al pulsar la tecla 'C'.
  - Si se completa una fila, se anotarán 10 puntos. Si la fila es del mismo color, 20 puntos.
  - La pieza cae automáticamente por defecto, como la atracción de la gravedad al centro de la tierra.
    Al pulsar la tecla hacia abajo, la pieza cae más rápido.
    
  Después de comprobar que funciona el código, he separado lass clases para la rejilla y las figuras
  en otros dos sketches.
  
  Música original creada por mi marido Joan Pere Jové para este juego, basándose en una combinación
  entre la música original de ambos juegos.
*/

// Cargamos la librería para el audio.
import processing.sound.*;
SoundFile file;

// Cargamos las fuentes tipográficas para el juego y el título.
PFont gameFont, titleFont;
  
// Declaración las clases principales
GameGrid gameBoard; // Rejilla para el juego
Shape activeShape; // Pieza activa en el juego
Shape nextShape; // Siguiente pieza

// Variables numéricas para contar la puntuación
int score, linesCount, colorLinesCount;

// Variables de estado del juego
boolean isGameOver = false; // Si ha acabado la partida
boolean gameStarted = false; // Si ha empezado la partida
boolean isPaused = false; // Si la partida está en pausa
boolean showControls = false; // Si se muestran o no los controles. 

// Paleta de colores para las piezas
color[] paleta = {
  color(218, 8, 4), // rojo
  color(0, 149, 0), // verde
  color(17, 130, 255), // azul
  color(248, 235, 51), // amarillo
  color(216, 132, 255) // lila
};


// Inicializamos el juego
void setup() {
  size(700, 700);
  
  // Tipografía para el juego.
  gameFont = createFont("bust-a-move.otf", 24);
  textFont(gameFont);
  
  // Tipografía para el título.
  titleFont = createFont("Bubble Bobble.ttf", 24);
  textFont(titleFont);
  
  // Sonido de fondo.
  file = new SoundFile(this, "TetrisBubble.mp3");
  file.loop();
  
  // Inicializamos las clases y variables de los contadores:
  gameBoard = new GameGrid(); // Generamos el tablero interno con la rejilla.
  activeShape = new Shape(); // Creamos una pieza.
  nextShape = new Shape(); // Creamos la siguiente pieza.
  score = 0; // puntuación
  linesCount = 0; // contador de líneas completadas
  colorLinesCount = 0; // contador de líneas completadas de colores.
}

void draw() {
  background(0);
  
  // Mostramos la pantalla de inicio del juego. 
  if (!gameStarted) {
    drawStartGame();
    return;
  }
  
  // Pintamos la estética e información
  drawBgSquares(); // Fondo de cuadrados
  drawFrames(); // Marcos
  drawScores(); // Puntuación
  drawInfo(); // Más información
  drawCopyright(); // Copyright
  drawNextShape(); // Siguiente figura

  // Condición para pausar la partida.
  if (isPaused) {
    drawPause();
    return;
  }

  // Condición para acabar la partida: 
  // Si la partida no ha acabado, muestra las piezas y las mueve hacia abajo.
  // Si la partida ha acabado, muestra el texto Game Over y posibilidad de empezar nueva partida. 
  if (!isGameOver) {
    if (activeShape.isActive) {
      activeShape.display();
      activeShape.moveDown();
    }
  } else {
    drawGameOver();
  }
  
  // Condición para mostrar la información de los controles del teclado. 
  if (showControls) {
    drawControlsOverlay();
  }
}


// Función para pintar las puntuaciones: total, líneas y líneas de colores.
void drawScores(){
  fill(255);
  textSize(12);
  textAlign(LEFT);
  text("SCORE ", 30, 50);
  
  textSize(18);
  textAlign(RIGHT);
  text(score, 135, 90);
  
  textSize(12);
  textAlign(LEFT);
  text("LINES ", 30, 130);
  
  textSize(18);
  textAlign(RIGHT);
  text(linesCount, 135, 170);
  
  textSize(12);
  textAlign(LEFT);
  text("COLOR", 30, 220);
  text("LINES", 30, 240);
  
  textSize(18);
  textAlign(RIGHT);
  text(colorLinesCount, 135, 270);
}


// Función para mostrar la info para ver los controles y pausar la partida.
void drawInfo(){
  int posX = 80;
  int posY = height/2;
  
  fill(255);
  textSize(11);
  textAlign(CENTER);
  text("HOLD 'I'", posX, posY + 60);
  text("TO SEE THE", posX, posY + 90);
  text("CONTROLS", posX, posY + 120);
  
  text("PRESS", posX, posY + height/4 + 40);
  text("'ENTER'", posX, posY + height/4 + 70);
  text("TO PAUSE", posX, posY + height/4 + 100);
}

// Función para pintar el copyright. 
void drawCopyright(){ 
  int posX = width - width/8 + 5;
  int posY = height - height/8;
  
  fill(255);
  textSize(8);
  textAlign(CENTER);
  text("CREATED BY", posX, posY - 80);
  text("DAVID IBANEZ", posX, posY - 60);
  
  text("MUSIC BY", posX, posY - 20);
  text("JOAN PERE JOVE", posX, posY);
}

// Función para pintar la ventana con los controles del teclado
void drawControlsOverlay() {
  float posX = 100;
  float posY = 200;
  float spacing = 50;
  
  // Guardamos en un array la info
  String[] infoLines = {
    "- LEFT / RIGHT: Move piece",
    "- DOWN: Faster drop",
    "- UP: Rotate",
    "- C: Change next piece color",
    "- ENTER: Pause game",
    "- I: Show/Hide controls"
  };
  
  fill(0, 0, 0, 200); // Fondo semitransparente
  noStroke();
  rect(50, 50, width - 100, height - 100);
  
  fill(255);
  textAlign(CENTER);
  textSize(28);
  text("CONTROLS", width / 2, 120);
  
  textSize(16);
  textAlign(LEFT);

  
  // Recorremos el array para pintar las instrucciones. 
  for (int i = 0; i < infoLines.length; i++) {
    text(infoLines[i], posX, posY + i * spacing);
  }
}

// Función para pintar la pantalla de inicio.
void drawStartGame() {
  
  // Llamamos a la función que pinta los cuadrados de fondo en el resto del juego.
  drawBgSquares();
  
  // Pintamos el título del juego con la tipografía indicada arriba.
  textAlign(CENTER, CENTER);
  fill(255);
  textFont(titleFont);
  textSize(80);
  text("TETRIS BUBBLE", width / 2, height / 2 - 70); // Subido un poco

  // Dibujamos burbujas de colores debajo del título como decoración.
  float bubbleSize = 30;
  float spacing = 60;
  float centerX = width / 2 - bubbleSize;
  float y = height / 2;
  
  for (int i = 0; i < paleta.length; i++) {
    fill(paleta[i]);
    float x = centerX + (i - 1.5) * spacing;
    circle(x, y, bubbleSize);
  }
  
  // Pintamos la info para empezar a jugar con la tipografía del juego
  textFont(gameFont);
  textSize(18);
  fill(255);
  text("PRESS SPACE TO START", width / 2, height / 2 + 60);
}


// Función para mostrar la pausa de la partida.
void drawPause(){
  textAlign(CENTER, CENTER);
  textSize(50);
  fill(255, 255, 0);
  text("PAUSE", width / 2, height / 2);
}

// Función para resetear las variables para empezar otra partida.
void resetGame() {
  gameBoard = new GameGrid();
  activeShape = new Shape();   
  nextShape = new Shape();     
  score = 0;
  linesCount = 0;
  colorLinesCount = 0;
  isGameOver = false;
  isPaused = false;
  showControls = false;
}

// Función para mostrar que la partida ha terminado - Game Over
void drawGameOver() {
  textAlign(CENTER, CENTER);
  textSize(50);
  fill(255, 0, 0);
  text("GAME OVER", width / 2, height / 2 - 30 );
  
  fill(255);
  textSize(18);
  text("PRESS SPACE TO RESTART", width / 2, height / 2 + 20);
}


// Función para pintar la muestra de la siguiente pieza
void drawNextShape() {
  float previewSize = min(width/2, height-40)/15;
  float offsetX = width - width / 4 + 65;
  float offsetY = 80;

  fill(255);
  textSize(12);
  textAlign(LEFT);
  text("NEXT", offsetX - 35, offsetY - 25);
  
  fill(nextShape.shapeColor);
  for (int i = 0; i < 4; i++) {
    float x = offsetX + nextShape.figura[i][0] * previewSize;
    float y = offsetY + 25 + nextShape.figura[i][1] * previewSize;
    circle(x, y, previewSize);
  }
  
  fill(255);
  textAlign(CENTER);
  text("PRESS 'C'", offsetX + 25, offsetY + 120);
  text("TO CHANGE", offsetX + 25, offsetY + 150);
  text("COLOR", offsetX + 25, offsetY + 180); 
}



// Función para pintar la cuadrícula del fondo
void drawBgSquares(){
  int bgCols = 20;
  int bgRows = 20;
  int bgCellWidth = width / bgCols;
  int bgCellHeight = height / bgRows;
  
  for (int i = 0; i < bgCols; i++) {
    for (int j = 0; j < bgRows; j++) {
      // Si la suma de la columna (i) y la fila (j) es par, usamos un color,
      // de lo contrario, usamos el otro color.
      if ((i + j) % 2 == 0) {
        fill(81, 23, 99);  // Color lila uno
      } else {
        fill(115, 30, 125);   // Color lila dos
      }
      noStroke();
      rect(i * bgCellWidth, j * bgCellHeight, bgCellWidth, bgCellHeight);
    }
  }
}

// Función para pintar el fondo y los marcos.
void drawFrames(){
  int posY = height / 2; 
  color intFrame = color(30, 100, 120);
  color extFrame = color(50, 80, 180);
  
  drawBgSquares(); // Pintar los cuadrados del fondo
  // Marco central (zona de juego)
  fill(0, 0, 0, 40);
  stroke(intFrame);
  strokeWeight(10);
  rect(width / 4 - 5, -8, width / 2 + 10, height + 4);
  
  // Marcos laterales
  stroke(extFrame);
  strokeWeight(8);
  rect(4, 0, width / 4 - 18, posY);
  rect(4, posY, width / 4 - 18, posY);
  rect(width - width / 4 + 12, height / 2, width / 4 - 18, posY);
  rect(width - width / 4 + 12, 0, width / 4 - 18, posY);

  // Rellenamos la rejilla de burbujas del centro.
  gameBoard.display();
}

// Configuración de la interación con el teclado.
void keyPressed(){

  // Si se pulsa el espacio y el juego no ha empezado, que empiece.
  // Si ha acabado la partida, que vuelva a empezar.
  if (key == ' ') {
    if (!gameStarted) {
      gameStarted = true;
      return;
    }
    
    if (isGameOver) {
      resetGame();
      return;
    }
  }
  
  // Si se pulsa la flecha derecha, la pieza se desplaza a la derecha.
  // Izquierda a la izquierda, abajo cae más rápido. 
  if(keyCode == RIGHT){
    activeShape.move("RIGHT");
  }
  
  if(keyCode == LEFT){
    activeShape.move("LEFT");
  }
  
  if(keyCode == DOWN){
    activeShape.move("DOWN");
  }
  
  // Si se pulsa la tecla 'C', la siguiente pieza cambia de color.
  if (key == 'c' || key == 'C') {
    nextShape.cambiarColor();
  }
  
  // Si se pulsa 'ENTER', se para la partida.
  if (keyCode == ENTER || keyCode == RETURN) {
    if (gameStarted && !isGameOver) {
      isPaused = !isPaused;
      return;
    }
  }
  
  // Si se pulsa 'I', muestraa los controles del teclado.
  if (key == 'i' || key == 'I') {
    showControls = true;
  }
}

// Utilizamos keyReleased para girar la pieza para que se gire al levantar la tecla
// y evitar que dé más vueltas. También para que se oculte la info de controles.
void keyReleased(){
  if(gameStarted && keyCode == UP){
    activeShape.rotate();
    activeShape.rotationCounter++;
  }
  
  if (key == 'i' || key == 'I') {
    showControls = false;
  }
}
