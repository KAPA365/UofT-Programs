#define AUDIO_BASE 0xFF203040
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
	// to hold values of samples
	int left, right, cnt = 0;
	int leftList[3200], rightList[3200];
	
	while (cnt < 3200) { // first loop with no echos
		if (audiop->rarc > 0 || audiop->ralc > 0){
			// load both input microphone channels - just get one sample from each
			left = audiop->ldata; // load the left input fifo
			right = audiop->rdata; // load the right input fifo
			audiop->ldata = left; // store to the left output fifo
			audiop->rdata = right; // store to the right output fifo
			leftList[cnt] = left; // store to list for further
			rightList[cnt] = right;
			cnt ++;
		}
	}
	while (1){ // now with echos
		cnt = 0; // reset
		while (cnt < 3200){
			if (audiop->rarc > 0 || audiop->ralc > 0){
				// load both input microphone channels - just get one sample from each
				left = audiop->ldata; // load the left input fifo
				right = audiop->rdata; // load the right input fifo
				audiop->ldata = left + (int) (leftList[cnt] * 0.8); 
				// store to the left output fifo, with echo loaded from list
				audiop->rdata = right + (int) (rightList[cnt] * 0.8); 
				// store to the right output fifo, with echo loaded from list
				leftList[cnt] = left + (int) (leftList[cnt] * 0.8);; // store to list for further
				rightList[cnt] = right + (int) (rightList[cnt] * 0.8);
				cnt ++;
			}
		}
	}
}