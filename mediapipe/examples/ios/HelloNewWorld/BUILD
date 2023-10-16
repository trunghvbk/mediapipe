MIN_IOS_VERSION = "12.0"

load(
    "@build_bazel_rules_apple//apple:ios.bzl",
    "ios_application",
)

load(
    "//mediapipe/examples/ios:bundle_id.bzl",
    "BUNDLE_ID_PREFIX",
    "example_provisioning",
)

load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "xcodeproj",
)

# load("@rules_cc//cc:defs.bzl", "objc_library")

xcodeproj(
    name = "xcodeproj",
    build_mode = "bazel",
    project_name = "HelloWorldApp",
    tags = ["manual"],
    top_level_targets = [
        top_level_target(
            ":HelloWorldApp",
            target_environments = [
                "device",
                "simulator",
            ],
        ),
    ],
)

ios_application(
    name = "HelloWorldApp",
    bundle_id = "vn.com.mirabo.mediapipe.sample",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = ["Info.plist"],
    minimum_os_version = MIN_IOS_VERSION,
    provisioning_profile = example_provisioning(),
    deps = [":HelloWorldAppLibrary"],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "HelloWorldAppLibrary",
    srcs = [
        "AppDelegate.m",
        "SceneDelegate.m",
        "ViewController.mm",
        "main.m",
    ],
    hdrs = [
        "AppDelegate.h",
        "SceneDelegate.h",
        "ViewController.h",
    ],
    data = [
        "Base.lproj/LaunchScreen.storyboard",
        "Base.lproj/Main.storyboard",
        "//mediapipe/graphs/edge_detection:mobile_gpu_binary_graph",
    ],
    sdk_frameworks = [
        "UIKit",
        "AVFoundation",
        "CoreGraphics",
        "CoreMedia",
    ],
    deps = [
        "//mediapipe/objc:mediapipe_framework_ios",
        "//mediapipe/objc:mediapipe_input_sources_ios",
        "//mediapipe/objc:mediapipe_layer_renderer",
        "//third_party/apple_frameworks:Metal",
        "//mediapipe/graphs/edge_detection:mobile_calculators",
    ],
)