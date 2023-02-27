# Do not change the filename; it is part of the user interface.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@com_github_nelhage_rules_boost//:boost/boost.bzl", "boost_deps")

def hedron_make_cc_https_easy():
    """Setup a WORKSPACE so you can easily make https requests from C++.

    Ensures you have CPR, whose interface you want to use...
    ... and its dependencies: curl and boringssl.
    """

    # Unified setup for users' WORKSPACES and this workspace when used standalone.
    # See invocations in:
    #     README.md (for users)
    #     WORKSPACE (for working on this repo standalone)

    maybe(
        http_archive,
        name = "cpr",
        patches = ["@hedron_make_cc_https_easy//:cpr.patch"], # Minor. Just removes version-define header from unbrella header <cpr/cpr.h>, since it's generated by cmake and we don't need it. If needed, could hack it in like https://github.com/curoky/tame/blob/c8926a2cd569848137ebb971a95057cb117055c3/recipes/c/cpr/default/BUILD
        build_file = "@hedron_make_cc_https_easy//:cpr.BUILD",
        url = "https://github.com/cpsauer/cpr/archive/a932bde8aec2242dd900fd6192a306584456aa48.tar.gz",
        sha256 = "5e330fe4fd0b79677bb6246017e15e80958485005a16df7d69bb82d558fa678f",
        strip_prefix = "cpr-a932bde8aec2242dd900fd6192a306584456aa48",
    )

    # CPR (temporarily) needs boost::filesystem to backfill std::filesystem on Apple platforms.
    # This is not public API; we anticipate eliminating it at some point in the future.
    maybe(
        http_archive,
        name = "com_github_nelhage_rules_boost",
        url = "https://github.com/nelhage/rules_boost/archive/27c9ef79a5455036086c1679889f14732e603f41.tar.gz",
        sha256 = "ed8d66232c85d5b53fb228b115ce6f9dab997fbf82b43c0dd07138818972526b",
        strip_prefix = "rules_boost-27c9ef79a5455036086c1679889f14732e603f41",
    )
    boost_deps()

    # CPR wraps libcurl
    # Note: libcurl updates are auto-PRd but not auto-merged, because the defines required to build it change frequently enough that you need to manually keep curl.BUILD in sync with https://github.com/curl/curl/commits/master/CMakeLists.txt. @cpsauer is responsible.
    maybe(
        http_archive,
        name = "curl",
        build_file = "@hedron_make_cc_https_easy//:curl.BUILD",
        url = "https://github.com/curl/curl/archive/curl-7_88_1.tar.gz",
        sha256 = "eb9f2ca79e2c39b89827cf2cf21f39181f6a537f50dc1df9c33d705913009ac4",
        strip_prefix = "curl-curl-7_88_1",
    )

    # libcurl needs to bundle an SSL library on Android. We're using boringssl because it has easy Bazel support. Despite it's Google-only orientation, it's also used in, e.g., Envoy. But if LibreSSL had Bazel wrappings, we'd probably consider it.
    # We're pointing our own mirror of google/boringssl:master-with-bazel to get Renovate auto-update. Otherwise, Renovate will keep moving us back to master, which doesn't support Bazel. See https://github.com/renovatebot/renovate/issues/18492
    # OPTIMNOTE: Their BUILD files should really be using assembly on Android https://bugs.chromium.org/p/boringssl/issues/detail?id=531
    maybe(
        http_archive,
        name = "boringssl",
        url = "https://github.com/hedronvision/boringssl/archive/681b56ec72d62ae8d6aaeff401e9fa3ea0ab2060.tar.gz",
        sha256 = "3dffd2fe3fab41eeecbfee480303fc9098cac6cb62242304cdde289cd9943ee4",
        strip_prefix = "boringssl-681b56ec72d62ae8d6aaeff401e9fa3ea0ab2060",
    )
