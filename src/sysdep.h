/**
* @file sysdep.h
* Machine-specific defs based on values in conf.h (from configure)
* 
* Part of the core tbaMUD source code distribution, which is a derivative
* of, and continuation of, CircleMUD.
*                                                                        
* All rights reserved.  See license for complete information.                                                                
* Copyright (C) 1993, 94 by the Trustees of the Johns Hopkins University 
* CircleMUD is based on DikuMUD, Copyright (C) 1990, 1991.               
*/
#ifndef _SYSDEP_H_
#define _SYSDEP_H_


/* uncomment to disable crypt() and use plaintext passwords */
// #define NOCRYPT


// generic C11 includes
#include <stdio.h>
#include <ctype.h>
#include <stdarg.h>
#include <string.h>  // now required
#include <strings.h>  // now required
#include <stdlib.h>  // now required
#include <sys/types.h>
#include <stdint.h>
#include <assert.h>

#if defined(_WIN32) || defined(_WIN64)
// visual studio does not have these functions
#define snprintf _snprintf
#define vsnprintf _vsnprintf
#define strncasecmp _strnicmp
#define strcasecmp _stricmp
// mimic limits.h
# define PATH_MAX MAX_PATH
#else
// unix
#include <unistd.h>
#include <limits.h>

#ifdef _POSIX_VERSION
#define POSIX
#endif

#include <signal.h>
#include <sys/stat.h>

#endif


/* strlcpy */
#if defined(__APPLE__) || defined(__FREEBSD__)
/* macOS and FreeBSD have strlcpy prototype */
#else
size_t strlcpy(char *dest, const char *src, size_t copylen);
#endif

#ifdef HAVE_ERRNO_H
#include <errno.h>
#endif

#ifdef HAVE_SYS_ERRNO_H
#include <sys/errno.h>
#endif

#ifdef HAVE_CRYPT_H
#include <crypt.h>
#endif

#ifdef TIME_WITH_SYS_TIME

# include <sys/time.h>
# include <time.h>

#else
# if HAVE_SYS_TIME_H
#  include <sys/time.h>
# else
#  include <time.h>
# endif
#endif




#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif

#ifdef HAVE_SYS_FCNTL_H
#include <sys/fcntl.h>
#endif

#ifdef HAVE_SYS_SOCKET_H
# include <sys/socket.h>
#endif

#ifdef HAVE_SYS_RESOURCE_H
# include <sys/resource.h>
#endif

#ifdef HAVE_SYS_WAIT_H
# include <sys/wait.h>
#endif

#ifdef HAVE_NETINET_IN_H
# include <netinet/in.h>
#endif

#ifdef HAVE_ARPA_INET_H
# include <arpa/inet.h>
#endif

#ifdef HAVE_NETDB_H
# include <netdb.h>
#endif

#ifdef HAVE_SYS_UIO_H
# include <sys/uio.h>
#endif

#ifdef HAVE_SYS_STAT_H

#endif

#if !defined(__GNUC__)
# define __attribute__(x)	/* nothing */
#endif

/* Socket/header miscellany. */

#if defined(CIRCLE_WINDOWS)    /* Definitions for Win32 */


# ifndef _WINSOCK2API_	/* Winsock1 and Winsock 2 conflict. */
#  include <winsock.h>
# endif

/* MSVC defaults to 64 (so say the old documentation)
 * this is used with select()
 * should really move away from select...
 */
#ifndef FD_SETSIZE
#define FD_SETSIZE 1024
#endif

#endif /* CIRCLE_WINDOWS */

/* SOCKET -- must be after the winsock.h #include. */
#ifdef CIRCLE_WINDOWS
# define CLOSE_SOCKET(sock)	closesocket(sock)
typedef SOCKET		socket_t;
#else
# define CLOSE_SOCKET(sock)    close(sock)
typedef int socket_t;
#endif

#if defined(__cplusplus)    /* C++ */
#define cpp_extern	extern
#else				/* C */
#define cpp_extern    /* Nothing */
#endif

/* Guess if we have the getrlimit()/setrlimit() functions */
#if defined(RLIMIT_NOFILE) || defined (RLIMIT_OFILE)
#define HAS_RLIMIT
#if !defined (RLIMIT_NOFILE)
# define RLIMIT_NOFILE RLIMIT_OFILE
#endif
#endif




#endif /* _SYSDEP_H_ */

