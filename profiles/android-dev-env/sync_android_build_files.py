# flake8: noqa
# Added above comment to bypass build issue with linting.
# See: https://github.com/NixOS/nixpkgs/issues/269811
import re
import sys
from pathlib import Path
import shutil


def log_info(msg):
    print(f"ℹ️  {msg}")


def log_success(msg):
    print(f"✅ {msg}")


def log_warn(msg):
    print(f"⚠️  {msg}")


def edit_file_if_exists(file_path, pattern, repl, description):
    path = Path(file_path)
    log_info(f"{description}: {file_path}")

    if not path.is_file():
        log_warn(f"File not found: {file_path}")
        return

    backup_path = path.with_suffix(path.suffix + ".bak")
    shutil.copyfile(path, backup_path)

    content = path.read_text()
    new_content, count = re.subn(pattern, repl, content)

    if count > 0:
        path.write_text(new_content)
        log_success(f"{description} succeeded for {file_path}")
    else:
        log_warn(f"No matches found in {file_path} for {description}")


def update_compile_sdk_version(android_dir, version):
    file = Path(android_dir) / "app" / "build.gradle.kts"
    # Updated pattern to match leading whitespace and update the version
    pattern = r"(compileSdk\s*=\s*)[^\n]+"

    def replacer(match):
        return match.group(1) + str(version)

    edit_file_if_exists(file, pattern, replacer, "Updating compileSdkVersion")


def update_agp_version(android_dir, version):
    file = Path(android_dir) / "settings.gradle.kts"
    # Pattern for replacing AGP version
    pattern = (
        r'(id\(["\']com\.android\.application["\']\)\s+version\s+)["\'][^"\']+["\']'
    )
    repl = r'\1"' + version + '"'
    edit_file_if_exists(file, pattern, repl, "Updating Android Gradle Plugin version")


def replace_gradlew_with_wrapper(android_dir, gradle_wrapper):
    gradlew_path = Path(android_dir) / "gradlew"
    log_info("Replacing gradlew with gradle-wrapper...")

    if gradlew_path.is_file():
        backup_path = gradlew_path.with_suffix(".bak")
        gradlew_path.rename(backup_path)
        gradlew_path.symlink_to(gradle_wrapper, target_is_directory=True)
        log_success("Replaced gradlew with gradle-wrapper")
    else:
        log_warn(f"File not found: {gradlew_path}")


def main():
    if len(sys.argv) != 5:
        print(
            "Usage: sync-android-build-files <androidDir> <compileSdkVersion> <androidGradlePluginVersion> <gradleWrapper>"
        )
        sys.exit(1)

    android_dir = sys.argv[1]
    compile_sdk_version = sys.argv[2]
    agp_version = sys.argv[3]
    gradle_wrapper = sys.argv[4]

    replace_gradlew_with_wrapper(android_dir, gradle_wrapper)

    if compile_sdk_version:
        update_compile_sdk_version(android_dir, compile_sdk_version)
    else:
        print(
            f"Did not update compileSdk version. Invalid version provided: {compile_sdk_version}"
        )

    if agp_version:
        update_agp_version(android_dir, agp_version)
    else:
        print(
            f"Did not update AGP version. Invalid version provided: {compile_sdk_version}"
        )

    # TODO update ndk.version in `gradle.properties` file
    # - append line if it doesn't exist


if __name__ == "__main__":
    main()
