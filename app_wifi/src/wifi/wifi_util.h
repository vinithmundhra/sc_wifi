#ifndef _wifi_util_h_
#define _wifi_util_h_

unsigned char* char_to_stream(unsigned char *p, unsigned char u8);
unsigned char* short_to_stream(unsigned char *p, unsigned short u16);
unsigned char* int_to_stream(unsigned char *p, unsigned int u32);
unsigned char* array_to_stream(unsigned char *p, unsigned char *a, int l);

#endif //_wifi_util_h_
