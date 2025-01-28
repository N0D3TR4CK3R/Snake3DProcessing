int boxSize = 40; // Tamaño de los cubos
PVector[] snake = new PVector[3]; // Serpiente compuesta por 3 segmentos
char currentDirection = 'D'; // Dirección inicial
char previousDirection = 'D'; // Dirección previa para evitar giros opuestos
boolean isGameOver = false; // Estado del juego
boolean easyMode = true; // Modo de juego: true para fácil, false para difícil
PVector food; // Posición de la esfera
int score = 0; // Contador de puntos
boolean isGameStarted = false; // Indica si el juego ha comenzado

void setup() {
  size(800, 800, P3D); // Tamaño del lienzo con vista 3D
  frameRate(10);

  // Inicializar la serpiente en el centro del plano
  for (int i = 0; i < snake.length; i++) {
    snake[i] = new PVector(-i * boxSize, 0, 0); // Cubos alineados en X
  }

  // Generar la primera posición de la esfera
  generateFood();
}

void draw() {
  if (!isGameStarted) {
    drawStartScreen(); // Mostrar pantalla de inicio
    return;
  }

  if (isGameOver) {
    background(0);
    drawUI(); // Dibujar UI específica para Game Over
    return;
  }

  background(30);
  lights();

  // Configurar la vista isométrica
  camera(width / 2.0, height / 2.0, 800, width / 2.0, height / 2.0, 0, 0, 1, 0);

  // Dibujar el plano
  drawGrid();

  // Dibujar las barreras
  drawBarriers();

  // Dibujar la serpiente
  for (PVector segment : snake) {
    pushMatrix();
    translate(width / 2 + segment.x, height / 2 - segment.y, segment.z);
    fill(0, 200, 0);
    stroke(0);
    box(boxSize);
    popMatrix();
  }

  // Dibujar la esfera (comida)
  drawFood();

  // Dibujar la UI
  hint(DISABLE_DEPTH_TEST); // Deshabilitar profundidad para superponer UI
  drawUI();
  hint(ENABLE_DEPTH_TEST); // Rehabilitar profundidad después de dibujar la UI

  // Actualizar la posición de la serpiente
  updateSnake();
}

void drawStartScreen() {
  background(0);

  // Dibujar el logo (placeholder: un rectángulo)
  fill(255, 0, 0);
  rectMode(CENTER);
  rect(width / 2, height / 2 - 100, 200, 100);

  // Dibujar los botones de dificultad
  fill(0, 255, 0);
  rect(width / 2, height / 2 + 50, 150, 50); // Botón "Normal"
  rect(width / 2, height / 2 + 150, 150, 50); // Botón "Difícil"

  // Texto de los botones
  fill(0);
  textSize(24);
  textAlign(CENTER, CENTER);
  text("Normal", width / 2, height / 2 + 50);
  text("Difícil", width / 2, height / 2 + 150);
}

void drawGrid() {
  stroke(50);
  for (int x = -400; x <= 400; x += boxSize) {
    for (int y = -400; y <= 400; y += boxSize) {
      line(width / 2 + x, height / 2 + y, 0, width / 2 + x, height / 2 + y, -10);
    }
  }
}

void drawBarriers() {
  fill(200, 0, 0); // Color de las barreras
  stroke(0);

  // Barreras horizontales (superior e inferior)
  for (int x = -400; x <= 400; x += boxSize) {
    pushMatrix();
    translate(width / 2 + x, height / 2 - 400, 0);
    box(boxSize);
    popMatrix();

    pushMatrix();
    translate(width / 2 + x, height / 2 + 400, 0);
    box(boxSize);
    popMatrix();
  }

  // Barreras verticales (izquierda y derecha)
  for (int y = -400; y <= 400; y += boxSize) {
    pushMatrix();
    translate(width / 2 - 400, height / 2 + y, 0);
    box(boxSize);
    popMatrix();

    pushMatrix();
    translate(width / 2 + 400, height / 2 + y, 0); // Ajuste de la barrera derecha
    box(boxSize);
    popMatrix();
  }
}

void drawFood() {
  pushMatrix();
  translate(width / 2 + food.x, height / 2 - food.y, food.z);
  fill(0, 0, 200);
  noStroke();
  sphere(boxSize / 2); // Dibujar la esfera como comida
  popMatrix();
}

void drawUI() {
  // Configurar estilo de texto
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);

  // Mostrar puntaje en la esquina superior izquierda
  text("Puntaje: " + score, 10, 10);

  // Si el juego terminó, mostrar texto adicional
  if (isGameOver) {
    fill(255, 0, 0);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("Game Over", width / 2, height / 2);
    textSize(20);
    text("Puntaje: " + score, width / 2, height / 2 + 50);
  }
}

void updateSnake() {
  // Calcular la próxima posición de la cabeza
  PVector nextPosition = snake[0].copy();
  switch (currentDirection) {
    case 'S':
      nextPosition.y -= boxSize;
      break;
    case 'W':
      nextPosition.y += boxSize;
      break;
    case 'A':
      nextPosition.x -= boxSize;
      break;
    case 'D':
      nextPosition.x += boxSize;
      break;
  }

  // Verificar colisión con las barreras
  if (nextPosition.x <= -400 || nextPosition.x >= 400 || nextPosition.y <= -400 || nextPosition.y >= 400) {
    if (easyMode) {
      currentDirection = previousDirection; // Detener la serpiente en modo fácil
      return;
    } else {
      isGameOver = true; // Terminar el juego en modo difícil
      return;
    }
  }

  // Verificar colisión con la comida
  if (nextPosition.equals(food)) {
    score++;
    generateFood();
    growSnake(); // Aumentar la longitud de la serpiente
  }

  // Actualizar las posiciones de la serpiente (cada segmento sigue al anterior)
  for (int i = snake.length - 1; i > 0; i--) {
    snake[i] = snake[i - 1].copy();
  }

  // Mover la cabeza a la nueva posición
  snake[0] = nextPosition;
  previousDirection = currentDirection; // Actualizar la dirección previa

  // Verificar colisión con el cuerpo
  checkSelfCollision();
}

void generateFood() {
  int cols = 800 / boxSize; // Número de columnas en la cuadrícula
  int rows = 800 / boxSize; // Número de filas en la cuadrícula

  // Generar una posición aleatoria dentro de los límites de la cuadrícula
  do {
    int x = (int) random(-cols / 2, cols / 2) * boxSize;
    int y = (int) random(-rows / 2, rows / 2) * boxSize;
    food = new PVector(x, y, 0);
  } while (Math.abs(food.x) >= 400 || Math.abs(food.y) >= 400);
}

void growSnake() {
  // Crear un nuevo array con un segmento adicional
  PVector[] newSnake = new PVector[snake.length + 1];

  // Copiar los segmentos existentes al nuevo array
  for (int i = 0; i < snake.length; i++) {
    newSnake[i] = snake[i].copy();
  }

  // Agregar un nuevo segmento al final, en la misma posición que el último segmento
  newSnake[snake.length] = snake[snake.length - 1].copy();

  // Reemplazar el array original con el nuevo array más grande
  snake = newSnake;
}

void checkSelfCollision() {
  // Verificar si la cabeza colisiona con algún segmento del cuerpo
  for (int i = 1; i < snake.length; i++) {
    if (snake[0].equals(snake[i])) {
      isGameOver = true; // Terminar el juego
      return;
    }
  }
}

void mousePressed() {
  if (!isGameStarted) {
    // Verificar si se hizo clic en el botón "Normal"
    if (mouseX > width / 2 - 75 && mouseX < width / 2 + 75 && mouseY > height / 2 + 25 && mouseY < height / 2 + 75) {
      easyMode = true;
      isGameStarted = true;
    }

    // Verificar si se hizo clic en el botón "Difícil"
    if (mouseX > width / 2 - 75 && mouseX < width / 2 + 75 && mouseY > height / 2 + 125 && mouseY < height / 2 + 175) {
      easyMode = false;
      isGameStarted = true;
    }
  }
}

void keyPressed() {
  // Cambiar la dirección según la tecla presionada, evitando giros opuestos
  if ((key == 'W' || key == 'w') && previousDirection != 'S') currentDirection = 'W';
  if ((key == 'S' || key == 's') && previousDirection != 'W') currentDirection = 'S';
  if ((key == 'A' || key == 'a') && previousDirection != 'D') currentDirection = 'A';
  if ((key == 'D' || key == 'd') && previousDirection != 'A') currentDirection = 'D';
}
