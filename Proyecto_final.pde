import processing.sound.*;

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
PImage snakeSkin, snakeFace, cocoTexture, steelTexture, lavaTexture, bannerSprite, normalBtnSprite, hardBtnSprite;
PShader snakeShader; 
float shaderTime = 0;
SoundFile normalModeSound, hardModeSound, buttonSound, pointSound, gameOverSound;
PFont font;


void setup() {
  size(800, 800, P3D);
  frameRate(10);
  
  // Cargar texturas desde la carpeta data
  snakeSkin = loadImage("sprites/snake_sprites/snake_skin.png");
  snakeFace = loadImage("sprites/snake_sprites/snake_face.png");
  cocoTexture = loadImage("sprites/coconut_sprite/coconut.png");
  steelTexture = loadImage("sprites/barrier_sprites/steel.png");
  lavaTexture = loadImage("sprites/barrier_sprites/lava.png");
  bannerSprite = loadImage("sprites/screen_sprites/baner_sprite.png");
  normalBtnSprite = loadImage("sprites/screen_sprites/normal_btn.png");
  hardBtnSprite = loadImage("sprites/screen_sprites/hard_btn.png");
  
  // Verificar carga de texturas
  if (snakeSkin == null || snakeFace == null || steelTexture == null || lavaTexture == null || cocoTexture == null || bannerSprite == null || normalBtnSprite == null || hardBtnSprite == null) {
    println("Error: No se encontraron las texturas. Verifica la ruta.");
    exit();
  }

  // Cargar shaders
  snakeShader = loadShader("shaders/snake_frag.glsl", "shaders/snake_vert.glsl");

   // Verificar carga de shaders
  if (snakeShader == null) {
    println("Error: No se pudo cargar el shader. Verifica la ruta.");
    exit();
  }

    // Carga de sonidos
    normalModeSound = new SoundFile(this, "sounds/normal_mode.mp3");
    hardModeSound = new SoundFile(this, "sounds/hard_mode.mp3");
    buttonSound = new SoundFile(this, "sounds/btn_pressed.mp3");
    pointSound = new SoundFile(this, "sounds/point_sound.mp3"); 
    gameOverSound= new SoundFile(this, "sounds/game_over.mp3");
    
    //Cargamos fuente customizada
    font = createFont("fonts/Daydream.ttf",32);

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
  
  shaderTime += 0.05; // Ajusta este valor para cambiar la velocidad de la pulsación
  // Dibujar serpiente con texturas
   for (int i = 0; i < snake.length; i++) {
    if (i == 0) {
      drawSnakeHead(snake[i]); // Cabeza con textura especial
    } else {
      drawSnakeBody(snake[i]); // Cuerpo con textura normal
    }
  }
  resetShader();
  drawFood();

  hint(DISABLE_DEPTH_TEST);
  drawUI();
  hint(ENABLE_DEPTH_TEST);

  updateSnake();
  updateMusic();
}

void updateMusic() {
  if (isGameStarted && !showGameOverScreen) {
    if (easyMode) {
      if (normalModeSound != null && !normalModeSound.isPlaying()) {
        normalModeSound.loop();
      }
      if (hardModeSound != null) {
        hardModeSound.stop();
      }
    } else {
      if (normalModeSound != null) {
        normalModeSound.stop();
      }
      if (hardModeSound != null && !hardModeSound.isPlaying()) {
        hardModeSound.loop();
      }
    }
  } else {
    if (normalModeSound != null) {
      normalModeSound.stop();
    }
    if (hardModeSound != null) {
      hardModeSound.stop();
    }
  }
}

void drawSnakeHead(PVector pos) {
  pushMatrix();
  translate(width/2 + pos.x, height/2 - pos.y, pos.z);
  float hs = boxSize / 2; // Mitad del tamaño del cubo
  
  // Aplicar shader y pasar la textura
  shader(snakeShader);
  snakeShader.set("texture", snakeFace); // Pasar la textura al shader
  
  // Configurar el modo de textura
  textureMode(NORMAL);

  // Cara frontal (Z+) - Textura especial (snakeFace) rotada según la dirección
  beginShape(QUADS);
  texture(snakeFace);
  shader(snakeShader);
  snakeShader.set("texture", snakeFace);
  snakeShader.set("time", shaderTime);
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
  resetShader();
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
  
  resetShader();
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
  
  // Dibujar banner centrado
  imageMode(CENTER);
  image(bannerSprite, width/2, height/2 - 100, 300, 150); // Ajustar tamaño según necesidad
  
  // Botones con sprites
  image(normalBtnSprite, width/2, height/2 + 50, 180, 70);
  image(hardBtnSprite, width/2, height/2 + 150, 180, 70);

  drawButtonHoverEffect();
}

void drawGameOverScreen() {
  background(0);
  
  // Texto de game over
  textFont(font);
  textSize(32);
  fill(255, 0, 0);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/2 - 100);
  textSize(24);
  text("Puntaje: " + score, width/2, height/2 - 50);
  
  // Botones con sprites
  imageMode(CENTER);
  image(normalBtnSprite, width/2, height/2 + 50, 180, 70);
  image(hardBtnSprite, width/2, height/2 + 150, 180, 70);

  drawButtonHoverEffect();
}

void drawButtonHoverEffect() {
  rectMode(CENTER); // Asegurar mismo modo que los botones
  noFill();
  strokeWeight(3);
  float buttonWidth = 180;
  float buttonHeight = 70;
  
  // Botón normal
  if (mouseOver(width/2, height/2 + 50, buttonWidth, buttonHeight)) {
    stroke(255, 200);
    rect(width/2, height/2 + 50, buttonWidth, buttonHeight, 10);
  }
  
  // Botón difícil
  if (mouseOver(width/2, height/2 + 150, buttonWidth, buttonHeight)) {
    stroke(255, 200);
    rect(width/2, height/2 + 150, buttonWidth, buttonHeight, 10);
  }
}

boolean mouseOver(float x, float y, float w, float h) {
  return mouseX > x - w/2 && mouseX < x + w/2 && 
         mouseY > y - h/2 && mouseY < y + h/2;
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
  texture(cocoTexture);
  sphere(boxSize / 2);
  popMatrix();
}

void drawUI() {
  textFont(font);
  fill(255,255,200);
  textSize(30);
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
    pointSound.play();
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
      gameOverSound.play();
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
      buttonSound.play();
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
