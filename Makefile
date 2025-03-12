SHELL := bash

ROOT=$(shell pwd)

# TODO Test GraalVM Community Edition
#   https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-22.0.2/graalvm-community-jdk-22.0.2_linux-x64_bin.tar.gz)

GRAALVM_NAME := graalvm-jdk-23_linux-x64_bin
GRAALVM_TAR := $(GRAALVM_NAME).tar.gz
GRAALVM_LINUX_X86_REPO := \
  https://download.oracle.com/graalvm/23/latest/$(GRAALVM_TAR)
GRAALVM_HOME := $(ROOT)/graalvm-jdk-23.0.2+7.1

export JAVA_HOME := $(GRAALVM_HOME)
export PATH := $(ROOT):$(JAVA_HOME)/bin:$(PATH)
export LD_LIBRARY_PATH := $(ROOT)/lib

NAME := HelloWorld
name := helloworld
APP  := $(name)
JAR  := $(NAME).jar
VER  := 1.2.3
LIB  := lib/lib$(name).$(VER).so


default:

test: build test-jar test-native

build: $(GRAALVM_HOME) $(LIB) $(APP)
	@echo

test-jar: $(JAR) $(LIB)
	@echo '*** Testing $@'
	java -jar $<
	@echo

test-native: $(APP) $(LIB)
	@echo '*** Testing $@'
	$<
	@echo

clean:
	$(RM) src/*.class src/*.h $(JAR) $(LIB) $(APP)
	$(RM) helloworld-build-report.html
	$(RM) -r reports bin lib target

realclean: clean
	$(RM) $(GRAALVM_TAR)
	$(RM) -r $(GRAALVM_HOME)

ifeq (1,$(USE_NATIVE_OPTS))
NATIVE_OPTS := \
  --verbose \
  --native-image-info \
  --no-fallback \
  --initialize-at-build-time \
  --enable-preview \
  --enable-url-protocols=https \
  -march=compatibility \
  -H:ReflectionConfigurationFiles=reflection.json \
  -H:+ReportExceptionStackTraces \
  -H:+PrintClassInitialization \
  -H:Log=registerResource: \
  "-J-Xmx3g"
endif

# Using none of the options above (or using all of them) both seem to work as
# of March 2025.

$(APP): $(JAR)
	native-image $(NATIVE_OPTS) -jar $< -o $@

$(JAR): $(GRAALVM_HOME) src/$(NAME).class src/manifest.txt
	cd src && jar cfm ../$@ manifest.txt $(NAME).class

src/%.class: src/%.java
	javac $<

$(LIB): src/$(NAME).c src/$(NAME).h
	mkdir -p lib
	gcc -shared -Wall -Werror \
		-I$(JAVA_HOME)/include \
		-I$(JAVA_HOME)/include/linux \
		-o $@ \
		-fPIC \
		$<

src/%.h: src/%.java
	cd src && javac -h $(PWD)/src $(<:src/%=%)

$(GRAALVM_HOME): $(GRAALVM_TAR)
	tar xf $<

$(GRAALVM_TAR):
	curl -sSL -o $@ $(GRAALVM_LINUX_X86_REPO)
