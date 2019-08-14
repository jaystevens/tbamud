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

/* Configurables: tbaMUD uses the crypt(3) function to encrypt player passwords
 * in the players file so that they are never stored in plaintext form. However,
 * due to U.S. export restrictions on machine-readable cryptographic software, 
 * the crypt() function is not available on some operating systems such as 
 * FreeBSD.  By default, the 'configure' script will determine if you have 
 * crypt() available and enable or disable password encryption appropriately.  
 * #define NOCRYPT (by uncommenting the line below) if you'd like to explicitly
 * disable password encryption (i.e., if you have moved your MUD from an OS that
 * does not support encryption to one that does). */
/* #define NOCRYPT */

/* If you are porting tbaMUD to a new (untested) platform and you find that 
 * POSIX-standard non-blocking I/O does *not* work, you can define the constant
 * below to work around the problem.  Not having non-blocking I/O can cause the
 * MUD to freeze if someone types part of a command while the MUD waits for the
 * remainder of the command.
 *
 * NOTE: **DO** **NOT** use this constant unless you are SURE you understand
 * exactly what non-blocking I/O is, and you are SURE that your operating system
 * does NOT have it!  (The only UNIX system I've ever seen that has broken POSIX
 * non-blocking I/O is AIX 3.2.)  If your MUD is freezing but you're not sure 
 * why, do NOT use this constant.  Use this constant ONLY if you're sure that 
 * your MUD is freezing because of a non-blocking I/O problem. */
/* #define POSIX_NONBLOCK_BROKEN */

/* The code prototypes library functions to avoid compiler warnings. (Operating
 * system header files *should* do this, but sometimes don't.) However, Circle's
 * prototypes cause the compilation to fail under some combinations of operating
 * systems and compilers. If your compiler reports "conflicting types" for 
 * functions, you need to define this constant to turn off library function 
 * prototyping.  Note, **DO** **NOT** blindly turn on this constant unless you 
 * are sure the problem is type conflicts between my header files and the header
 * files of your operating system.  The error message will look something like
 * this: In file included from comm.c:14:
 *    sysdep.h:207: conflicting types for `random'
 * /usr/local/lib/gcc-lib/alpha-dec-osf3.2/2.7.2/include/stdlib.h:253:
 *    previous declaration of `random' */
/* #define NO_LIBRARY_PROTOTYPES */

/* If using the GNU C library, version 2+, then you can have it trace memory 
 * allocations to check for leaks, uninitialized uses, and bogus free() calls.
 * To see if your version supports it, run:
 * info libc 'Allocation Debugging' 'Tracing malloc'
 * Example usage (Bourne shell):
 *      MALLOC_TRACE=/tmp/circle-trace bin/circle
 * Read the entire "Allocation Debugging" section of the GNU C library
 * documentation before setting this to '1'. */
#define CIRCLE_GNU_LIBC_MEMORY_TRACK    0    /* 0 = off, 1 = on */

/* Do not change anything below this line. */

/* Set up various machine-specific things based on the values determined from 
 * configure and conf.h. */

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

#ifdef _WIN32
// visual studio
#include <x>
#include <x>
#else
// unix
#include <unistd.h>
#include <limits.h>

#ifdef _POSIX_VERSION
#define POSIX
#endif

#include <signal.h>

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

#ifdef HAVE_SIGNAL_H
# ifndef _POSIX_C_SOURCE
#  define _POSIX_C_SOURCE 2
#  include <signal.h>
#  undef _POSIX_C_SOURCE
# else

    /* GNU libc 6 already defines _POSIX_C_SOURCE. */

# endif
#endif

#ifdef HAVE_SYS_UIO_H
# include <sys/uio.h>
#endif

#ifdef HAVE_SYS_STAT_H
# include <sys/stat.h>
#endif

#if !defined(__GNUC__)
# define __attribute__(x)	/* nothing */
#endif

/* Socket/header miscellany. */

#if defined(CIRCLE_WINDOWS)    /* Definitions for Win32 */

# define snprintf _snprintf
# define vsnprintf _vsnprintf
# define PATH_MAX MAX_PATH

# ifndef _WINSOCK2API_	/* Winsock1 and Winsock 2 conflict. */
#  include <winsock.h>
# endif

# ifndef FD_SETSIZE	/* MSVC 6 is reported to have 64. */
#  define FD_SETSIZE		1024
# endif

#endif /* CIRCLE_WINDOWS */

#if !defined(CIRCLE_UNIX) && !defined(CIRCLE_WINDOWS)
# error "You forgot to include conf.h or do not have a valid system define."
#endif

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


/* Function prototypes. */
/* Header files of many OS's do not contain function prototypes for the
 * standard C library functions.  This produces annoying warning messages 
 * (sometimes, a lot of them) on such OS's when compiling with gcc's -Wall.
 *
 * Configuration script has been changed to detect which prototypes exist 
 * already; this header file only prototypes functions that aren't already 
 * prototyped by the system headers.  A clash should be impossible.  This 
 * should give us our strong type-checking back. */

#ifndef NO_LIBRARY_PROTOTYPES

#ifndef HAVE_STRLCPY_PROTO
size_t strlcpy(char *dest, const char *src, size_t copylen);
#endif

#endif /* NO_LIBRARY_PROTOTYPES */

#endif /* _SYSDEP_H_ */

