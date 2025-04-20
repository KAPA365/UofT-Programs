#define AUDIO_BASE 0xFF203040
int main(void) {
// Audio codec Register address
	volatile int * audio_ptr = (int *) AUDIO_BASE;
	// intermediate values
	int left, right, fifospace;
	// This is an infinite loop checking the RARC to see if there is at least one
	// entry in the input fifos. If there is, just copy it over to the output fifo.
	// The timing of the input fifo controls the timing of the output
	while (1) {
		fifospace = *(audio_ptr + 1); // read the audio port fifospace register
		if ((fifospace & 0x000000FF) > 0) {
			// check RARC to see if there is at leastone sample input
			// load both input microphone channels - just get one sample from each
			int left = *(audio_ptr + 2); // note that this removes the sample
			int right = *(audio_ptr + 3);
			// store both of those samples to output channels
			*(audio_ptr + 2) = left;
			*(audio_ptr + 3) = right;
		}
	}
}