int boxSize = 40;
PVector[] snake = new PVector[3];
char currentDirection = 'D';
char previousDirection = 'D';
boolean isGameOver = false;
boolean easyMode = true;
PVector food;
int score = 0;
boolean isGameStarted = false;
boolean showGameOverScreen = false;
PImage snakeSkin, snakeFace, cocoTexture, steelTexture, lavaTexture;

void setup() {
  size(800, 800, P3D);
  frameRate(10);
  
  // Cargar texturas desde la carpeta data
  snakeSkin = loadImage("sprites/snake_sprites/snake_skin.png");
  snakeFace = loadImage("sprites/snake_sprites/snake_face.png");
  cocoTexture = loadImage("sprites/coconut_sprite/coconut.png");
  steelTexture = loadImage("sprites/barrier_sprites/steel.png");
  lavaTexture = loadImage("sprites/barrier_sprites/lava.png");
  
  // Verificar carga de texturas
  if (snakeSkin == null || snakeFace == null || steelTexture == null || lavaTexture == null || cocoTexture == null) {
    println("Error: No se encontraron las texturas. Verifica la ruta.");
    exit();
  }

  // Inicializar serpiente
  for (int i = 0; i < snake.length; i++) {
    snake[i] = new PVector(-i * boxSize, 0, 0);
  }
  
  generateFood();
}

void draw() {
  if (!isGameStarted) {
    drawStartScreen();
    return;
  }
  
  if (showGameOverScreen) {
    drawGameOverScreen();
    return;
  }

  background(30);
  lights();
  camera(width/2.0, height/2.0, 800, width/2.0, height/2.0, 0, 0, 1, 0);

  drawGrid();
  drawBarriers();
  
  // Dibujar serpiente con texturas
   for (int i = 0; i < snake.length; i++) {
    if (i == 0) {
      drawSnakeHead(snake[i]); // Cabeza con textura especial
    } else {
      drawSnakeBody(snake[i]); // Cuerpo con textura normal
    }
  }
  
  drawFood();

  hint(DISABLE_DEPTH_TEST);
  drawUI();
  hint(ENABLE_DEPTH_TEST);

  updateSnake();
}

void drawSnakeHead(PVector pos) {
  pushMatrix();
  translate(width/2 + pos.x, height/2 - pos.y, pos.z);
  float hs = boxSize / 2; // Mitad del tamaño del cubo
  
  // Configurar el modo de textura
  textureMode(NORMAL);

  // Cara frontal (Z+) - Textura especial (snakeFace) rotada según la dirección
  beginShape(QUADS);
  texture(snakeFace);
  
  // Ajustar coordenadas UV según la dirección
  switch (currentDirection) {
    case 'W': // Arriba
      vertex(-hs, -hs, hs, 0, 0); // Sin rotación
      vertex(hs, -hs, hs, 1, 0);
      vertex(hs, hs, hs, 1, 1);
      vertex(-hs, hs, hs, 0, 1);
      break;
    case 'S': // Abajo
      vertex(-hs, -hs, hs, 1, 0); // Rotación 180 grados
      vertex(hs, -hs, hs, 0, 0);
      vertex(hs, hs, hs, 0, 1);
      vertex(-hs, hs, hs, 1, 1);
      break;
    case 'A': // Izquierda
      vertex(-hs, -hs, hs, 0, 1); // Rotación 90 grados antihorario
      vertex(hs, -hs, hs, 0, 0);
      vertex(hs, hs, hs, 1, 0);
      vertex(-hs, hs, hs, 1, 1);
      break;
    case 'D': // Derecha
      vertex(-hs, -hs, hs, 1, 1); // Rotación 90 grados horario
      vertex(hs, -hs, hs, 1, 0);
      vertex(hs, hs, hs, 0, 0);
      vertex(-hs, hs, hs, 0, 1);
      break;
  }
  endShape();

  // Cara trasera (Z-) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, -hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  // Cara izquierda (X-) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(-hs, -hs, hs, 1, 0);  // Esquina inferior derecha
  vertex(-hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  // Cara derecha (X+) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  // Cara superior (Y-) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, -hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, -hs, hs, 0, 1);  // Esquina superior izquierda
  endShape();

  // Cara inferior (Y+) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(-hs, hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, hs, 0, 1);  // Esquina superior izquierda
  endShape();

  popMatrix();
}

// Función para el CUERPO (segmentos 2+)
void drawSnakeBody(PVector pos) {
  pushMatrix();
  translate(width/2 + pos.x, height/2 - pos.y, pos.z);
  float hs = boxSize/2;

  // Todas las caras con snakeSkin
  beginShape(QUADS);
  texture(snakeSkin);
  // Cara frontal (Z+)
  vertex(-hs, -hs, hs, 0, 0);
  vertex(hs, -hs, hs, 1, 0);
  vertex(hs, hs, hs, 1, 1);
  vertex(-hs, hs, hs, 0, 1);
  endShape();

  // Cara trasera (Z-) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, -hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  // Cara izquierda (X-) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(-hs, -hs, hs, 1, 0);  // Esquina inferior derecha
  vertex(-hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  // Cara derecha (X+) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  // Cara superior (Y-) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, -hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, -hs, hs, 0, 1);  // Esquina superior izquierda
  endShape();

  // Cara inferior (Y+) - Textura normal (snakeSkin)
  beginShape(QUADS);
  texture(snakeSkin);
  vertex(-hs, hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, hs, 0, 1);  // Esquina superior izquierda
  endShape();
  
  popMatrix();
}

void drawStartScreen() {
  background(0);
  fill(255, 0, 0);
  rectMode(CENTER);
  rect(width/2, height/2 - 100, 200, 100);
  
  fill(0, 255, 0);
  rect(width/2, height/2 + 50, 150, 50);
  rect(width/2, height/2 + 150, 150, 50);
  
  fill(0);
  textSize(24);
  textAlign(CENTER, CENTER);
  text("Normal", width/2, height/2 + 50);
  text("Difícil", width/2, height/2 + 150);
}

void drawGameOverScreen() {
  background(0);
  fill(255, 0, 0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/2 - 100);
  
  textSize(24);
  text("Puntaje: " + score, width/2, height/2 - 50);
  
  fill(0, 255, 0);
  rect(width/2, height/2 + 50, 150, 50);
  rect(width/2, height/2 + 150, 150, 50);
  
  fill(0);
  text("Normal", width/2, height/2 + 50);
  text("Difícil", width/2, height/2 + 150);
}

void drawGrid() {
  stroke(50);
  for (int x = -400; x <= 400; x += boxSize) {
    for (int y = -400; y <= 400; y += boxSize) {
      line(width/2 + x, height/2 + y, 0, width/2 + x, height/2 + y, -10);
    }
  }
}

void drawBarriers() {
  // Determinar qué textura usar según el modo
  PImage barrierTexture = easyMode ? steelTexture : lavaTexture;
  
  // Configurar propiedades comunes
  textureMode(NORMAL);
  noStroke();
  
  // Dibujar barreras horizontales (superior e inferior)
  for (int x = -400; x <= 400; x += boxSize) {
    drawBarrierSegment(x, -400, barrierTexture); // Barrera superior
    drawBarrierSegment(x, 400, barrierTexture);  // Barrera inferior
  }

  // Dibujar barreras verticales (izquierda y derecha)
  for (int y = -400; y <= 400; y += boxSize) {
    drawBarrierSegment(-400, y, barrierTexture); // Barrera izquierda
    drawBarrierSegment(400, y, barrierTexture);  // Barrera derecha
  }
}

// Función auxiliar para dibujar un segmento de barrera
void drawBarrierSegment(float x, float y, PImage tex) {
  pushMatrix();
  translate(width/2 + x, height/2 + y, 0);
  
  float hs = boxSize/2;
  
  beginShape(QUADS);
  texture(tex);
  vertex(-hs, -hs, hs, 0, 0);
  vertex(hs, -hs, hs, 1, 0);
  vertex(hs, hs, hs, 1, 1);
  vertex(-hs, hs, hs, 0, 1);
  endShape();

  beginShape(QUADS);
  texture(tex);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, -hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  beginShape(QUADS);
  texture(tex);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(-hs, -hs, hs, 1, 0);  // Esquina inferior derecha
  vertex(-hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  beginShape(QUADS);
  texture(tex);
  vertex(hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(hs, hs, -hs, 0, 1);  // Esquina superior izquierda
  endShape();

  beginShape(QUADS);
  texture(tex);
  vertex(-hs, -hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, -hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, -hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, -hs, hs, 0, 1);  // Esquina superior izquierda
  endShape();

  beginShape(QUADS);
  texture(tex);
  vertex(-hs, hs, -hs, 0, 0); // Esquina inferior izquierda
  vertex(hs, hs, -hs, 1, 0);  // Esquina inferior derecha
  vertex(hs, hs, hs, 1, 1);   // Esquina superior derecha
  vertex(-hs, hs, hs, 0, 1);  // Esquina superior izquierda
  endShape();
  
  popMatrix();
}

void drawFood() {
  pushMatrix();
  translate(width/2 + food.x, height/2 - food.y, food.z);
  
  // Configurar el modo de textura
  textureMode(NORMAL);
  
  // Dibujar la esfera con textura
  beginShape(SPHERE);
  texture(cocoTexture);
  sphere(boxSize / 2); // Tamaño de la esfera
  endShape();
  
  popMatrix();
}

void drawUI() {
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Puntaje: " + score, 10, 10);
}

void updateSnake() {
  PVector nextPosition = snake[0].copy();
  switch (currentDirection) {
    case 'S': nextPosition.y -= boxSize; break;
    case 'W': nextPosition.y += boxSize; break;
    case 'A': nextPosition.x -= boxSize; break;
    case 'D': nextPosition.x += boxSize; break;
  }

  if (nextPosition.x <= -400 || nextPosition.x >= 400 || 
      nextPosition.y <= -400 || nextPosition.y >= 400) {
    if (easyMode) {
      currentDirection = previousDirection;
      return;
    } else {
      isGameOver = true;
      return;
    }
  }

  if (nextPosition.equals(food)) {
    score++;
    generateFood();
    growSnake();
  }

  for (int i = snake.length - 1; i > 0; i--) {
    snake[i] = snake[i - 1].copy();
  }

  snake[0] = nextPosition;
  previousDirection = currentDirection;
  checkSelfCollision();
}

void generateFood() {
  int cols = 800 / boxSize;
  int rows = 800 / boxSize;
  do {
    int x = (int)random(-cols/2, cols/2) * boxSize;
    int y = (int)random(-rows/2, rows/2) * boxSize;
    food = new PVector(x, y, 0);
  } while (abs(food.x) >= 400 || abs(food.y) >= 400);
}

void growSnake() {
  PVector[] newSnake = new PVector[snake.length + 1];
  for (int i = 0; i < snake.length; i++) {
    newSnake[i] = snake[i].copy();
  }
  newSnake[snake.length] = snake[snake.length - 1].copy();
  snake = newSnake;
}

void checkSelfCollision() {
  for (int i = 1; i < snake.length; i++) {
    if (snake[0].equals(snake[i])) {
      showGameOverScreen = true;
      isGameOver = true;
      return;
    }
  }
}

void mousePressed() {
  if (!isGameStarted || showGameOverScreen) {
    boolean clickNormal = mouseX > width/2 - 75 && mouseX < width/2 + 75 && 
                         mouseY > height/2 + 25 && mouseY < height/2 + 75;
    boolean clickHard = mouseX > width/2 - 75 && mouseX < width/2 + 75 && 
                       mouseY > height/2 + 125 && mouseY < height/2 + 175;

    if (clickNormal || clickHard) {
      isGameStarted = true;
      showGameOverScreen = false;
      isGameOver = false;
      score = 0;
      easyMode = clickNormal;
      
      snake = new PVector[3];
      for (int i = 0; i < snake.length; i++) {
        snake[i] = new PVector(-i * boxSize, 0, 0);
      }
      generateFood();
    }
  }
}

void keyPressed() {
  if ((key == 'W' || key == 'w') && previousDirection != 'S') currentDirection = 'W';
  if ((key == 'S' || key == 's') && previousDirection != 'W') currentDirection = 'S';
  if ((key == 'A' || key == 'a') && previousDirection != 'D') currentDirection = 'A';
  if ((key == 'D' || key == 'd') && previousDirection != 'A') currentDirection = 'D';
}
