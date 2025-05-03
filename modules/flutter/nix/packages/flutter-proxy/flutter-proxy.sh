#!/usr/bin/env bash

# Check if the first argument is "create"
if [[ "$1" == "create" && -n "$2" ]]; then
  PROJECT_NAME="$2"

  # Optionally override compileSdkVersion if passed as an argument (default: 34)
  COMPILE_SDK_VERSION="${3:-34}"

  # Run flutter create with additional arguments
  shift 2  # Remove "create" and "$PROJECT_NAME" from the arguments list
  flutter create "$PROJECT_NAME" "$@" || {
    echo "❌ Flutter project creation failed."
    exit 1
  }

  cd "$PROJECT_NAME/android" || exit 1

  # Inject flutter.compileSdkVersion into local.properties (if not already there)
  grep -q '^flutter.compileSdkVersion=' local.properties || echo -e "\nflutter.compileSdkVersion=$COMPILE_SDK_VERSION" >> local.properties
  echo "✅ Added flutter.compileSdkVersion=$COMPILE_SDK_VERSION to android/local.properties"

  # Define GRADLE_FILE path to app/build.gradle
  GRADLE_FILE="./app/build.gradle"  # Correct path to app's build.gradle

  # Replace flutter.compileSdkVersion with compileSdkVersion in app/build.gradle
  sed -i.bak 's/flutter\.compileSdkVersion/compileSdkVersion/g' "$GRADLE_FILE"
  echo "✅ Updated compileSdkVersion reference in $GRADLE_FILE"

  # Inject Gradle code into android/build.gradle to read flutter.compileSdkVersion
  cp "$GRADLE_FILE" "$GRADLE_FILE.bak"

  awk '
  BEGIN { in_plugins=0; inserted=0 }
  {
    print $0
    if ($0 ~ /^plugins\s*{/) { in_plugins=1 }
    if (in_plugins && $0 ~ /^}/ && !inserted) {
      print ""
      print "// Injected: Load flutter.compileSdkVersion from local.properties"
      print "def localProperties = new Properties()"
      print "def localPropertiesFile = rootProject.file(\"local.properties\")"
      print "if (localPropertiesFile.exists()) {"
      print "    localPropertiesFile.withInputStream { stream -> localProperties.load(stream) }"
      print "}"
      print "def compileSdkVersion = localProperties.getProperty(\"flutter.compileSdkVersion\")?.toInteger()"
      print "if (compileSdkVersion == null) {"
      print "    throw new GradleException(\"flutter.compileSdkVersion is not specified in local.properties or is invalid.\")"
      print "}"
      inserted=1
      in_plugins=0
    }
  }' "$GRADLE_FILE.bak" > "$GRADLE_FILE"

  echo "✅ Injected compileSdkVersion loader into $GRADLE_FILE"
  echo "🎉 Flutter project '$PROJECT_NAME' created and patched successfully."

else
  # Forward any other command to flutter directly
  flutter "$@"
fi

