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
        url = "https://github.com/libcpr/cpr/archive/1.10.3.tar.gz",
        sha256 = "7b9d3504ffdaf7ce3189f1b91d135888776b6a1b26ea1bf2c3c4986b8a5af06f",
        strip_prefix = "cpr-1.10.3",
    )

    # CPR (temporarily) needs boost::filesystem to backfill std::filesystem on Apple platforms.
    # This is not public API; we anticipate eliminating it at some point in the future.
    maybe(
        http_archive,
        name = "com_github_nelhage_rules_boost",
        url = "https://github.com/nelhage/rules_boost/archive/9a102f7ad389f973b88f38b209cd4cabf7af6423.tar.gz",
        sha256 = "7f81d561f7d41f2e4ff6602fab136c6e153bdacfa43887cc4482469cffc9ada7",
        strip_prefix = "rules_boost-9a102f7ad389f973b88f38b209cd4cabf7af6423",
    )
    # boost_deps is called in transitive_sorkspace_setup

    # CPR wraps libcurl
    # Note: libcurl updates are auto-PRd but not auto-merged, because the defines required to build it change frequently enough that you need to manually keep curl.BUILD in sync with https://github.com/curl/curl/commits/master/CMakeLists.txt. @cpsauer is responsible.
    maybe(
        http_archive,
        name = "curl",
        build_file = "@hedron_make_cc_https_easy//:curl.BUILD",
        url = "https://github.com/curl/curl/archive/curl-8_0_1.tar.gz",
        sha256 = "d9aefeb87998472cd79418edd4fb4dc68c1859afdbcbc2e02400b220adc64ec1",
        strip_prefix = "curl-curl-8_0_1",
    )

    # libcurl needs to bundle an SSL library on Android. We're using boringssl because it has easy Bazel support. Despite it's Google-only orientation, it's also used in, e.g., Envoy. But if LibreSSL had Bazel wrappings, we'd probably consider it.
    # We're pointing our own mirror of google/boringssl:master-with-bazel to get Renovate auto-update. Otherwise, Renovate will keep moving us back to master, which doesn't support Bazel.
        # https://bugs.chromium.org/p/boringssl/issues/detail?id=542 tracks having bazel on the boringssl master branch.
        # https://github.com/renovatebot/renovate/issues/18492 tracks Renovate support for non-default branches.
    # OPTIMNOTE: Boringssl's BUILD files should really be using assembly on Windows, if we add support https://bugs.chromium.org/p/boringssl/issues/detail?id=531
    maybe(
        http_archive,
        name = "boringssl",
        url = "https://github.com/hedronvision/boringssl/archive/63bd68c59fdc3815a57e7cac02ebb8a274d0bb70.tar.gz",
        sha256 = "0829f6c8624b06318557830a133935136a0c113a884cee0fe1b287a2477347a6",
        strip_prefix = "boringssl-63bd68c59fdc3815a57e7cac02ebb8a274d0bb70",
    )
