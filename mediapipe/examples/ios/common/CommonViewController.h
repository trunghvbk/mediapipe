// Copyright 2019 The MediaPipe Authors.
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

#import <UIKit/UIKit.h>

#import "mediapipe/objc/MPPCameraInputSource.h"
#import "mediapipe/objc/MPPGraph.h"
#import "mediapipe/objc/MPPLayerRenderer.h"
#import "mediapipe/objc/MPPPlayerInputSource.h"
#import "mediapipe/objc/MPPTimestampConverter.h"

typedef NS_ENUM(NSInteger, MediaPipeDemoSourceMode) {
    MediaPipeDemoSourceCamera,
    MediaPipeDemoSourceVideo,
    MediaPipeDemoSourceComparing,
};

@interface CommonViewController : UIViewController <MPPGraphDelegate, MPPInputSourceDelegate>

// The MediaPipe graph currently in use. Initialized in viewDidLoad, started in
// viewWillAppear: and sent video frames on videoQueue.
@property(nonatomic) MPPGraph* mediapipeGraph;
@property(nonatomic) MPPGraph* mediapipeComparingGraph;

// Handles camera access via AVCaptureSession library.
@property(nonatomic) MPPCameraInputSource* cameraSource;

// Provides data from a video.
@property(nonatomic) MPPPlayerInputSource* videoSource;

@property(nonatomic) MPPPlayerInputSource* comparingVideoSource;

// Helps to convert timestamp.
@property(nonatomic) MPPTimestampConverter* timestampConverter;

// The data source for the demo.
@property(nonatomic) MediaPipeDemoSourceMode sourceMode;
@property(nonatomic) NSURL* sourceVideoURL;

// Inform the user when camera is unavailable.
@property(nonatomic) IBOutlet UILabel* noCameraLabel;
@property(nonatomic) IBOutlet UILabel* poseInfoLabel;

// Display the camera preview frames.
@property(strong, nonatomic) IBOutlet UIView* liveView;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *contentView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *userContentView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *compareButton;

// Render frames in a layer.
@property(nonatomic) MPPLayerRenderer* renderer;
@property(nonatomic) MPPLayerRenderer* comparingRenderer;

// Process camera frames on this queue.
@property(nonatomic) dispatch_queue_t videoQueue;
@property(nonatomic) dispatch_queue_t deinitQueue;

// Graph name.
@property(nonatomic) NSString* graphName;

// Graph input stream.
@property(nonatomic) const char* graphInputStream;

// Graph output stream.
@property(nonatomic) const char* graphOutputStream;

- (void)startGraphAndVideo;
@end
