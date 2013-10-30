#include "hci_helper.h"

/*---------------------------------------------------------------------------
 This function is used for copying 16 bit to stream while converting to
 little endian format.
 ---------------------------------------------------------------------------*/
unsigned char* char_to_stream(unsigned char *p, unsigned char u8)
{
	*(p)++ = (unsigned char)(u8);
	return p;
}

/*---------------------------------------------------------------------------
 This function is used for copying 16 bit to stream while converting to
 little endian format.
 ---------------------------------------------------------------------------*/
unsigned char* short_to_stream(unsigned char *p, unsigned short u16)
{
	*(p)++ = (unsigned char)(u16);
	*(p)++ = (unsigned char)((u16) >> 8);
	return p;
}

/*---------------------------------------------------------------------------
 This function is used for copying 32 bit to stream while converting to
 little endian format.
 ---------------------------------------------------------------------------*/
unsigned char* int_to_stream(unsigned char *p, unsigned int u32)
{
	*(p)++ = (unsigned char)(u32);
	*(p)++ = (unsigned char)((u32) >> 8);
	*(p)++ = (unsigned char)((u32) >> 16);
	*(p)++ = (unsigned char)((u32) >> 24);
	return p;
}

/*---------------------------------------------------------------------------
 This macro is used for copying a specified value length bits (l) to stream
 while converting to little endian format.
 ---------------------------------------------------------------------------*/
unsigned char* array_to_stream(unsigned char *p, unsigned char *a, int l)
{
    for(int i = 0; i < l; i++)
    {
        *(p)++ = ((unsigned char *) a)[i];
    }
    return p;
}

/*---------------------------------------------------------------------------
 This function is used for copying received stream to 8 bit in little endian
 format.
 ---------------------------------------------------------------------------*/
unsigned char stream_to_char(char* p, unsigned int offset)
{
    return (unsigned char)(*(p + offset));
}

/*---------------------------------------------------------------------------
 This function is used for copying received stream to 16 bit in little endian
 format.
 ---------------------------------------------------------------------------*/
unsigned short stream_to_short(char* p, unsigned int offset)
{
  return (unsigned short) ((unsigned short)
      ((unsigned short) (*(p + offset + 1)) << 8) +
      (unsigned short) (*(p + offset)));
}

/*---------------------------------------------------------------------------
 This function is used for copying received stream to 32 bit in little endian
 format.
 ---------------------------------------------------------------------------*/
unsigned int stream_to_int(char* p, unsigned int offset)
{
  return (unsigned int) ((unsigned int)
      ((unsigned int) (*(p + offset + 3)) << 24) +
      (unsigned int) ((unsigned int) (*(p + offset + 2)) << 16) +
      (unsigned int) ((unsigned int) (*(p + offset + 1)) << 8) +
      (unsigned int) (*(p + offset)));
}
