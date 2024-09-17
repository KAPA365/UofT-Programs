#define AUDIO_BASE 0xFF203040
#define SW_BASE 0xFF200040
int main(void) {
	// Audio port structure
	struct audio_t {
		volatile unsigned int control; // The control/status register
		volatile unsigned char rarc; // the 8 bit RARC register
		volatile unsigned char ralc; // the 8 bit RALC register
		volatile unsigned char wsrc; // the 8 bit WSRC register
		volatile unsigned char wslc; // the 8 bit WSLC register
		volatile unsigned int ldata;
		volatile unsigned int rdata;
	};
	/* we don't need to 'reserve memory' for this, it is already there
	so we just need a pointer to this structure */
	struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);
	volatile int *sw = (int *) SW_BASE;
	// to hold values of samples
	int left, right;
	while (1) {
		int sw_in = *sw;
		// // read current switch
		double step = 8000/((2000-100) / 0x3ff * sw_in + 100), t = 0.0;
		// 100 - 2kHz, controlled by 2^10 - 1 outcomes of switches
		while (t < 8000){
			if (t < 4000){
				left = 0; // low
				right = 0;
			}
			else{
				left = 0xfffffff; // high
				right = 0xfffffff;
			}
			audiop->ldata = left; // store to the left output fifo
			audiop->rdata = right; // store to the right output fifo
			t += step;
		}
	}
}