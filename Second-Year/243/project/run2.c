#include <stdbool.h>
#include <stdlib.h>
#define AUDIO_BASE 0xFF203040
#define SW_BASE 0xFF200040
#define MAX_OBSTACLES 3
volatile int pixel_buffer_start;
short int Buffer1[240][512];
short int Buffer2[240][512];

typedef struct {
  int positionX;
  int positionY;
  int health;
  int score;
} Player;

typedef struct {
  int positionX;
  int positionY;
  int type;  // = 0 short; = 1 high
} Obstacle;

typedef struct {
  Obstacle obstacles[MAX_OBSTACLES];
  int numObstacles;
  int board[3][200];
  int difficulty;
  Player player;
} Game;

void initializePlayer(Player *player);
int updateHealth(Player *player);
int addScore(Player *player);
void playerTurnLeft(Player *player);
void playerTurnRight(Player *player);
void spawnObstacle(Obstacle *obstacle);
void gameStart(Game *game);
void gameUpdate(Game *game);
void gameEnd(Game *game);
void plot_box(int x, int y, int width, short int line_color);
void plot_pixel(int x, int y, short int line_color);
void clear_screen();
void swap(int *a, int *b);
void wait_for_vsync();                                    // from lab7
void draw_line(int x0, int y0, int x1, int y1, int clr);  // from lab7
void playSound(int snd);                                  // from lab6
void keyDetect(Player *player);                           // from eecg

int main() {
  volatile int *pixel_ctrl_ptr = (int *)0xff203020;
  *(pixel_ctrl_ptr + 1) = (int)&Buffer2;
  pixel_buffer_start = *(pixel_ctrl_ptr + 1);
  wait_for_vsync();
  Game game;
  gameStart(&game);
  while (game.player.health > 0) {
    keyDetect(&game.player);
    gameUpdate(&game);
    wait_for_vsync();  // swap front and back buffers on VGA vertical sync
    pixel_buffer_start = *(pixel_ctrl_ptr + 1);  // new back buffer
  }
  return 0;
}

void initializePlayer(Player *player) {
  player->positionX = 1;
  player->positionY = 200;  // use 100 width, 200 height of screen
  player->health = 3;
  player->score = 0;
}

int updateHealth(Player *player) {
  player->health -= 1;
  return player->health;
}

int addScore(Player *player) {
  player->score += 1;
  return player->score;
}

void playerTurnLeft(Player *player) {
  if (player->positionX > 0) {
    player->positionX -= 1;
  } else {
    playSound(600);
  }
}

void playerTurnRight(Player *player) {
  if (player->positionX < 2) {
    player->positionX += 1;
  } else {
    playSound(600);
  }
}

void spawnObstacle(Obstacle *obstacle) {
  obstacle->positionY = 0;
  obstacle->positionX = rand() % 3;
  obstacle->type = rand() % 2;
}

void gameStart(Game *game) {
  initializePlayer(&game->player);
  for (int x = 0; x < 3; x++) {
    for (int y = 0; y < 200; y++) {
      game->board[x][y] = 0;
    }
  }
  game->numObstacles = MAX_OBSTACLES;
  for (int i = 0; i < MAX_OBSTACLES; i++) {
    spawnObstacle(&game->obstacles[i]);
  }
  // init display
  volatile int *pixel_ctrl_ptr = (int *)0xff203020;
  *(pixel_ctrl_ptr + 1) = (int)&Buffer1;
  wait_for_vsync();
  pixel_buffer_start = *pixel_ctrl_ptr;
  clear_screen();
  *(pixel_ctrl_ptr + 1) = (int)&Buffer2;
  pixel_buffer_start = *(pixel_ctrl_ptr + 1);
  clear_screen();
}

void gameUpdate(Game *game) {
  keyDetect(&game->player);
  for (int i = 0; i < game->numObstacles; i++) {  // gameplay
    game->obstacles[i].positionY += 1;
    if (game->obstacles[i].positionY >= 200) {
      spawnObstacle(&game->obstacles[i]);
    }
    if (game->obstacles[i].positionY == game->player.positionY &&
        game->obstacles[i].positionX == game->player.positionX) {
      playSound(600);
      if (updateHealth(&game->player) == 0) {
        gameEnd(&game);
        return;
      }
    } else {
      addScore(&game->player);
    }
  }
  clear_screen();  // need optimize later

  plot_box(game->player.positionX * 100, game->player.positionY, 5, 0x07E0);
  for (int i = 0; i < game->numObstacles; i++) {
    plot_box(game->obstacles[i].positionX * 100, game->obstacles[i].positionY,
             game->obstacles[i].type * 10 + 10, 0xF800);
  }
  // draw_score()
}

void gameEnd(Game *game) {
  playSound(800);
  game->player.score = 0;
  game->player.health = 3;
}

void playSound(int snd) {
  struct audio_t {
    volatile unsigned int control;
    volatile unsigned char rarc;
    volatile unsigned char ralc;
    volatile unsigned char wsrc;
    volatile unsigned char wslc;
    volatile unsigned int ldata;
    volatile unsigned int rdata;
  };
  struct audio_t *const audiop = ((struct audio_t *)AUDIO_BASE);
  int left, right;
  while (1) {
    double step = 8000 / ((2000 - 100) / 0x3ff * snd + 100), t = 0.0;
    while (t < 8000) {
      if (t < 4000) {
        left = 0;  // low
        right = 0;
      } else {
        left = 0xfffffff;  // high
        right = 0xfffffff;
      }
      audiop->ldata = left;
      audiop->rdata = right;
      t += step;
    }
  }
}

void plot_box(int x, int y, int width, short int line_color) {
  for (int j = y; j < y + width; j++) {
    for (int i = x; i < x + width; i++) {
      plot_pixel(i, j, line_color);
    }
  }
}

void plot_pixel(int x, int y, short int line_color) {
  volatile short int *one_pixel_address;
  one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);
  *one_pixel_address = line_color;
}

void clear_screen() {
  for (int y = 0; y < 240; y++) {
    for (int x = 0; x < 320; x++) {
      plot_pixel(x, y, 0x0);
    }
  }
}

void swap(int *a, int *b) {
  int temp = *a;
  *a = *b;
  *b = temp;
}

void wait_for_vsync() {
  volatile int *pixel_ctrl_ptr = (int *)0xff203020;
  int status;
  *pixel_ctrl_ptr = 1;
  status = *(pixel_ctrl_ptr + 3);
  while ((status & 0x01) != 0) {
    status = *(pixel_ctrl_ptr + 3);
  }
}

void draw_line(int x0, int y0, int x1, int y1, int clr) {
  bool is_steep = abs(y1 - y0) > abs(x1 - x0);
  if (is_steep) {
    swap(&x0, &y0);
    swap(&x1, &y1);
  }

  if (x0 > x1) {
    swap(&x0, &x1);
    swap(&y0, &y1);
  }
  int deltax = x1 - x0;
  int deltay = abs(y1 - y0);
  int error = -(deltax / 2);
  int y = y0;
  int y_step;
  if (y0 < y1) {
    y_step = 1;
  } else {
    y_step = -1;
  }
  for (int x = x0; x <= x1; x++) {
    if (is_steep) {
      plot_pixel(y, x, clr);
    } else {
      plot_pixel(x, y, clr);
    }
    error += deltay;
    if (error > 0) {
      y += y_step;
      error -= deltax;
    }
  }
}

void keyDetect(Player *player) {  // modified from eecg websites
  volatile int *PS2_ptr = (int *)0xFF200100;
  unsigned char byte1 = 0;
  unsigned char byte2 = 0;
  unsigned char byte3 = 0;
  int PS2_data = *(PS2_ptr);
  int RVALID = (PS2_data & 0x8000);
  if (RVALID) {
    byte1 = byte2;
    byte2 = byte3;
    byte3 = PS2_data & 0xFF;
    if (byte2 != 0xF0) {
      if (byte3 == 0x6B) {  // left arrow
        playerTurnLeft(&player);
      } else if (byte3 == 0x74) {  // right
        playerTurnRight(&player);
      }
    }
  }
  return;
}
