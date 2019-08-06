include(CheckLibraryExists)
include(CheckCSourceCompiles)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckPrototypeDefinition)
include(CheckTypeSize)
include(CheckStructHasMember)

# setup conf file
if(MSVC)
    # if MSVC use prebuilt conf.h
    configure_file(
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h.msvc"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h"
    )
else()
    # PREFLIGHT
    CHECK_INCLUDE_FILES(sys/types.h HAVE_SYS_TYPES_H)

    # TODO #define const

    CHECK_INCLUDE_FILES(sys/wait.h HAVE_SYS_WAIT_H)

    CHECK_FUNCTION_EXISTS(vprintf, HAVE_VPRINTF)
    # TODO - VPRINTF fails
    set(HAVE_VPRINTF 1)

    if(NOT HAVE_VPRINTF)
        CHECK_FUNCTION_EXISTS(_doprnt HAVE_DOPRNT)
    else()
        unset(HAVE_DOPRNT)
    endif()

    CHECK_TYPE_SIZE(pid_t HAVE_PID_T)
    if(HAVE_PID_T GREATER_EQUAL 0)
        message("-- pid_t - found")
        set(pid_t 0)
    else()
        message("-- pid_t - not found")
        set(pid_t int)
    endif()

    include(TestSignalType)

    CHECK_TYPE_SIZE(size_t HAVE_SIZE_T)
    if(HAVE_SIZE_T GREATER_EQUAL 0)
        message("-- size_t - found")
        set(size_t 0)
    else()
        message("-- size_t - not found")
        set(size_t unsigned)
    endif()

    # STDC_HEADERS test
    CHECK_INCLUDE_FILES(stdlib.h HAVE_STDLIB_H)
    CHECK_INCLUDE_FILES(stdarg.h HAVE_STDARG_H)
    CHECK_INCLUDE_FILES(string.h HAVE_STRING_H)
    CHECK_INCLUDE_FILES(float.h HAVE_FLOAT_H)
    if((HAVE_STDLIB_H) AND (HAVE_STDARG_H) AND (HAVE_STRING_H) AND (HAVE_FLOAT_H))
        set(STDC_HEADERS 1)
    endif()

    CHECK_INCLUDE_FILES("sys/time.h;time.h" TIME_WITH_SYS_TIME)

    if(NOT WIN32)
        set(CIRCLE_UNIX 1)
    endif()

    # CIRCLE_CRYPT test
    CHECK_FUNCTION_EXISTS(crypt HAVE_CRYPT)
    CHECK_LIBRARY_EXISTS(crypt crypt "" HAVE_CRYPT_LIB)

    # CIRCLE_CRYPT
    if(HAVE_CRYPT OR HAVE_CRYPT_LIB)
        set(CIRCLE_CRYPT 1)
    else()
        unset(CIRCLE_CRYPT)
    endif()

    # TODO HAVE_UNSAFE_CRYPT

    CHECK_STRUCT_HAS_MEMBER("struct in_addr" s_addr "netinet/in.h" HAVE_STRUCT_IN_ADDR)

    # TODO - includes for HAVE_SOCKLEN
    CHECK_TYPE_SIZE(socklen_t HAVE_SOCKLEN_T)
    if(HAVE_SOCKLEN_T GREATER_EQUAL 0)
        message("-- socklen_t - found")
        set(socklen_t 0)
    else()
        message("-- socklen_t - not found")
        set(socklen_t unsigned)
    endif()
    message("socklen_t test broken, JAM value")
    set(socklen_t 0)

    CHECK_TYPE_SIZE(ssize_t HAVE_SSIZE_T)
    if(HAVE_SSIZE_T GREATER_EQUAL 0)
        message("-- ssize_t - found")
        set(ssize_t 0)
    else()
        message("-- ssize_t - not found")
        set(ssize_t int)
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

    # make conf.h before we check prototypes
    configure_file(
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h.cmakein"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h"
    )

    # NEED_ACCEPT_PROTO
    check_prototype_definition(
            accept
            "void accept(int a, char b, int c, char d, int e, char f, int g, char h);"
            "-1"
            "sys/socket.h"
            NEED_ACCEPT_PROTO
    )

    # NEED_ATOI_PROTO
    check_prototype_definition(
            atoi
            "void atoi(int a, char b, int c, char d, int e, char f, int g, char h);"
            "-1"
            "string.h"
            NEED_ATOI_PROTO
    )

    # "int gettimeofday(struct timeval *tv, struct timezone *tz)"
    check_prototype_definition(
            gettimeofday
            "void gettimeofday(int a, char b, int c, char d, int e, char f, int g, char h);"
            "-1"
            "sys/time.h"
            HAVE_GETTIMEOFDAY_TZ)

    message("HAVE_GETTIMEOFDAY_TZ: ${HAVE_GETTIMEOFDAY_TZ}")

    message("JAM NEED PROTO")
    set(NEED_STRICMP_PROTO 1)
    set(NEED_STRLCPY_PROTO 1)
    set(NEED_STRNICMP_PROTO 1)



    configure_file(
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h.cmakein"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h"
    )
endif()