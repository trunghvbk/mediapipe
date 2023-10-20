# Copyright 2020 The MediaPipe Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load(
    "@build_bazel_rules_apple//apple:ios.bzl",
    "ios_application",
)
load(
    "//mediapipe/examples/ios:bundle_id.bzl",
    "BUNDLE_ID_PREFIX",
    "example_provisioning",
)

licenses(["notice"])

MIN_IOS_VERSION = "13.0"

alias(
    name = "posetrackinggpuswift",
    actual = "PoseTrackingGpuSwiftApp",
)

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "xcodeproj",
)

# load("@rules_cc//cc:defs.bzl", "objc_library")

xcodeproj(
    name = "xcodeproj",
    build_mode = "bazel",
    project_name = "PoseTrackingGpuSwiftApp",
    tags = ["manual"],
    top_level_targets = [
        top_level_target(
            ":PoseTrackingGpuSwiftApp",
            target_environments = [
                "device",
                "simulator",
            ],
        ),
    ],
)

ios_application(
    name = "PoseTrackingGpuSwiftApp",
    app_icons = ["AppIcon"],
    bundle_id = "vn.com.mirabo.mediapipe.sample",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        "Info.plist",
    ],
    minimum_os_version = MIN_IOS_VERSION,
    provisioning_profile = example_provisioning(),
    deps = [
        ":PoseTrackingGpuSwiftAppLibrary",
        "@ios_opencv//:OpencvFramework",
    ],
    visibility = ["//visibility:public"],
)

# objc_library(
#     name = "PoseTrackingGpuAppLibrary",
#     srcs = [
#         "PoseTrackingViewController.mm",
#     ],
#     hdrs = [
#         "PoseTrackingViewController.h",
#     ],
#     copts = ["-std=c++17"],
#     data = [
#         "//mediapipe/graphs/pose_tracking:pose_tracking_gpu.binarypb",
#         "//mediapipe/modules/pose_detection:pose_detection.tflite",
#         "//mediapipe/modules/pose_landmark:pose_landmark_full.tflite",
#     ],
#     deps = [
#         "//mediapipe/examples/ios/common:CommonMediaPipeAppLibrary",
#         "//mediapipe/framework/formats:landmark_cc_proto",
#     ] + select({
#         "//mediapipe:ios_i386": [],
#         "//mediapipe:ios_x86_64": [],
#         "//conditions:default": [
#             "//mediapipe/graphs/pose_tracking:pose_tracking_gpu_deps",
#         ],
#     }),
# )

swift_library(
    name = "PoseTrackingGpuSwiftAppLibrary",
    srcs = glob(["src/*.swift"]),
    # copts = ["-std=c++17"],
    data = [
        "Base.lproj/LaunchScreen.storyboard",
        "Base.lproj/Main.storyboard",
        "//mediapipe/graphs/pose_tracking:pose_tracking_gpu.binarypb",
        "//mediapipe/modules/pose_detection:pose_detection.tflite",
        "//mediapipe/modules/pose_landmark:pose_landmark_full.tflite",
    ],
    visibility = [
        "//mediapipe:__subpackages__",
    ],
    deps = [
        "//mediapipe/objc:mediapipe_framework_ios",
        "//mediapipe/objc:mediapipe_input_sources_ios",
        "//mediapipe/objc:mediapipe_layer_renderer",
        "//third_party/apple_frameworks:AVFoundation",
        "//third_party/apple_frameworks:CoreGraphics",
        "//third_party/apple_frameworks:CoreMedia",
        "//third_party/apple_frameworks:UIKit",
        "//mediapipe/framework/formats:landmark_cc_proto",
    ] 
    + select({
        "//mediapipe:ios_i386": [],
        "//mediapipe:ios_x86_64": [],
        "//conditions:default": [
           "//mediapipe/graphs/pose_tracking:pose_tracking_gpu_deps",
        ],
    }),
)

filegroup(
    name = "AppIcon",
    srcs = glob(["Assets.xcassets/AppIcon.appiconset/*"]),
    visibility = ["//mediapipe:__subpackages__"],
)
