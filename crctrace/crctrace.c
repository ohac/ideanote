#include <stdio.h>
#include <string.h>

static unsigned short crctracecrc;
void crctraceout(FILE* fp)
{
	fprintf(fp, "%04x\n", crctracecrc);
}

void crctraceimpl(char* filename, int lineno)
{
	unsigned char c = (unsigned char)lineno;
	unsigned short crc = crctracecrc;
	int i = 0;
	int l = strlen(filename);
	for (; i < l; i++) c ^= filename[i];
	for (i = 0; i < 8; i++) {
		unsigned char a = c;
		if (crc & 1) a++;
		crc >>= 1;
		if (a & 1) crc ^= 0xa001;
		c >>= 1;
	}
	crctracecrc = crc;
}
#define crctrace() crctraceimpl(__FILE__, __LINE__)

void sub(int i) {
	crctrace();
	if (i < 10) {
		crctrace();
	}
}

int main(int argc, char **argv)
{
	crctrace();
	sub(7);
	crctrace();
	sub(17);
	crctraceout(stdout);
	return 0;
}
