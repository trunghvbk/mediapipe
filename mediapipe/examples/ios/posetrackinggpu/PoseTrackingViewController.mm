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
    
    self.landmarkListArray = [[NSMutableArray alloc] init];
    self.comparingLandmarkListArray = [[NSMutableArray alloc] init];
    
    self.compareButton.layer.cornerRadius = 4;
    self.compareButton.layer.masksToBounds = true;
}

- (void)startGraphAndVideo {
    // Start running self.mediapipeGraph.
    NSError* error;
    if (![self.mediapipeGraph startWithError:&error]) {
      NSLog(@"Failed to start graph: %@", error);
    }
    else if (![self.mediapipeGraph waitUntilIdleWithError:&error]) {
      NSLog(@"Failed to complete graph initial run: %@", error);
    }
    
    // Start fetching frames from the camera.
    dispatch_async(self.videoQueue, ^{
      [self.videoSource start];
    });
}

- (void)startComparingGraphAndVideo {
    NSError* error;
    if (![self.mediapipeComparingGraph startWithError:&error]) {
      NSLog(@"Failed to start graph: %@", error);
    }
    else if (![self.mediapipeComparingGraph waitUntilIdleWithError:&error]) {
      NSLog(@"Failed to complete graph initial run: %@", error);
    }
    
    dispatch_async(self.videoQueue, ^{
        [self.comparingVideoSource start];
    });
}

- (void)videoDidPlayToEnd:(CMTime)timestamp {
    if (self.videoSource.isRunning) {
        [self.videoSource stop];
        NSMutableString *info = [[NSMutableString alloc] initWithString:@""];
        for (int i = 0; i < self.landmarkListArray.count; i++) {
            [info appendString:[NSString stringWithFormat:@"\n%@", [self.landmarkListArray[i] description]]];
        }
//        NSLog([NSString stringWithFormat:@"LandmarkListArray:\n%@", info]);
        NSLog([NSString stringWithFormat:@"LandmarkListArray:\n%d", self.landmarkListArray.count]);
        [self startComparingGraphAndVideo];
    } else if (self.comparingVideoSource.isRunning) {
        [self.comparingVideoSource stop];
//        NSMutableString *info = [[NSMutableString alloc] initWithString:@""];
//        for (int i = 0; i < self.comparingLandmarkListArray.count; i++) {
//            [info appendString:[self.comparingLandmarkListArray[i] description]];
//        }
        NSLog([NSString stringWithFormat:@"ComparingLandmarkListArray:\n%d", self.comparingLandmarkListArray.count]);
        
        [self showCompareButton];
    }
}

- (void)showCompareButton {
    // Show Comparing Button
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.compareButton setHidden:false];
    });
}


#pragma mark - MPPGraphDelegate methods

// Receives a raw packet from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
     didOutputPacket:(const ::mediapipe::Packet&)packet
          fromStream:(const std::string&)streamName {
    if (streamName == kLandmarksOutputStream) {
        int64 timeStamp = packet.Timestamp().Value();
//        NSLog(@"TS:%lld", timeStamp);
        if (packet.IsEmpty()) {
            NSLog(@"[TS:%lld] No pose landmarks", timeStamp);
            return;
        }
        
        const auto& landmarks = packet.Get<::mediapipe::NormalizedLandmarkList>();
        NSMutableString *infoString = [NSMutableString stringWithFormat:@"[TS:%lld] Number of pose landmarks: %d \n", timeStamp, landmarks.landmark_size()];
        NSMutableArray<Landmark *>* landmarkList = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < landmarks.landmark_size(); ++i) {
            mediapipe::NormalizedLandmark landmark = landmarks.landmark(i);
            if (self.sourceMode != MediaPipeDemoSourceComparing) {
                [infoString appendFormat:@"[%d]: (%f, %f, %f)  ", i, landmark.x(),
                 landmark.y(), landmark.z()];
            }
//            if (graph == self.mediapipeComparingGraph) {
//                NSLog([NSString stringWithFormat:@"[%d]: (%f, %f, %f)  ", i, landmark.x(),
//                       landmark.y(), landmark.z()]);
//            } else {
//                NSLog([NSString stringWithFormat:@"Comparing [%d]: (%f, %f, %f)  ", i, landmark.x(),
//                       landmark.y(), landmark.z()]);
//            }
            
            Landmark *aLandmark = [[Landmark alloc] initWithX:landmark.x() y:landmark.y() z:landmark.z() type: (LandmarkType)i];
                [landmarkList addObject:aLandmark];
        }
        
        LandmarkList* landmarkList1 = [[LandmarkList alloc] initWithLandmarks:landmarkList timeStamp: timeStamp];
        if (graph == self.mediapipeGraph) {
            [self.landmarkListArray addObject: landmarkList1];
        } else if (graph == self.mediapipeComparingGraph) {
            [self.comparingLandmarkListArray addObject: landmarkList1];
        }
      
      if (self.sourceMode != MediaPipeDemoSourceComparing) {
          dispatch_async(dispatch_get_main_queue(), ^{
              self.poseInfoLabel.text = infoString;
          });
      }
  }
}

@end
