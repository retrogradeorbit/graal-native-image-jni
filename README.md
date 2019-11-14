# graal-native-image-jni

### Aim

Try and build the smallest possible JNI example to test GraalVM's native-image JNI support.

### Result

Failure

```
$ LD_LIBRARY_PATH=./ ./helloworld
Exception in thread "main" java.lang.UnsatisfiedLinkError: HelloWorld.print()V [symbol: Java_HelloWorld_print or Java_HelloWorld_print__]
    at com.oracle.svm.jni.access.JNINativeLinkage.getOrFindEntryPoint(JNINativeLinkage.java:145)
    at com.oracle.svm.jni.JNIGeneratedMethodSupport.nativeCallAddress(JNIGeneratedMethodSupport.java:57)
    at HelloWorld.print(HelloWorld.java)
    at HelloWorld.main(HelloWorld.java:10)
```

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
    --static \
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
12674 \
-imagecp \
/home/crispin/graalvm-ce-19.2.1/jre/lib/boot/graaljs-scriptengine.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/boot/graal-sdk.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/svm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/javacpp.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/svm-llvm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/graal-llvm.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/llvm-platform-specific.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/llvm-wrapper.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/objectfile.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/builder/pointsto.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/jvmci-hotspot.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/graal-management.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/jvmci-api.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/jvmci/graal.jar:/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/library-support.jar:/home/crispin/dev/epiccastle/graal-native-image-jni/HelloWorld.jar \
-H:Path=/home/crispin/dev/epiccastle/graal-native-image-jni \
-H:Class=HelloWorld \
-H:+ReportExceptionStackTraces \
-H:ConfigurationFileDirectories=config-dir \
-H:ClassInitialization=:build_time \
-H:FallbackThreshold=0 \
-H:+StaticExecutable \
-H:+TraceClassInitialization \
-H:+PrintClassInitialization \
-H:CLibraryPath=/home/crispin/graalvm-ce-19.2.1/jre/lib/svm/clibraries/linux-amd64 \
-H:Name=helloworld
]
[helloworld:12696]    classlist:   2,278.98 ms
[helloworld:12696]        (cap):   2,047.01 ms
[helloworld:12696]        setup:   3,860.61 ms
[helloworld:12696]   (typeflow):   3,282.54 ms
[helloworld:12696]    (objects):   2,281.07 ms
[helloworld:12696]   (features):     409.02 ms
[helloworld:12696]     analysis:   6,118.63 ms
Printing initializer configuration to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/initializer_configuration_20191114_001123.txt
Printing initializer dependencies to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/initializer_dependencies_20191114_001123.dot
Printing 0 classes that are considered as safe for build-time initialization to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/safe_classes_20191114_001123.txt
Printing 1710 classes of type BUILD_TIME to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/build_time_classes_20191114_001123.txt
Printing 13 classes of type RERUN to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/rerun_classes_20191114_001123.txt
Printing 0 classes of type RUN_TIME to /home/crispin/dev/epiccastle/graal-native-image-jni/reports/run_time_classes_20191114_001123.txt
[helloworld:12696]     (clinit):     290.00 ms
[helloworld:12696]     universe:     698.37 ms
[helloworld:12696]      (parse):     640.49 ms
[helloworld:12696]     (inline):   1,262.75 ms
[helloworld:12696]    (compile):   5,504.10 ms
[helloworld:12696]      compile:   7,949.36 ms
[helloworld:12696]        image:     567.70 ms
[helloworld:12696]        write:     160.26 ms
[helloworld:12696]      [total]:  21,886.25 ms
LD_LIBRARY_PATH=./ ./helloworld
Exception in thread "main" java.lang.UnsatisfiedLinkError: HelloWorld.print()V [symbol: Java_HelloWorld_print or Java_HelloWorld_print__]
    at com.oracle.svm.jni.access.JNINativeLinkage.getOrFindEntryPoint(JNINativeLinkage.java:145)
    at com.oracle.svm.jni.JNIGeneratedMethodSupport.nativeCallAddress(JNIGeneratedMethodSupport.java:57)
    at HelloWorld.print(HelloWorld.java)
    at HelloWorld.main(HelloWorld.java:10)
Makefile:40: recipe for target 'run-native' failed
make: *** [run-native] Error 1
```
