int boxSize = 40; // Tamaño de los cubos
PVector[] snake = new PVector[3]; // Serpiente compuesta por 3 segmentos
char currentDirection = 'D'; // Dirección inicial
char previousDirection = 'D'; // Dirección previa para evitar giros opuestos

void setup() {
  size(800, 800, P3D); // Tamaño del lienzo con vista 3D
  frameRate(10);

  // Inicializar la serpiente en el centro del plano
  for (int i = 0; i < snake.length; i++) {
    snake[i] = new PVector(-i * boxSize, 0, 0); // Cubos alineados en X
  }
}

void draw() {
  background(30);
  lights();
  
  // Configurar la vista isométrica
  camera(width / 2.0, height / 2.0, 800, width / 2.0, height / 2.0, 0, 0, 1, 0);

  // Dibujar el plano
  drawGrid();

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

void updateSnake() {
  // Actualizar las posiciones de la serpiente (cada segmento sigue al anterior)
  for (int i = snake.length - 1; i > 0; i--) {
    snake[i] = snake[i - 1].copy();
  }

  // Mover la cabeza según la dirección actual
  switch (currentDirection) {
    case 'S':
      snake[0].y -= boxSize;
      break;
    case 'W':
      snake[0].y += boxSize;
      break;
    case 'A':
      snake[0].x -= boxSize;
      break;
    case 'D':
      snake[0].x += boxSize;
      break;
  }

  previousDirection = currentDirection; // Actualizar la dirección previa
}

void keyPressed() {
  // Cambiar la dirección según la tecla presionada, evitando giros opuestos
  if ((key == 'W' || key == 'w') && previousDirection != 'S') currentDirection = 'W';
  if ((key == 'S' || key == 's') && previousDirection != 'W') currentDirection = 'S';
  if ((key == 'A' || key == 'a') && previousDirection != 'D') currentDirection = 'A';
  if ((key == 'D' || key == 'd') && previousDirection != 'A') currentDirection = 'D';
}
