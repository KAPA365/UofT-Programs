#include <stdlib.h>
#include <stdbool.h>
int pixel_buffer_start; // global variable

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
	int dir = 1;
	int y = 100;
	while (1){
		draw_line(0, y, 319, y, 0x0);   // clear prev
		draw_line(0, y + dir, 319, y + dir, 0x365);   // this line is ??
		if (y < 239 && dir == 1 || y > 1 && dir == -1){
			y += dir;
		}
		else{
			dir = -dir;
		}
		wait_for_vsync();
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