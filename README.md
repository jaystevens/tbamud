# tbaMud+ #


mud server based on circle 3.0 / diku / tbaMud

## TODO

- cleanup #ifdef for AMIGA / ACORN / OS2 / VMS
- cleanup #ifdef for CIRCLE_OS_X and CIRCLE_MACINTOSH
- port configure NEED_X_PROTO detection to cmake
- test cmake detection on windows / move windows IAC out of conf.h.msvc
- SIGHUP/SIGTERM cleaner shutdown
- missing spells command
- fix cast spell holy symbol ''
- better automap
- protocol negotiation command
- move main() out of comm.c into circle.c
- change from argv options to argparse.c based
- clean up old tools
  - autowiz ?
  - are index rebuild tools still needed/useful/work properly?
- fix compiler warnings
  - const char*
  - duplicate defines
  - iso C90 variable declaration
  - unused variable (warning disabled today, it is very verbose)
- Mud Improvements:
  - prompt - act_other: do_display sucks
  - rework xpmulti - i.e. happy_hour
  - echo - wiz command ? use ?
- Future Improvements
  - ssh support (looking at wolfSSL/wolfSSH)
  - move away from gcrypt (possibly wolfSSL pbkdf2, or openssl pbkdf2, allow linux static linking of exe)

## Requirements ##

- requires cmake 3.10 or newer
- requires C compiler with C11 support

## Tested Compilers / Environments ##

- GCC - Centos 7 - 4.8.5
- MS Visual Studio 2017
- MS Visual Studio 2019
- macOS Mojave - 14.4.5