include(CheckLibraryExists)
include(CheckCSourceCompiles)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckPrototypeDefinition)
include(CheckTypeSize)
include(CheckStructHasMember)

#set(CONF_H_GENERATED 0)  # set for debuging

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

        CHECK_INCLUDE_FILES(sys/types.h HAVE_SYS_TYPES_H)

        # in C11 const should always be defined/work
        set(const 0)

        CHECK_INCLUDE_FILES(sys/wait.h HAVE_SYS_WAIT_H)

        CHECK_FUNCTION_EXISTS(vprintf HAVE_VPRINTF)

        if(NOT HAVE_VPRINTF)
            CHECK_FUNCTION_EXISTS(_doprnt HAVE_DOPRNT)
        else()
            unset(HAVE_DOPRNT)
        endif()

        CHECK_TYPE_SIZE(pid_t HAVE_PID_T)
        if(HAVE_PID_T GREATER_EQUAL 0)
            set(pid_t 0)
        else()
            set(pid_t int)
        endif()

        include(TestSignalType)

        CHECK_TYPE_SIZE(size_t HAVE_SIZE_T)
        if(HAVE_SIZE_T GREATER_EQUAL 0)
            set(size_t 0)
        else()
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

        # CIRCLE_UNIX / CIRCLE_WINDOWS
        if(WIN32)
            set(CIRCLE_UNIX 0)
            set(CIRCLE_WINDOWS 1)
        else()
            set(CIRCLE_UNIX 1)
            set(CIRCLE_WINDOWS 0)
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

        # TODO - broken on windows - need to find headers
        CHECK_STRUCT_HAS_MEMBER("struct in_addr" s_addr "netinet/in.h" HAVE_STRUCT_IN_ADDR)

        # TODO - retest on windows - probably still broken
        set(CMAKE_EXTRA_INCLUDE_FILES ${CMAKE_EXTRA_INCLUDE_FILES} sys/socket.h)
        CHECK_TYPE_SIZE(socklen_t SOCKLEN_T_SIZE)
        if(SOCKLEN_T_SIZE GREATER_EQUAL 0)
            set(socklen_t 0)
        else()
            set(socklen_t unsigned)
        endif()
        set(CMAKE_EXTRA_INCLUDE_FILES "")

        CHECK_TYPE_SIZE(ssize_t HAVE_SSIZE_T)
        if(HAVE_SSIZE_T GREATER_EQUAL 0)
            set(ssize_t 0)
        else()
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
            set(NEED_ACCEPT_PROTO 0)
        else()
            set(NEED_ACCEPT_PROTO 1)
        endif()

        # NEED_ATOI_PROTO
        check_prototype_definition(atoi
                "int atoi(const char *str)"
                "-1"
                "stdlib.h;string.h"
                HAVE_ATOI_PROTO
        )
        if(HAVE_ATOI_PROTO)
            set(NEED_ATOI_PROTO 0)
        else()
            set(NEED_ATOI_PROTO 1)
        endif()

        # NEED_ATOL_PROTO
        check_prototype_definition(atol
                ""
                "-1"
                ".h"
                HAVE_ATOL_PROTO)
        if(HAVE_ATOL_PROTO)
            set(NEED_ATOL_PROTO 0)
        else()
            set(NEED_ATOL_PROTO 1)
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
            set(NEED_STRLCPY_PROTO 1)
            set(NEED_STRNICMP_PROTO 1)
        else()
            message(STATUS "PROTO override macOS - TODO")
        endif()

        configure_file(
                "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h.cmakein"
                "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h"
        )
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