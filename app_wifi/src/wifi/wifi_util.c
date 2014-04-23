#include "wifi_util.h"

unsigned char* char_to_stream(unsigned char *p, unsigned char u8)
{
  *(p)++ = (unsigned char)(u8);
  return p;
}
/*===========================================================================*/
unsigned char* short_to_stream(unsigned char *p, unsigned short u16)
{
  *(p)++ = (unsigned char)(u16);
  *(p)++ = (unsigned char)((u16) >> 8);
  return p;
}
/*===========================================================================*/
unsigned char* int_to_stream(unsigned char *p, unsigned int u32)
{
  *(p)++ = (unsigned char)(u32);
  *(p)++ = (unsigned char)((u32) >> 8);
  *(p)++ = (unsigned char)((u32) >> 16);
  *(p)++ = (unsigned char)((u32) >> 24);
  return p;
}
/*===========================================================================*/
unsigned char* array_to_stream(unsigned char *p, unsigned char *a, int l)
{
    for(int i = 0; i < l; i++)
    {
        *(p)++ = ((unsigned char *) a)[i];
    }
    return p;
}
