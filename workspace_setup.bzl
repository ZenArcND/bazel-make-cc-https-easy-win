# Do not change the filename; it is part of the user interface.


load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")


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
        url = "https://github.com/libcpr/cpr/archive/1.10.4.tar.gz",
        sha256 = "88462d059cd3df22c4d39ae04483ed50dfd2c808b3effddb65ac3b9aa60b542d",
        strip_prefix = "cpr-1.10.4",
    )

    # CPR (temporarily) needs boost::filesystem to backfill std::filesystem on Apple platforms.
    # This is not public API; we anticipate eliminating it at some point in the future.
    maybe(
        http_archive,
        name = "com_github_nelhage_rules_boost",
        url = "https://github.com/nelhage/rules_boost/archive/5eed19eb483d5b3dd9a5e50cae854f2ae8e46101.tar.gz",
        sha256 = "b27a2b8b31314002ec3a637f6aea0ad8fda3fb2e3b29127345c53a7e63e3d4ef",
        strip_prefix = "rules_boost-5eed19eb483d5b3dd9a5e50cae854f2ae8e46101",
    )
    # boost_deps is called in transitive_sorkspace_setup

    # CPR wraps libcurl
    # Note: libcurl updates are auto-PRd but not auto-merged, because the defines required to build it change frequently enough that you need to manually keep curl.BUILD in sync with https://github.com/curl/curl/commits/master/CMakeLists.txt. @cpsauer is responsible.
    maybe(
        http_archive,
        name = "curl",
        build_file = "@hedron_make_cc_https_easy//:curl.BUILD",
        url = "https://github.com/curl/curl/archive/curl-8_1_0.tar.gz",
        sha256 = "531565b17d1c427b05eeffb139e24d7a48f56e9d068cc75d107160c0848b433d",
        strip_prefix = "curl-curl-8_1_0",
    )

    # libcurl needs to bundle an SSL library on Android. We're using boringssl because it has easy Bazel support. Despite it's Google-only orientation, it's also used in, e.g., Envoy. But if LibreSSL had Bazel wrappings, we'd probably consider it.
    # We're pointing our own mirror of google/boringssl:master-with-bazel to get Renovate auto-update. Otherwise, Renovate will keep moving us back to master, which doesn't support Bazel.
        # https://bugs.chromium.org/p/boringssl/issues/detail?id=542 tracks having bazel on the boringssl master branch.
        # https://github.com/renovatebot/renovate/issues/18492 tracks Renovate support for non-default branches.
    # OPTIMNOTE: Boringssl's BUILD files should really be using assembly on Windows, if we add support https://bugs.chromium.org/p/boringssl/issues/detail?id=531
    maybe(
        http_archive,
        name = "boringssl",
        url = "https://github.com/hedronvision/boringssl/archive/901f77cb8b5be3c25b180b7aafbc5fd04e2b055a.tar.gz",
        sha256 = "43f0a14885482ec0f2ee871d306444e7a52d3eef4179a66ccf0d88535ce068f7",
        strip_prefix = "boringssl-901f77cb8b5be3c25b180b7aafbc5fd04e2b055a",
    )
