include(CheckLibraryExists)
include(CheckCSourceCompiles)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckPrototypeDefinition)
include(CheckTypeSize)
include(CheckStructHasMember)

# set(CONF_H_GENERATED 0)  # set for debuging

# setup conf file
if(NOT CONF_H_GENERATED)
    if(MSVC)
        # if MSVC use prebuilt conf.h
        message(STATUS "conf.h - using prebuilt file for Visual Studio")
        include(WindowsCache)
    else()
        message(STATUS "conf.h - detecting configuration")

        # PREFLIGHT
        CHECK_INCLUDE_FILES(stdio.h HAVE_STDIO_H)
        if(NOT HAVE_STDIO_H)
            message(ERROR "unable to find stdio.h")
        endif()
        CHECK_INCLUDE_FILES(stdint.h HAVE_STDINT_H)
        if(NOT_HAVE_STDINT_H)
            message(ERROR "unable to find stdint.h")
        endif()

        CHECK_INCLUDE_FILES(sys/types.h HAVE_SYS_TYPES_H)

        # in C11 const should always be defined/work
        set(const 0 CACHE INTERNAL "")

        CHECK_INCLUDE_FILES(sys/wait.h HAVE_SYS_WAIT_H)

        CHECK_FUNCTION_EXISTS(vprintf HAVE_VPRINTF)

        if(NOT HAVE_VPRINTF)
            CHECK_FUNCTION_EXISTS(_doprnt HAVE_DOPRNT)
        else()
            unset(HAVE_DOPRNT)
        endif()

        CHECK_TYPE_SIZE(pid_t HAVE_PID_T)
        if(HAVE_PID_T GREATER_EQUAL 0)
            set(pid_t 0 CACHE INTERNAL "")
        else()
            set(pid_t int CACHE INTERNAL "")
        endif()

        include(TestSignalType)

        CHECK_TYPE_SIZE(size_t HAVE_SIZE_T)
        if(HAVE_SIZE_T GREATER_EQUAL 0)
            set(size_t 0 CACHE INTERNAL "")
        else()
            set(size_t unsigned CACHE INTERNAL "")
        endif()

        # STDC_HEADERS test
        CHECK_INCLUDE_FILES(stdlib.h HAVE_STDLIB_H)
        CHECK_INCLUDE_FILES(stdarg.h HAVE_STDARG_H)
        CHECK_INCLUDE_FILES(string.h HAVE_STRING_H)
        CHECK_INCLUDE_FILES(float.h HAVE_FLOAT_H)
        if((HAVE_STDLIB_H) AND (HAVE_STDARG_H) AND (HAVE_STRING_H) AND (HAVE_FLOAT_H))
            set(STDC_HEADERS 1 CACHE INTERNAL "")
        endif()

        CHECK_INCLUDE_FILES("sys/time.h;time.h" TIME_WITH_SYS_TIME)

        # CIRCLE_UNIX / CIRCLE_WINDOWS
        if(WIN32)
            set(CIRCLE_UNIX 0 CACHE INTERNAL "")
            set(CIRCLE_WINDOWS 1 CACHE INTERNAL "")
        else()
            set(CIRCLE_UNIX 1 CACHE INTERNAL "")
            set(CIRCLE_WINDOWS 0 CACHE INTERNAL "")
        endif()

        # CIRCLE_CRYPT test
        CHECK_FUNCTION_EXISTS(crypt HAVE_CRYPT)
        CHECK_LIBRARY_EXISTS(crypt crypt "" HAVE_CRYPT_LIB)

        # CIRCLE_CRYPT
        if(HAVE_CRYPT OR HAVE_CRYPT_LIB)
            set(CIRCLE_CRYPT 1 CACHE INTERNAL "")
        else()
            unset(CIRCLE_CRYPT CACHE INTERNAL "")
        endif()

        # TODO HAVE_UNSAFE_CRYPT

        # TODO - broken on windows - need to find headers
        CHECK_STRUCT_HAS_MEMBER("struct in_addr" s_addr "netinet/in.h" HAVE_STRUCT_IN_ADDR)

        # TODO - retest on windows - probably still broken
        set(CMAKE_EXTRA_INCLUDE_FILES ${CMAKE_EXTRA_INCLUDE_FILES} sys/socket.h)
        CHECK_TYPE_SIZE(socklen_t SOCKLEN_T_SIZE)
        if(SOCKLEN_T_SIZE GREATER_EQUAL 0)
            set(socklen_t 0 CACHE INTERNAL "")
        else()
            set(socklen_t unsigned CACHE INTERNAL "")
        endif()
        set(CMAKE_EXTRA_INCLUDE_FILES "")

        CHECK_TYPE_SIZE(ssize_t HAVE_SSIZE_T)
        if(HAVE_SSIZE_T GREATER_EQUAL 0)
            set(ssize_t 0 CACHE INTERNAL "")
        else()
            set(ssize_t int CACHE INTERNAL "")
        endif()

        CHECK_FUNCTION_EXISTS(gettimeofday HAVE_GETTIMEOFDAY)  # TODO -lnsl
        CHECK_FUNCTION_EXISTS(inet_addr HAVE_INET_ADDR)
        CHECK_FUNCTION_EXISTS(inet_aton HAVE_INET_ATON)
        CHECK_FUNCTION_EXISTS(select HAVE_SELECT)
        CHECK_FUNCTION_EXISTS(snprintf HAVE_SNPRINTF)
        CHECK_FUNCTION_EXISTS(strcasecmp HAVE_STRCASECMP)
        CHECK_FUNCTION_EXISTS(strdup HAVE_STRDUP)
        CHECK_FUNCTION_EXISTS(strerror HAVE_STRERROR)
        CHECK_FUNCTION_EXISTS(stricmp HAVE_STRICMP)
        CHECK_FUNCTION_EXISTS(strlcpy HAVE_STRLCPY)
        CHECK_FUNCTION_EXISTS(strncasecmp HAVE_STRNCASECMP)
        CHECK_FUNCTION_EXISTS(strnicmp HAVE_STRNICMP)
        CHECK_FUNCTION_EXISTS(strstr HAVE_STRSTR)
        CHECK_FUNCTION_EXISTS(vsnprintf HAVE_VSNPRINTF)

        CHECK_INCLUDE_FILES(arpa/inet.h HAVE_ARPA_INET_H)
        CHECK_INCLUDE_FILES(arpa/telnet.h HAVE_ARPA_TELNET_H)
        CHECK_INCLUDE_FILES(assert.h HAVE_ASSERT_H)
        CHECK_INCLUDE_FILES(crypt.h HAVE_CRYPT_H)
        CHECK_INCLUDE_FILES(errno.h HAVE_ERRNO_H)
        CHECK_INCLUDE_FILES(fcntl.h HAVE_FCNTL_H)
        CHECK_INCLUDE_FILES(limits.h HAVE_LIMITS_H)
        CHECK_INCLUDE_FILES(mcheck.h HAVE_MCHECK_H)
        CHECK_INCLUDE_FILES(memory.h HAVE_MEMORY_H)
        CHECK_INCLUDE_FILES(net/errno.h HAVE_NET_ERRNO_H)
        CHECK_INCLUDE_FILES(netdb.h HAVE_NETDB_H)
        CHECK_INCLUDE_FILES(netinet/in.h HAVE_NETINET_IN_H)
        CHECK_INCLUDE_FILES(signal.h HAVE_SIGNAL_H)
        CHECK_INCLUDE_FILES(string.h HAVE_STRING_H)
        CHECK_INCLUDE_FILES(strings.h HAVE_STRINGS_H)
        CHECK_INCLUDE_FILES(sys/fcntl.h HAVE_SYS_FCNTL_H)
        CHECK_INCLUDE_FILES(sys/resource.h HAVE_SYS_RESOURCE_H)
        CHECK_INCLUDE_FILES(sys/select.h HAVE_SYS_SELECT_H)
        CHECK_INCLUDE_FILES(sys/socket.h HAVE_SYS_SOCKET_H)
        CHECK_INCLUDE_FILES(sys/stat.h HAVE_SYS_STAT_H)
        CHECK_INCLUDE_FILES(sys/time.h HAVE_SYS_TIME_H)
        CHECK_INCLUDE_FILES(sys/types.h HAVE_SYS_TYPES_H)
        CHECK_INCLUDE_FILES(sys/uio.h HAVE_SYS_UIO_H)
        CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)

        # TODO HAVE_LIBMALLOC -lmalloc
        # malloc library seems to be solaris related?
        # it is also possibly available on macOS?
        #   (apple has "barrowed" enough solaris code it would not surprise me)
        FIND_LIBRARY(HAVE_LIBMALLOC malloc)
        message(STATUS "HAVE_LIBMALLOC: ${HAVE_LIBMALLOC}")

        # NEED_ACCEPT_PROTO
        check_prototype_definition(accept
                "int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)"
                "-1"
                "sys/types.h;sys/socket.h"
                HAVE_ACCEPT_PROTO
                )
        if(HAVE_ACCEPT_PROTO)
            set(NEED_ACCEPT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_ACCEPT_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_ATOI_PROTO
        check_prototype_definition(atoi
                "int atoi(const char *str)"
                "-1"
                "stdlib.h;string.h"
                HAVE_ATOI_PROTO
                )
        if(HAVE_ATOI_PROTO)
            set(NEED_ATOI_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_ATOI_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_ATOL_PROTO
        check_prototype_definition(atol
                "long int atol(const char *str)"
                "-1"
                "stdlib.h;string.h"
                HAVE_ATOL_PROTO)
        if(HAVE_ATOL_PROTO)
            set(NEED_ATOL_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_ATOL_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_BIND_PROTO
        check_prototype_definition(bind
                "int bind(int sockfd, const struct sockaddr *addr, socklen_t addlen)"
                "-1"
                "sys/types.h;sys/socket.h"
                HAVE_BIND_PROTO)
        if(HAVE_BIND_PROTO)
            set(NEED_BIND_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_BIND_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_BZERO_PROTO
        check_prototype_definition(bzero
                "void bzero(void *s, size_t n)"
                ""  # void return
                "stdio.h;strings.h"
                HAVE_BZERO_PROTO)
        if(HAVE_BZERO_PROTO)
            set(NEED_BZERO_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_BZERO_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_CHDIR_PROTO
        check_prototype_definition(chdir
                "int chdir(const char *path)"
                "-1"
                "unistd.h"
                HAVE_CHDIR_PROTO)
        if(HAVE_CHDIR_PROTO)
            set(NEED_BZERO_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_BZERO_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_CLOSE_PROTO
        check_prototype_definition(close
                "int close(int fd)"
                "-1"
                "unistd.h"
                HAVE_CLOSE_PROTO)
        if(HAVE_CLOSE_PROTO)
            set(NEED_CLOSE_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_CLOSE_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_CRYPT_PROTO - TODO check, need -lcrypt ?
        check_prototype_definition(crypt
                "char *crypt(const char *key, const char *salt)"
                "-1"
                "unistd.h"
                HAVE_CRYPT_PROTO)
        if(HAVE_CRYPT_PROTO)
            set(NEED_CRYPT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_CRYPT_PROTO 1 CACHE INTERNAL "")
        endif()
        # TODO - override, test needs work
        set(NEED_CRYPT_PROTO 0 CACHE INTERNAL "")

        # NEED_FCLOSE_PROTO
        check_prototype_definition(fclose
                "int fclose(FILE *stream)"
                "-1"
                "stdio.h"
                HAVE_FCLOSE_PROTO)
        if(HAVE_FCLOSE_PROTO)
            set(NEED_FCLOSE_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FCLOSE_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FCNTL_PROTO
        check_prototype_definition(fcntl
                "int fcntl(int fildes, int cmd, ...)"
                "-1"
                "unistd.h;fcntl.h"
                HAVE_FCNTL_PROTO)
        if(HAVE_FCNTL_PROTO)
            set(NEED_FCNTL_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FCNTL_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FFLUSH_PROTO
        check_prototype_definition(fflush
                "int fflush(FILE *stream)"
                "-1"
                "stdio.h"
                HAVE_FFLUSH_PROTO)
        if(HAVE_FFLUSH_PROTO)
            set(NEED_FFLUSH_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FFLUSH_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FPRINTF_PROTO
        check_prototype_definition(fprintf
                "int fprintf(FILE *stream, const char *format, ...)"
                "-1"
                "stdio.h"
                HAVE_FPRINTF_PROTO)
        if(HAVE_FPRINTF_PROTO)
            set(NEED_FPRINTF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FPRINTF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FPUTC_PROTO
        check_prototype_definition(fputc
                "int fputc(int c, FILE *stream)"
                "-1"
                "stdio.h"
                HAVE_FPUTC_PROTO)
        if(HAVE_FPUTC_PROTO)
            set(NEED_FPUTC_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FPUTC_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FPUTS_PROTO
        check_prototype_definition(fputs
                "int fputs(const char *s, FILE *stream)"
                "-1"
                "stdio.h"
                HAVE_FPUTS_PROTO)
        if(HAVE_FPUTS_PROTO)
            set(NEED_FPUTS_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FPUTS_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FREAD_PROTO
        check_prototype_definition(fread
                "size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream)"
                "0"
                "stdio.h"
                HAVE_FREAD_PROTO)
        if(HAVE_FREAD_PROTO)
            set(NEED_FREAD_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FREAD_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FSCANF_PROTO
        check_prototype_definition(fscanf
                "int fscanf(FILE *stream, const char *format, ...)"
                "-1"
                "stdio.h"
                HAVE_FSCANF_PROTO)
        if(HAVE_FSCANF_PROTO)
            set(NEED_FSCANF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FSCANF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FSEEK_PROTO
        check_prototype_definition(fseek
                "int fseek(FILE *stream, long offset, int whence)"
                "-1"
                "stdio.h"
                HAVE_FSEEK_PROTO)
        if(HAVE_FSEEK_PROTO)
            set(NEED_FSEEK_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FSEEK_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FWRITE_PROTO
        check_prototype_definition(fwrite
                "size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)"
                "0"
                "stdio.h"
                HAVE_FWRITE_PROTO)
        if(HAVE_FWRITE_PROTO)
            set(NEED_FWRITE_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FWRITE_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_GETPEERNAME_PROTO
        check_prototype_definition(getpeername
                "int getpeername(int sockfd, struct sockaddr *addr, socklen_t *addrlen)"
                "-1"
                "sys/socket.h"
                HAVE_GETPEERNAME_PROTO)
        if(HAVE_GETPEERNAME_PROTO)
            set(NEED_GETPEERNAME_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_GETPEERNAME_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_GETPID_PROTO
        check_prototype_definition(getpid
                "pid_t getpid(void)"
                "-1"
                "sys/types.h;unistd.h"
                HAVE_GETPID_PROTO)
        if(HAVE_GETPID_PROTO)
            set(NEED_GETPID_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_GETPID_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_GETRLIMIT_PROTO
        check_prototype_definition(getrlimit
                "int getrlimit(int resource, struct rlimit *rlim)"
                "-1"
                "sys/time.h;sys/resource.h"
                HAVE_GETRLIMIT_PROTO)
        if(HAVE_GETRLIMIT_PROTO)
            set(NEED_GETRLIMIT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_GETRLIMIT_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_GETSOCKNAME_PROTO
        check_prototype_definition(getsockname
                "int getsockname(int sockfd, struct sockaddr *addr, socklen_t *addrlen)"
                "-1"
                "sys/socket.h"
                HAVE_GETSOCKNAME_PROTO)
        if(HAVE_GETSOCKNAME_PROTO)
            set(NEED_GETSOCKNAME_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_GETSOCKNAME_PROTO 0 CACHE INTERNAL "")
        endif()

        # NEED_GETTIMEOFDAY_PROTO
        check_prototype_definition(gettimeofday
                "int gettimeofday(struct timeval *tv, struct timezone *tz)"
                "-1"
                "sys/time.h"
                HAVE_GETTIMEOFDAY_PROTO)
        if(HAVE_GETTIMEOFDAY_PROTO)
            set(NEED_GETTIMEOFDAY_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_GETTIMEOFDAY_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_HTONL_PROTO
        check_prototype_definition(htonl
                "uint32_t htonl(uint32_t hostlong)"
                "-1"
                "arpa/inet.h"
                HAVE_HTONL_PROTO)
        if(HAVE_HTONL_PROTO)
            set(NEED_HTONL_PROTO 0 CACHE INTERNAL "")
        else()
            # FreeBSD defines HTONL using a macro
            check_symbol_exists(htonl "arpa/inet.h" HAVE_HTONL_SYMBOL)
            if(HAVE_HTONL_SYMBOL)
                set(NEED_HTONL_PROTO 0 CACHE INTERNAL "")
            else()
                set(NEED_HTONL_PROTO 1 CACHE INTERNAL "")
            endif()
        endif()

        # NEED_HTONS_PROTO
        check_prototype_definition(htons
                "uint16_t htons(uint16_t hostshort)"
                "-1"
                "arpa/inet.h"
                HAVE_HTONS_PROTO)
        if(HAVE_HTONS_PROTO)
            set(NEED_HTONS_PROTO 0 CACHE INTERNAL "")
        else()
            check_symbol_exists(htons "arpa/inet.h" HAVE_HTONS_SYMBOL)
            if(HAVE_HTONS_SYMBOL)
                set(NEED_HTONS_PROTO 0 CACHE INTERNAL "")
            else()
                set(NEED_HTONS_PROTO 1 CACHE INTERNAL "")
            endif()
        endif()

        # NEED_INET_ADDR_PROTO
        check_prototype_definition(inet_addr
                "in_addr_t inet_addr(const char *cp)"
                "-1"
                "sys/socket.h;arpa/inet.h"
                HAVE_INET_ADDR_PROTO)
        if(HAVE_INET_ADDR_PROTO)
            set(NEED_INET_ADDR_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_INET_ADDR_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_INET_ATON_PROTO
        check_prototype_definition(inet_aton
                "int inet_aton(const char *cp, struct in_addr *inp)"
                "-1"
                "sys/socket.h;arpa/inet.h"
                HAVE_INET_ATON_PROTO)
        if(HAVE_INET_ATON_PROTO)
            set(NEED_INET_ATON_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_INET_ATON_PROTO 1 CACHE INTERNAL "")
        endif()



        # NEED_STRICMP_PROTO
        check_prototype_definition(stricmp
                "int stricmp (const char *s1, const char *s2)"
                "-1"
                "stdio.h;string.h"
                HAVE_STRICMP_PROTO)
        if(HAVE_STRICMP_PROTO)
            set(NEED_STRICMP_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_STRICMP_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_STRLCPY_PROTO - FreeBSD -lc
        check_prototype_definition(strlcpy
                "size_t strlcpy(char * restrict dst, const	char * restrict	src, size_t dstsize)"
                "0"
                "string.h"
                HAVE_STRLCPY_PROTO)
        if(HAVE_STRLCPY_PROTO)
            set(NEED_STRLCPY_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_STRLCPY_PROTO 1 CACHE INTERNAL "")
        endif()




        # "int gettimeofday(struct timeval *tv, struct timezone *tz)"
        check_prototype_definition(gettimeofday
                "int gettimeofday(struct timeval *tv, struct timezone *tz)"
                "-1"
                "sys/time.h"
                HAVE_GETTIMEOFDAY_PROTO)

        message(STATUS "PROTO detection is still incomplete")
        if(UNIX AND NOT APPLE)
            message(STATUS "PROTO override Linux")
            set(NEED_STRICMP_PROTO 1)
            # set(NEED_STRLCPY_PROTO 1)
            set(NEED_STRNICMP_PROTO 1)
        endif()

    endif()

    # write conf.h
    configure_file(
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h.cmakein"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h"
    )

    # check that it worked
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h")
        message(STATUS "conf.h generated")
        set(CONF_H_GENERATED 1 CACHE BOOL "conf.h built, set variable 0/OFF to rebuild")
    else()
        message(ERROR "conf.h failed")
    endif()
else()
    message(STATUS "conf.h already built")
endif()
