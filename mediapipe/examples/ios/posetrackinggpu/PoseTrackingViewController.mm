// Copyright 2020 The MediaPipe Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "PoseTrackingViewController.h"

#include "mediapipe/framework/formats/landmark.pb.h"

static const char* kLandmarksOutputStream = "pose_landmarks";

@implementation PoseTrackingViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.mediapipeGraph addFrameOutputStream:kLandmarksOutputStream
                           outputPacketType:MPPPacketTypeRaw];
}

#pragma mark - MPPGraphDelegate methods

// Receives a raw packet from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
     didOutputPacket:(const ::mediapipe::Packet&)packet
          fromStream:(const std::string&)streamName {
  if (streamName == kLandmarksOutputStream) {
    if (packet.IsEmpty()) {
      NSLog(@"[TS:%lld] No pose landmarks", packet.Timestamp().Value());
      return;
    }
    const auto& landmarks = packet.Get<::mediapipe::NormalizedLandmarkList>();
      NSMutableString *infoString = [NSMutableString stringWithFormat:@"[TS:%lld] Number of pose landmarks: %d \n", packet.Timestamp().Value(),
                                     landmarks.landmark_size()];
    for (int i = 0; i < landmarks.landmark_size(); ++i) {
        mediapipe::NormalizedLandmark landmark = landmarks.landmark(i);
        [infoString appendFormat:@"[%d]: (%.2f, %.2f, %.2f)  ", i, landmark.x(),
         landmark.y(), landmark.z()];
    }
      if (self.sourceMode != MediaPipeDemoSourceComparing) {
          dispatch_async(dispatch_get_main_queue(), ^{
              self.poseInfoLabel.text = infoString;
          });
      }
  }
}

@end
