#include <stdlib.h>
#include <stdbool.h>
volatile int pixel_buffer_start; // global variable
short int Buffer1[240][512]; // 240 rows, 512 (320 + padding) columns
short int Buffer2[240][512];

void plot_box(int x, int y, short int line_color);
void plot_pixel(int x, int y, short int line_color);
void clear_screen(void);
void wait_for_vsync(void);
void draw_line(int x0, int y0, int x1, int y1, int clr);
int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // declare other variables(not shown)
    // initialize location and direction of rectangles(not shown)
	int x_box[8], y_box[8], dx[8], dy[8], clr_box[8];
	int prev[8][2], prevprev[8][2];
	int colour[10] = {
						0xFFFFFF, // White
						0xFF0000, // Red
						0x00FF00, // Green
						0x0000FF, // Blue
						0x00FFFF, // Cyan
						0xFF00FF, // Magenta
						0xFFFF00, // Yellow
						0x808080, // Dark Gray
						0xC0C0C0  // Light Gray
						};
	for (int i = 0; i < 8; i++){
		x_box[i] = rand()%319;
		y_box[i] = rand()%239;
		clr_box[i] = colour[rand()%10];
		dx[i] = (( rand() %2) *2) - 1;
		dy[i] = (( rand() %2) *2) - 1;
		for (int j = 0; j < 2; j ++){
			prev[i][j] = 0;
			prevprev[i][j] = 0;
		}
	}
    /* set front pixel buffer to Buffer 1 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the  back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
	
    /* set back pixel buffer to Buffer 2 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    while (1)
    {
		//clear 2 frames ago
		for (int i = 0; i < 8; i ++){
			plot_box(prevprev[i][0], prevprev[i][1], 0);
			draw_line(prevprev[i][0], prevprev[i][1], \
					  prevprev[(i+1) % 8][0], prevprev[(i+1) % 8][1], 0);
			plot_box(prev[i][0], prev[i][1], 0);
			draw_line(prev[i][0], prev[i][1], \
					  prev[(i+1) % 8][0], prev[(i+1) % 8][1], 0);
		}
        // code for drawing the boxes and lines (not shown)
        // code for updating the locations of boxes (not shown)
		for (int i = 0; i < 8; i ++){
			plot_box(x_box[i], y_box[i], clr_box[i]);
			draw_line(x_box[i], y_box[i], x_box[(i+1) % 8], y_box[(i+1) % 8], 0xFFFFFF);
			prevprev[i][0] = prev[i][0];
			prevprev[i][1] = prev[i][1];
			prev[i][0] = x_box[i];
			prev[i][1] = y_box[i];
			x_box[i] += dx[i];
			y_box[i] += dy[i];
			if (x_box[i] == 0 || x_box[i] == 319){
				dx[i] = -dx[i];
			}
			if (y_box[i] == 0 || y_box[i] == 239){
				dy[i] = -dy[i];
			}
		}
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

// code for subroutines (not shown)

void plot_box(int x, int y, short int line_color){
	for (int j = y; j <= y + 1; j++){
		for (int i = x; i <= x + 1; i++){
			plot_pixel(i, j, line_color);
		}
	}
}

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;

        one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);

        *one_pixel_address = line_color;
}

void clear_screen(){
	for (int y = 0; y < 240; y++){
		for (int x = 0; x < 320; x++){
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
    volatile int * pixel_ctrl_ptr = (int *) 0xff203020; // base address
    int status;
    *pixel_ctrl_ptr = 1; // start the synchronization process
    // write 1 into front buffer address register
    status = *(pixel_ctrl_ptr + 3); // read the status register
    while ((status & 0x01) != 0) { // polling loop waiting for S bit to go to 0
        status = *(pixel_ctrl_ptr + 3);
    } // loop/function exits when status bit goes to 0
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

  