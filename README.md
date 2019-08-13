# tbaMudx #


mud server based on circle 3.0 / diku / tbaMud

## TODO

- CMake

  - port configure NEED_X_PROTO detection to cmake

    - mostly done 2019-08-12

    - 

- Improvements:

  - add command `spells`
  - add command `slist` - skills list
  - fix cast spell holy symbol `'`
  - prompt - prompt sucks, make more flexible
  - rework happy_hour into something nice
  - echo - wiz command ? use ?

- clean up old tools
  - autowiz ?
  - are index rebuild tools still needed/useful/work properly?

- broken:

  - autoeq is borked by type conversion
  - zonereset is borked
  - copyover on windows looks borked, turned it off on windows for now, probably not worth fixing.

- fix compiler warnings:

  - -Wconstant-conversion - fix bad type conversions
  - -Wconversion - fix type type conversions
  - -Wformat - printf / snprintf  safety warnings
  - ~~const char*~~ - no warnings as of 2018-08-12, but needs further improvements
  - ~~duplicate defines~~
  - ~~iso C90 variable declaration~~
  - ~~unused variable (warning disabled today, it is very verbose)~~

- Enhancements:

  - move main() out of comm.c into circle.c
  - change from argv options to argparse.c based
  - AUTOMAP - easier to read overhead automap
  - SIGHUP/SIGTERM - does not behave the same as `shutdown`
  - TELNET code
    - for current telnet code - add a protocol negotiation command / overrides
    - for current telnet code - try to improve speed of protocol negotiation
    - evaluate if libtelnet is better than the current telnet swiss cheese
    - add telnet over SSL/TLS (mbed TLS / openSLL / wolfSSL)
    - add ssh support (wolfSSH)
  - PASSWORD - add pbkdf2 password encryption (mbed TLS / openSSL / wolfSSL)

- Completed:

  - ~~cleanup #ifdef for AMIGA / ACORN / OS2 / VMS~~
  - ~~cleanup #ifdef for CIRCLE_OS_X and CIRCLE_MACINTOSH~~
  - ~~test cmake detection on windows / move windows IAC out of conf.h.msvc~~

## Requirements ##

- requires cmake 3.10 or newer
- requires C compiler with C11 support

## Tested Compilers / Environments ##

- Centos 7 - GCC 4.8.5 / GCC 9.2.0
- MS Visual Studio 2019 [compile test only] (should also compile with 2017)
- macOS Mojave - 14.4.5 [compile test only]
- FreeBSD 12.0-p9 clang / gcc 8.3.0 [compile test only]