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
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned char* char_to_stream(unsigned char *p, unsigned char u8);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned char* short_to_stream(unsigned char *p, unsigned short u16);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned char* int_to_stream(unsigned char *p, unsigned int u32);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned char* array_to_stream(unsigned char *p, unsigned char *a, int l);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned char stream_to_char(char* p, unsigned int offset);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned short stream_to_short(char* p, unsigned int offset);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned int stream_to_int(char* p, unsigned int offset);

#endif // _hci_helper_h_
/*==========================================================================*/
