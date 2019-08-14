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
#include <assert.h>
#include <stdio.h>
#include <ctype.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <stdint.h>
#include <inttypes.h>
#include <fcntl.h>
#include <stdbool.h>
#include <time.h>

#if defined(_WIN32) || defined(_WIN64)
// visual studio does not have these functions
#define snprintf _snprintf
#define vsnprintf _vsnprintf
#define strncasecmp _strnicmp
#define strcasecmp _stricmp
// set limits.h PATH_MAX to windows MAX_PATH
# define PATH_MAX MAX_PATH
// fake STDOUT_FILENO / STDERR_FILENO on windows
#define STDOUT_FILENO 1
#define STDERR_FILENO 2
// fake pid_t
#define pid_t int
// <sys/socket.h> does not define socklen_t
#define socklen_t int
// <sys/types.h> does not define ssize_t
#define ssize_t int
// windows does not have the crypt library
#define NOCRYPT
#else
// unix
#include <unistd.h>
#include <strings.h>  // now required
#include <limits.h>  // for PATH_MAX
# include <sys/uio.h>

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

/* crypt on FreeBSD */
#if defined(__FREEBSD__)
#if !defined(HAVE_UNSAFE_CRYPT)
#define HAVE_UNSAFE_CRYPT 1
#endif
#endif

#ifdef HAVE_ERRNO_H
#include <errno.h>
#endif


#ifdef HAVE_CRYPT_H
#include <crypt.h>
#endif

#if HAVE_SYS_TIME_H
#include <sys/time.h>
#endif

#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
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

/* Guess if we have the getrlimit()/setrlimit() functions */
#if defined(RLIMIT_NOFILE) || defined (RLIMIT_OFILE)
#define HAS_RLIMIT
#if !defined (RLIMIT_NOFILE)
# define RLIMIT_NOFILE RLIMIT_OFILE
#endif
#endif




#endif /* _SYSDEP_H_ */

