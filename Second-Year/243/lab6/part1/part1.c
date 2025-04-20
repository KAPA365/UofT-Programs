int main(void){
	volatile int *KEYs = 0xff200050;
	volatile int *LEDs = 0xff200000;
	// getting the KEYs edge capture register into the variable edge_cap:
	while (1){
		int edge_cap = *(KEYs + 3);
		if (edge_cap & 0x1){
			*LEDs = 0x3ff;
		}
		if (edge_cap & 0x2){
			*LEDs = 0x0;
		}
		if (edge_cap != 0){
			*(KEYs + 3) = 0xf;
		}
	}
}
