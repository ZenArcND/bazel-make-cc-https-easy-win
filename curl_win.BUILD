cc_import(
    name = "curl-lib",
    static_library = "lib/libcurl.a"
)

cc_library(
    name = "curl-headers",
    hdrs = glob(["include/curl/*.h"]),
    includes = ["include"]
)

cc_library(
    name = "curl",
    deps = [
        ":curl-lib",
        ":curl-headers"
    ],
    visibility = ["//visibility:public"],
)