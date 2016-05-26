from conans import ConanFile
from conans.tools import download, unzip
import os

VERSION = "0.0.3"


class SanitizeTargetCMakeConan(ConanFile):
    name = "sanitize-target-cmake"
    version = os.environ.get("CONAN_VERSION_OVERRIDE", VERSION)
    generators = "cmake"
    requires = ("cmake-include-guard/master@smspillaz/cmake-include-guard",
                "cmake-multi-targets/master@smspillaz/cmake-multi-targets",
                "tooling-cmake-util/master@smspillaz/tooling-cmake-util",
                "sanitizers-cmake/0.0.1@smspillaz/sanitizers-cmake")
    url = "http://github.com/polysquare/sanitize-target-cmake"
    license = "MIT"
    options = {
        "dev": [True, False]
    }
    default_options = "dev=False"

    def requirements(self):
        if self.options.dev:
            self.requires("cmake-module-common/master@smspillaz/cmake-module-common")

    def source(self):
        zip_name = "sanitize-target-cmake.zip"
        download("https://github.com/polysquare/"
                 "sanitize-target-cmake/archive/{version}.zip"
                 "".format(version="v" + VERSION),
                 zip_name)
        unzip(zip_name)
        os.unlink(zip_name)

    def package(self):
        self.copy(pattern="*.cmake",
                  dst="cmake/sanitize-target-cmake",
                  src="sanitize-target-cmake-" + VERSION,
                  keep_path=True)
