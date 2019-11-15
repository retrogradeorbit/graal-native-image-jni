# graal-native-image-jni

### Aim

Try and build the smallest possible JNI example to test GraalVM's native-image JNI support.

### Result

Success.

```
$ ./helloworld
Hello world; this is C talking!
```

### Insight

In order for native-image to successfuly load a c library to execute, it must run the `System.loadLibrary()` call at runtime, not at build time.

### Method 1: Put loadLibrary in the execution path

This is the version we have done. By putting loadLibrary inside the `main` method, the library is loaded at run time. With this setup we can compile with `--initialize-at-build-time` and everything will work.

### Method 2: Put loadLibraru in static class initializer and use --initialize-at-run-time

Sometimes you don't have control over where you call loadLibrary from. Often existing code places it in the slasses static initializer block. In this case the library is loaded at build time, but then when the final artifact is run, the linked code cannot be found and the programme crashes with a `java.lang.UnsatisfiedLinkError` exception.

When you place the loadLibrary call within a static block of a class, you must specify to `native-image` that your class should be initialized at runtime.

## Requirements

 * Linux
 * GraalVM CE 19.2.1 with native-image tool installed
 * Working GNU C compiler

## Overview

`HelloWorld.java` contains HelloWorld class, that calls the native code in `HelloWorld.c` to print output.

`HelloWorld.c` compiles into `libHelloWorld.so`

`HelloWorld.class` is built into a jar with a simple manifest.

## Build and run a JNI jar

```
$ make run-jar
javac src/HelloWorld.java
cd src && jar cfm ../HelloWorld.jar manifest.txt HelloWorld.class
cd src && javah -jni HelloWorld
gcc -shared -Wall -Werror -I/usr/lib/jvm/java-8-oracle/include -I/usr/lib/jvm/java-8-oracle/include/linux -o libHelloWorld.so -fPIC src/HelloWorld.c
LD_LIBRARY_PATH=./ java -jar HelloWorld.jar
Hello world; this is C talking!
```

## Build and run a native image

(you can specify a custom GRAALVM path with `make run-native GRAALVM=/path/to/my/graalvm`)

```
$ make run-native
/home/crispin/graalvm-ce-19.2.1/bin/native-image \
    -jar HelloWorld.jar \
    -H:Name=helloworld \
    -H:+ReportExceptionStackTraces \
    -H:ConfigurationFileDirectories=config-dir \
    --initialize-at-build-time \
    --verbose \
    --no-fallback \
    --no-server \
    "-J-Xmx1g" \
    -H:+TraceClassInitialization -H:+PrintClassInitialization
Executing [
/home/crispin/graalvm-ce-19.2.1/jre/bin/java \
-XX:+UnlockExperimentalVMOptions \
-XX:+EnableJVMCI \
-Dtruffle.TrustAllTruffleRuntimeProviders=true \
-Dtruffle.TruffleRuntime=com.oracle.truffle.api.impl.DefaultTruffleRuntime \
-Dgraalvm.ForcePolyglotInvalid=true \
-Dgraalvm.locatorDisabled=true \
-d64 \
-XX:-UseJVMCIClassLoader \
-XX:+UseJVMCINativeLibrary \
-Xss10m \
-Xms1g \
-Xmx14g \
-Duser.country=US \
-Duser.language=en \
-Dorg.graalvm.version=19.2.1 \
-Dorg.graalvm.config=CE \
-Dcom.oracle.graalvm.isaot=true \
-Djvmci.class.path.append=/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/graal.jar \
-javaagent:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/svm.jar \
-Xmx1g \
-Xbootclasspath/a:/home/crispin/graalvm-ce-19.2.1/jre/lib/boot/graaljs-scriptengine.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/boot/graal-sdk.jar \
-cp \
/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/svm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/javacpp.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/svm-llvm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/graal-llvm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/llvm-platform-specific.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/llvm-wrapper.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/objectfile.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/pointsto.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/jvmci-hotspot.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/graal-management.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/jvmci-api.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/graal.jar \
com.oracle.svm.hosted.NativeImageGeneratorRunner \
-watchpid \
10964 \
-imagecp \
/home/crispin/graalvm-ce-19.2.1/jre/lib/boot/graaljs-scriptengine.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/boot/graal-sdk.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/svm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/javacpp.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/svm-llvm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/graal-llvm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/llvm-platform-specific.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/llvm-wrapper.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/objectfile.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/pointsto.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/jvmci-hotspot.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/graal-management.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/jvmci-api.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/graal.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/library-support.jar:/home/crispin/dev/epiccastle/graal-native-image-jni/HelloWorld.jar \
-H:Path=/home/crispin/dev/epiccastle/graal-native-image-jni \
-H:Class=HelloWorld \
-H:+ReportExceptionStackTraces \
-H:ConfigurationFileDirectories=config-dir \
-H:ClassInitialization=:build_time \
-H:FallbackThreshold=0 \
-H:+TraceClassInitialization \
-H:+PrintClassInitialization \
-H:CLibraryPath=/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/clibraries/linux-amd64 \
-H:Name=helloworld
]
[helloworld:10986]    classlist:   1,616.92 ms
[helloworld:10986]        (cap):   1,526.85 ms
[helloworld:10986]        setup:   2,825.72 ms
[helloworld:10986]   (typeflow):   5,943.24 ms
[helloworld:10986]    (objects):   4,215.63 ms
[helloworld:10986]   (features):     329.14 ms
[helloworld:10986]     analysis:  10,674.16 ms
Printing initializer configuration to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/initializer_configuration_20191115_205814.txt
Printing initializer dependencies to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/initializer_dependencies_20191115_205814.dot
Printing 0 classes that are considered as safe for build-time initialization to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/safe_classes_20191115_205814.txt
Printing 2599 classes of type BUILD_TIME to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/build_time_classes_20191115_205814.txt
Printing 13 classes of type RERUN to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/rerun_classes_20191115_205814.txt
Printing 0 classes of type RUN_TIME to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/run_time_classes_20191115_205814.txt
[helloworld:10986]     (clinit):     225.64 ms
[helloworld:10986]     universe:     593.86 ms
[helloworld:10986]      (parse):     896.34 ms
[helloworld:10986]     (inline):   1,534.65 ms
[helloworld:10986]    (compile):   7,715.71 ms
[helloworld:10986]      compile:  10,785.92 ms
[helloworld:10986]        image:     920.97 ms
[helloworld:10986]        write:     123.24 ms
[helloworld:10986]      [total]:  27,737.71 ms
LD_LIBRARY_PATH=./ ./helloworld
Hello world; this is C talking!
```
