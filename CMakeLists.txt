# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.10)

# do not let cmake cache run in <project>/ folder
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR
        "In-source builds are not permitted. Make a separate folder for building:\n"
        "mkdir build; cd build; cmake ..\n"
        "Before that, remove the files already created:\n"
        "rm -rf CMakeCache.txt CMakeFiles")
endif()
# do not let cmake cache run in <project>/src/ folder
if("${CMAKE_SOURCE_DIR}/src" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR
            "In-source builds are not permitted. Make a separate folder for building:\n"
            "mkdir build; cd build; cmake ..\n"
            "Before that, remove the files already created:\n"
            "rm -rf CMakeCache.txt CMakeFiles")
endif()

# Visual Studio project generator x64 check
if(MSVC)
    if(CMAKE_GENERATOR MATCHES ".*Visual Studio.*")
        if(NOT CMAKE_GENERATOR_PLATFORM MATCHES "x64")
            message(FATAL_ERROR "\nVisual Studio x86 builds are not supported\nrebuild cmake cache with '-A x64'")
        endif()
    endif()
endif()

# if no build type specified default to release
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release"
            CACHE "Build type: Debug, Release, RelWithDebInfo or MinSizeRel" STRING FORCE)
endif()

# append cmake/modules to MAKE_MODULE_PATH variable
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

project("tbamud" LANGUAGES C)

# setup version number
include(GetGitRevisionDescription)
git_describe(VERSION)
if(VERSION MATCHES "-128-NOTFOUND")
    set(VERSION "v0.0-0-gmissing")
endif()
if (VERSION MATCHES "HEAD-HASH-NOTFOUND")
    set(VERSION "v0.0-0-gmissing")
endif()
message("git version   : ${VERSION}")
string(REGEX REPLACE "^v([0-9]+)\\..*" "\\1" VERSION_MAJOR "${VERSION}")
string(REGEX REPLACE "^v[0-9]+\\.([0-9]+).*" "\\1" VERSION_MINOR "${VERSION}")
string(REGEX REPLACE "^v[0-9]+\\.[0-9]+\\-([0-9]+)-.*" "\\1" VERSION_PATCH "${VERSION}")
set(VERSION_TWEAK 0)
string(REGEX REPLACE "^v[0-9]+\\.[0-9]+\\-[0-9]+-(.*)" "\\1" VERSION_SHA1 "${VERSION}")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_TWEAK}")
set(VERSION_FULL "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_TWEAK} ${VERSION_SHA1}")
message("version       :  ${VERSION}")
message("version full  :  ${VERSION_FULL}")
cmake_host_system_information(RESULT BUILD_HOST QUERY HOSTNAME)

# setup version number in application
configure_file (
        "${CMAKE_CURRENT_SOURCE_DIR}/src/version.c.in"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/version.c"
)

# options
option(MARCH_NATIVE "use march=native for GCC" ON)

# compiler flags
include(compiler_flags)
if(MSVC)
    add_definitions(-DUNICODE -D_UNICODE) # Visual Studio - force unicode over multi-byte
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)  # Visual Studio - turn off use secure functions
    # Disable MSVC warnings that suggest making code non-portable.
    #add_compiler_flag_if_supported("/wd4996")
    add_definitions("/wd4996")
    add_definitions("/favor:INTEL64")  # Visual Studio - favor intel cpu, only works with 64 bit
else()
    # require_c_flag("-std=c11" YES)
    # these are from my ffmpeg build (fftools/config.mak)
    add_c_flag_if_supported("-fomit-frame-pointer")
    add_c_flag_if_supported("-fPIE")
    # compiler warnings
    add_c_flag_if_supported("-Wall")
    add_c_flag_if_supported("-Wextra")
    add_c_flag_if_supported("-Wdeclaration-after-statement")
    add_c_flag_if_supported("-Wdisabled-optimization")
    add_c_flag_if_supported("-Wpointer-arith")
    add_c_flag_if_supported("-Wredundant-decls")
    add_c_flag_if_supported("-Wwrite-strings")
    add_c_flag_if_supported("-Wtype-limits")
    add_c_flag_if_supported("-Wundef")
    add_c_flag_if_supported("-Wmissing-prototypes")
    add_c_flag_if_supported("-Wno-pointer-to-int-cast")
    add_c_flag_if_supported("-Wstrict-prototypes")
    add_c_flag_if_supported("-Wempty-body")
    add_c_flag_if_supported("-Wno-parentheses")
    add_c_flag_if_supported("-Wno-switch")
    add_c_flag_if_supported("-Wno-format-zero-length")
    add_c_flag_if_supported("-Wno-pointer-sign")
    add_c_flag_if_supported("-fno-math-errno")
    add_c_flag_if_supported("-fno-signed-zeros")
    add_c_flag_if_supported("-fno-tree-vectorize")
    add_c_flag_if_supported("-Werror=format-security")
    add_c_flag_if_supported("-Werror=implicit-function-declaration")
    #add_c_flag_if_supported("-Werror=missing-prototypes")
    add_c_flag_if_supported("-Werror=return-types")
    # add direct, does not support test?
    append_c_flag("-Werror=vla")
    add_c_flag_if_supported("-Wformat")
    add_c_flag_if_supported("-fdiagnostics-color=auto")
    add_c_flag_if_supported("-Wno-maybe-uninitialized")
    # fixup
    #add_c_flag_if_supported("-Wno-undef")
    #add_c_flag_if_supported("-Wno-unknown-pragmas")

    # build statc if not MSVC not on MacOS
    #if(NOT APPLE)
    #    add_c_flag_if_supported("-static")
    #    add_c_flag_if_supported("-static-libgcc")
    #endif()

    add_c_flag_if_supported("-Wno-unused-parameter")  # disable unused parameter otherwise GCC is very verbosey

    # tbamud options from old configure
    add_c_flag_if_supported("-g")  # enable debug
    add_c_flag_if_supported("-Wno-char-subscripts")  # disable gcc warning about arrays
    add_c_flag_if_supported("-fno-builtin")  # disable builtin

    if(MARCH_NATIVE)
        add_c_flag_if_supported("-march=native")
    endif()
endif()


#if ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
#    if (MSVC)
#        # Maximum optimization in Release mode.
#        add_compile_options("$<$<CONFIG:RELEASE>:/Ox>")
#    else ()
#        add_c_flag_if_supported("-O3")
#    endif ()
#endif ()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${QTTOOLS_C_FLAGS}")

# setup runtime folder
#set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

# include directory required for making utils that refernce source headers
include_directories("${CMAKE_SOURCE_DIR}/src")

include(ConfigureChecks)

# link libraries
#list(LINK_LIBS "")
if(MSVC)
    # requires wsock32 library on windows
    #target_link_libraries(circle wsock32.lib)
    list(APPEND LINK_LIBS wsock32.lib)
else()
    if(HAVE_CRYPT_LIB)
        #target_link_libraries(circle crypt)
        list(APPEND LINK_LIBS crypt)
    endif()
endif()

add_executable(circle
        "src/act_comm.c"
        "src/act_informative.c"
        "src/act_item.c"
        "src/act_movement.c"
        "src/act_offensive.c"
        "src/act_other.c"
        "src/act_social.c"
        "src/act_wizard.c"
        "src/olc_social_aedit.c"
        "src/asciimap.c"
        "src/ban.c"
        "src/boards.c"
        "src/bsd-snprintf.c"
        "src/zone_spec_castle.c"
        "src/olc_cfg_cedit.c"
        "src/class.c"
        "src/comm.c"
        "src/config.c"
        "src/constants.c"
        "src/db.c"
        "src/dg_comm.c"
        "src/dg_db_scripts.c"
        "src/dg_event.c"
        "src/dg_handler.c"
        "src/dg_misc.c"
        "src/dg_mobcmd.c"
        "src/dg_objcmd.c"
        "src/dg_olc.c"
        "src/dg_scripts.c"
        "src/dg_triggers.c"
        "src/dg_variables.c"
        "src/dg_wldcmd.c"
        "src/fight.c"
        "src/genmob.c"
        "src/genobj.c"
        "src/genolc.c"
        "src/genqst.c"
        "src/genshp.c"
        "src/genwld.c"
        "src/genzon.c"
        "src/graph.c"
        "src/handler.c"
        "src/olc_help_hedit.c"
        "src/house.c"
        "src/ibt.c"
        "src/improved-edit.c"
        "src/interpreter.c"
        "src/limits.c"
        "src/lists.c"
        "src/magic.c"
        "src/mail.c"
        "src/olc_mob_medit.c"
        "src/mobact.c"
        "src/modify.c"
        "src/olc_msg_msgedit.c"
        "src/mud_event.c"
        "src/oasis.c"
        "src/oasis_copy.c"
        "src/oasis_delete.c"
        "src/oasis_list.c"
        "src/objsave.c"
        "src/olc_obj_oedit.c"
        "src/players.c"
        "src/prefedit.c"
        "src/protocol.c"
        "src/olc_quest_qedit.c"
        "src/quest.c"
        "src/random.c"
        "src/olc_room_redit.c"
        "src/olc_shop_sedit.c"
        "src/shop.c"
        "src/spec_assign.c"
        "src/spec_procs.c"
        "src/spell_parser.c"
        "src/spells.c"
        "src/olc_text_tedit.c"
        "src/utils.c"
        "src/version.c"
        "src/weather.c"
        "src/olc_zone_zedit.c"
        "src/zmalloc.c")
set_target_properties(circle PROPERTIES C_STANDARD_REQUIRED ON)
set_target_properties(circle PROPERTIES C_STANDARD 11)
set_target_properties(circle PROPERTIES C_EXTENSIONS ON)

target_link_libraries(circle ${LINK_LIBS})

# utils - TOOD fix - broken path include
#add_executable(asciipasswd "src/util/asciipasswd.c")
#target_link_libraries(asciipasswd ${LINK_LIBS})

#add_executable(autowiz "src/util/autowiz.c")
#target_link_libraries(autowiz ${LINK_LIBS})

#add_executable(plrtoascii "src/util/plrtoascii.c")
#target_link_libraries(plrtoascii ${LINK_LIBS})

if(NOT MSVC)
    # TODO - rebuildIndex requires <dent.h> not available on windows
    #add_executable(rebuildIndex "src/util/rebuildAsciiIndex.c")
    #target_link_libraries(rebuildIndex ${LINK_LIBS})
endif()

if(NOT MSVC)
    # TODO - rebuildMailIndex requires <dent.h> not available on windows
    #add_executable(rebuildMailIndex "src/util/rebuildMailIndex.c")
    #target_link_libraries(rebuildMailIndex ${LINK_LIBS})
endif()

#add_executable(shopconv "src/util/shopconv.c")
#target_link_libraries(shopconv ${LINK_LIBS})

if(NOT MSVC)
    # TODO - sign does not compile on windows
    #add_executable(sign "src/util/sign.c")
    #target_link_libraries(sign ${LINK_LIBS})
endif()

#add_executable(split "src/util/split.c")
#target_link_libraries(split ${LINK_LIBS})

if(NOT MSVC)
    # TODO - wld2html does not compile on windows
    #add_executable(wld2html "src/util/wld2html.c")
    #target_link_libraries(wld2html ${LINK_LIBS})
endif()

if(NOT MSVC)
    # TODO - webster does not compile on windows
    #add_executable(webster "src/util/webster.c")
    #target_link_libraries(webster ${LINK_LIBS})
endif()


# install directives
if(WIN32)
    set(__CPACK_INSTALL_DEST "/")
else()
    set(__CPACK_INSTALL_DEST "")
endif()
install(TARGETS circle RUNTIME DESTINATION ${__CPACK_INSTALL_DEST} COMPONENT tbamud)

# Configure CPack
set(CPACK_PACKAGE_NAME "tbamud")
set(CPACK_PACKAGE_VENDOR "tbamud")
#set(CPACK_PACKAGE_DIRECTORY "")
set(CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH})
set(CPACK_PACKAGE_DESCRIPTION "TBA MUD")
#set(CPACK_PACKAGE_DESCRIPTION_FILE "")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "mud stuff")
set(CPACK_PACKAGE_HOMEPAGE_URL "")
#set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_SYSTEM_NAME}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "tbamud")  # for installer
#set(CPACK_PACKAGE_ICON "")
set(CPACK_PACKAGE_CHECKSUM "SHA256") # MD5/SHA1/SHA224/SHA256/SHA384/SHA512/SHA3_224/SHA3_256/SHA3_384/SHA3_512
#set(CPACK_RESOURCE_FILE_LICENSE "")  # used by installer
#set(CPACK_RESOURCE_FILE_README "")
#set(CPACK_RESOURCE_FILE_WELCOME "")
set(CPACK_MONOLITHIC_INSTALL TRUE)
set(CPACK_COMPONENTS_ALL_IN_ONE_PACKAGE 1)
# cpack output, see cpack --help
if(UNIX)
    set(CPACK_GENERATOR TXZ)
else()
    set(CPACK_GENERATOR ZIP)
endif()
#set(CPACK_PACKAGE_EXECUTABLES "fkoder;FKoder")  # start menu shortcuts
if(WIN32)
else()
    set(CPACK_STRIP_FILES TRUE)  # strip all files
endif()

# Source pack
#set(CPACK_SOURCE_PACKAGE_FILE_NAME "fkoder-")
#set(CPACK_SOURCE_STRIP_FILES FALSE)
#set(CPACK_SOURCE_GENERATOR TXZ)
#set(CPACK_SOURCE_IGNORE_FILES "/\\.idea/;/\\.vs/;;")

# Adv
set(CPACK_PACKAGE_VERSION ${VERSION})
include(CPack)

#message("Supported features = ${CMAKE_CXX_COMPILE_FEATURES}")
#message("Supported features = ${CMAKE_C_COMPILE_FEATURES}")
