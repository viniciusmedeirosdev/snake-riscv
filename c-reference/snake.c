/*
 * Versão em C do mesmo Snake, só para comparação.
 * Cole no Compiler Explorer (godbolt.org), compilador Clang para RISC-V 32 bits,
 * com as opções:  -O2 -march=rv32i -mabi=ilp32
 * e compare o assembly gerado com src/snake.s (veja o RELATORIO.md).
 */
#include <stdint.h>

#define LED   ((volatile uint32_t *)0xF0000000)
#define DPAD  ((volatile uint32_t *)0xF0000DAC)   /* [0]=UP [1]=DOWN [2]=LEFT [3]=RIGHT */
#define W 35
#define H 25
#define CELLS (W * H)
#define DELAY 1000

enum { UP, DOWN, LEFT, RIGHT };
enum { C_BODY = 0x00C000, C_HEAD = 0xFFFF00, C_FOOD = 0xFF0000 };

static uint32_t rng = 1;
static volatile uint32_t *body[CELLS];          /* buffer circular */

static uint32_t xorshift(void) {
    rng ^= rng << 13; rng ^= rng >> 17; rng ^= rng << 5;
    return rng;
}

static void spawn_food(void) {
    for (;;) {
        uint32_t r = xorshift(), x = r & 63, y = (r >> 8) & 31;
        if (x >= W || y >= H || LED[y * W + x]) continue;
        LED[y * W + x] = C_FOOD;
        return;
    }
}

int main(void) {
    for (int i = 0; i < CELLS; i++) LED[i] = 0;
    while (!(DPAD[0] | DPAD[1] | DPAD[2] | DPAD[3])) rng++;
    rng |= 1;

    int x = 5, y = 12, dir = RIGHT, next = RIGHT, len = 0, score = 0;
    int head = -1, tail = 0;
    for (int i = 0; i < 3; i++, x++) {
        body[++head] = &LED[y * W + x];
        *body[head] = C_BODY; len++;
    }
    x--; *body[head] = C_HEAD;
    spawn_food();

    for (;;) {
        for (int d = 0; d < DELAY; d++) {
            if (DPAD[UP]    && dir != DOWN)  next = UP;
            if (DPAD[DOWN]  && dir != UP)    next = DOWN;
            if (DPAD[LEFT]  && dir != RIGHT) next = LEFT;
            if (DPAD[RIGHT] && dir != LEFT)  next = RIGHT;
        }
        dir = next;
        int nx = x + (dir == RIGHT) - (dir == LEFT);
        int ny = y + (dir == DOWN)  - (dir == UP);
        if ((unsigned)nx >= W || (unsigned)ny >= H) break;
        x = nx; y = ny;
        volatile uint32_t *cell = &LED[y * W + x];
        int ate = (*cell == C_FOOD);
        if (!ate) {
            *body[tail] = 0; tail = (tail + 1) % CELLS; len--;
            if (*cell) break;                         /* bateu no corpo */
        }
        *body[head] = C_BODY;
        head = (head + 1) % CELLS;
        body[head] = cell; *cell = C_HEAD; len++;
        if (ate) { score++; if (len >= CELLS) break; spawn_food(); }
    }
    return score;
}
