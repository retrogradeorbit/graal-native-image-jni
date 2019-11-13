GRAALVM = $(HOME)/graalvm-ce-19.2.1

clean:
	-rm src/*.class
	-rm src/*.h
	-rm *.jar
	-rm *.so
	-rm helloworld

src/HelloWorld.class: src/HelloWorld.java
	javac src/HelloWorld.java

src/HelloWorld.h: src/HelloWorld.java
	cd src && javah -jni HelloWorld

libHelloWorld.so: src/HelloWorld.h src/HelloWorld.c
	gcc -shared -Wall -Werror -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/linux -o libHelloWorld.so -fPIC src/HelloWorld.c

HelloWorld.jar: src/HelloWorld.class src/manifest.txt
	cd src && jar cfm ../HelloWorld.jar manifest.txt HelloWorld.class

run-jar: HelloWorld.jar libHelloWorld.so
	LD_LIBRARY_PATH=./ java -jar HelloWorld.jar

helloworld: HelloWorld.jar libHelloWorld.so
	$(GRAALVM)/bin/native-image \
		-jar HelloWorld.jar \
		-H:Name=helloworld \
		-H:+ReportExceptionStackTraces \
		-H:ConfigurationFileDirectories=config-dir/ \
		--initialize-at-build-time \
		--verbose \
		--allow-incomplete-classpath \
		--no-fallback \
		--no-server \
		"-J-Xmx1g" \
		-H:+TraceClassInitialization -H:+PrintClassInitialization

run-native: helloworld libHelloWorld.so
	LD_LIBRARY_PATH=./ ./helloworld
