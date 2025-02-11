#!/bin/sh

PROJECT_PATH_DIR=$1
PROJECT_NAME=$2

if [ -z "$PROJECT_PATH_DIR" ]
then
echo ""
echo "Provide project dir"
echo ""
else

if [ -z "$PROJECT_NAME" ]
then
echo ""
echo "Provide project name"
echo ""
else

CURR_DIR=$(pwd)
PROJECT_PATH=${CURR_DIR}/${PROJECT_PATH_DIR}
BUILD_DIR=${PROJECT_PATH}/BUILD_DIR
CONFIGURATION="Release"

UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-Universal

#Create all related dirs
echo "Сreate all related dirs ${BUILD_DIR}"

rm    -rf "${BUILD_DIR}"
mkdir -p  "${UNIVERSAL_OUTPUTFOLDER}"

#build for simulator
echo "Build for simulator"

xcodebuild -workspace "${PROJECT_PATH}/${PROJECT_NAME}.xcworkspace" \
-scheme "${PROJECT_NAME}" \
-configuration Debug \
-sdk iphonesimulator \
ONLY_ACTIVE_ARCH=NO \
BUILD_DIR="${BUILD_DIR}" \
clean build 

#build for device
echo "Build for device"

xcodebuild -workspace "${PROJECT_PATH}/${PROJECT_NAME}.xcworkspace" \
-scheme "${PROJECT_NAME}" \
-configuration  "${CONFIGURATION}" \
-sdk iphoneos \
ONLY_ACTIVE_ARCH=NO \
BUILD_DIR="${BUILD_DIR}" \
clean build 

#Copy the framework structure (from iphoneos build) to the universal folder
echo "Copy the framework structure (from iphoneos build) to the universal folder"

cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

#Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
echo "Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory"

cp -R "${BUILD_DIR}/Debug-iphonesimulator/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/." \
"${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"

#Create universal binary file using lipo and place the combined executable in the copied framework directory
echo "Create universal binary file using lipo and place the combined executable in the copied framework directory"

lipo -create -output \
"${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" \
"${BUILD_DIR}/Debug-iphonesimulator/${PROJECT_NAME}.framework/${PROJECT_NAME}" \
"${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework/${PROJECT_NAME}"

#Copy the framework to the project's directory
echo "Copy the framework to the project's directory"

cp -R -a "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework" "${CURR_DIR}"

#cleanup build dir
echo "cleanup build dir"

rm -rf "${BUILD_DIR}"

fi
fi
