#!/bin/bash

# Get variables
OUTPUT=$1
OSMAND_ROOT=../..
OSMAND_JAVA_CORE=$OSMAND_ROOT/core/OsmAnd-java
AVIAN_ARCH=$2
AVIAN_FLAVOR=-$3
if [ "$AVIAN_FLAVOR" == "-fast" ]; then
	AVIAN_FLAVOR=
fi
AVIAN=../../avian/core
AVIAN_BIN=$AVIAN/build/wp8-$AVIAN_ARCH$AVIAN_FLAVOR-bootimage

# Perform actions
if [ "$4" == "build" ]; then
	# Ensure OsmAnd JAVA core is built
	ant -f $OSMAND_JAVA_CORE/build.xml build
	
	# Prepare *.class files
	rm -rf "$OUTPUT/stage"
	mkdir -p "$OUTPUT/stage"
	rm -rf "$OUTPUT/jars"
	mkdir -p "$OUTPUT/jars"
	cp $AVIAN_BIN/host/classpath.jar "$OUTPUT/jars/"
	cp $OSMAND_JAVA_CORE/OsmAnd-avian.jar "$OUTPUT/jars/"
	cp $OSMAND_JAVA_CORE/lib/simple-logging.jar "$OUTPUT/jars/"
	cp $OSMAND_JAVA_CORE/lib/kxml2-2.3.0.jar "$OUTPUT/jars/"
	cp $OSMAND_JAVA_CORE/lib/junidecode-0.1.jar "$OUTPUT/jars/"
	(cd "$OUTPUT/stage" && \
		jar -xf ../jars/classpath.jar && \
		jar -xf ../jars/OsmAnd-avian.jar && \
		jar -xf ../jars/simple-logging.jar && \
		jar -xf ../jars/kxml2-2.3.0.jar && \
		jar -xf ../jars/junidecode-0.1.jar)

	# Collect resources
	rm -rf "$OUTPUT/resources*"
	mkdir -p "$OUTPUT/resources"
	(cd "$OUTPUT/stage" && \
		find . -type f -not -name '*.class' | xargs tar cf - | tar xf - -C ../resources)
	(cd "$OUTPUT/resources" && \
		jar cf ../resources.jar *)

	# Compile resources
	RESOURCES_JAR_NATIVE=`cygpath -w "$OUTPUT/resources.jar"`
	RESOURCES_OBJ_NATIVE=`cygpath -w "$OUTPUT/resources.obj"`
	$AVIAN_BIN/host/binaryToObject/binaryToObject \
		"$RESOURCES_JAR_NATIVE" \
		"$RESOURCES_OBJ_NATIVE" \
		_binary_resources_jar_start _binary_resources_jar_end windows $AVIAN_ARCH 1

	# Precompile code
	rm -f "$OUTPUT/bootimage.obj"
	rm -f "$OUTPUT/codeimage.obj"
	BOOTIMAGE_OBJ_NATIVE=`cygpath -w "$OUTPUT/bootimage.obj"`
	CODEIMAGE_OBJ_NATIVE=`cygpath -w "$OUTPUT/codeimage.obj"`
	STAGE_NATIVE=`cygpath -w "$OUTPUT/stage"`
	$AVIAN_BIN/bootimage-generator \
		-cp "$STAGE_NATIVE" \
		-bootimage "$BOOTIMAGE_OBJ_NATIVE" \
		-codeimage "$CODEIMAGE_OBJ_NATIVE"
fi