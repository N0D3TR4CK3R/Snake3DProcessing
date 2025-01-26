int boxSize = 40; // Tamaño de los cubos
PVector[] snake = new PVector[3]; // Serpiente compuesta por 3 segmentos
char currentDirection = 'D'; // Dirección inicial
char previousDirection = 'D'; // Dirección previa para evitar giros opuestos
boolean isGameOver = false; // Estado del juego
boolean easyMode = true; // Modo de juego: true para fácil, false para difícil

void setup() {
  size(800, 800, P3D); // Tamaño del lienzo con vista 3D
  frameRate(10);

  // Inicializar la serpiente en el centro del plano
  for (int i = 0; i < snake.length; i++) {
    snake[i] = new PVector(-i * boxSize, 0, 0); // Cubos alineados en X
  }
}

void draw() {
  if (isGameOver) {
    background(0);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("Game Over", width / 2, height / 2);
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

  // Actualizar la posición de la serpiente
  updateSnake();
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

  // Actualizar las posiciones de la serpiente (cada segmento sigue al anterior)
  for (int i = snake.length - 1; i > 0; i--) {
    snake[i] = snake[i - 1].copy();
  }

  // Mover la cabeza a la nueva posición
  snake[0] = nextPosition;
  previousDirection = currentDirection; // Actualizar la dirección previa
}

void keyPressed() {
  // Cambiar la dirección según la tecla presionada, evitando giros opuestos
  if ((key == 'W' || key == 'w') && previousDirection != 'S') currentDirection = 'W';
  if ((key == 'S' || key == 's') && previousDirection != 'W') currentDirection = 'S';
  if ((key == 'A' || key == 'a') && previousDirection != 'D') currentDirection = 'A';
  if ((key == 'D' || key == 'd') && previousDirection != 'A') currentDirection = 'D';

  // Alternar entre modo fácil y difícil con la tecla M
  if (key == 'M' || key == 'm') easyMode = !easyMode;
}
