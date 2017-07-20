# Swifty Robot environment
Swift + Android build environment

Swifty Robot environment is a set of tools created to reduce the entrance complexity to the Swift + Android world.

The current version is based on a docker machine containing all the prebuilt binaries and set of scripts needed to start building Swift Packages using SwiftPM, and to deploy them to Android devices and APKs.

To install the environment first make sure you have downloaded Docker, and then run the setup script:

```
curl -sSL http://pick.ly/swiftyrobot/install | bash
```

After that just open a new terminal and run `sr help` to get a list of available commands.

The most important commands are

```
    build - Trigger the build process using the Swift Package Manager
    swiftc - Execute swiftc compiler with Android dependencies include paths and target
    copylibs - Copy Android binaries of Swift libs and dependencies to the specified path
```

Just position yourself in a Swift Package, and run `sr build` to run the build process in with all the params set to produce `armv7-none-linux-androideabi` binaries. Verify the recently created library / executable:

```
$ file .build/debug/exec_test
.build/debug/exec_test: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /system/bin/linker, BuildID[sha1]=fbf4cd026761caf774fe3f76a722d6a523115c6e, not stripped
```

and deploy.

## Next Steps

* A gradle script will be created to integrate the library build process to your build pipeline.
* Step-by-step full examples.
* Fix compatibility issues between Swift and ARMv7 or Android.

## Build it yourself

In case you want to create the Docker image yourself using the last version, clone this repo and run:

```
$ docker build -t swifty-robot-evinronment .
```

This will run the image generation using all the scripts available in `prepare_environment`.

## Reach out

Follow me on twitter: [@gonzalolarralde](https://twitter.com/gonzalolarralde/) happy to answer any question you may have.
