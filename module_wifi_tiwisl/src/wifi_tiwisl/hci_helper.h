// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

#ifndef _hci_helper_h_
#define _hci_helper_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/
 
/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Copy char to stream
 *
 *  \param *p    pointer to array location
 *  \param u8    the char
 *  \return pointer to next array location
 **/
unsigned char* char_to_stream(unsigned char *p, unsigned char u8);

/*==========================================================================*/
/**
 *  Copy short to stream
 *
 *  \param *p    pointer to array location
 *  \param u16   the short
 *  \return pointer to next array location
 **/
unsigned char* short_to_stream(unsigned char *p, unsigned short u16);

/*==========================================================================*/
/**
 *  Copy int to stream
 *
 *  \param *p    pointer to array location
 *  \param u32   the int
 *  \return pointer to next array location
 **/
unsigned char* int_to_stream(unsigned char *p, unsigned int u32);

/*==========================================================================*/
/**
 *  Copy array to stream
 *
 *  \param *p    pointer to array location
 *  \param *a    pointer to the source array location
 *  \param l     copy length
 *  \return pointer to next array location
 **/
unsigned char* array_to_stream(unsigned char *p, unsigned char *a, int l);

/*==========================================================================*/
/**
 *  Extract char from stream
 *
 *  \param *p      pointer to array location
 *  \param offset  offset - TODO: is this required?
 *  \return char
 **/
unsigned char stream_to_char(char* p, unsigned int offset);

/*==========================================================================*/
/**
 *  Extract short from stream
 *
 *  \param *p      pointer to array location
 *  \param offset  offset - TODO: is this required?
 *  \return short
 **/
unsigned short stream_to_short(char* p, unsigned int offset);

/*==========================================================================*/
/**
 *  Extract int from stream
 *
 *  \param *p      pointer to array location
 *  \param offset  offset - TODO: is this required?
 *  \return int
 **/
unsigned int stream_to_int(char* p, unsigned int offset);

#endif // _hci_helper_h_
/*==========================================================================*/
