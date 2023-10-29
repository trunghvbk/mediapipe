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

#import "CommonViewController.h"

static const char* kVideoQueueLabel = "com.google.mediapipe.example.videoQueue";
static const char* kDeinitQueueLabel = "com.google.mediapipe.example.deinitQueue";

@implementation CommonViewController
// This provides a hook to replace the basic ViewController with a subclass when it's created from a
// storyboard, without having to change the storyboard itself.
+ (instancetype)allocWithZone:(struct _NSZone*)zone {
  NSString* subclassName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MainViewController"];
  if (subclassName.length > 0) {
    Class customClass = NSClassFromString(subclassName);
    Class baseClass = [CommonViewController class];
    NSAssert([customClass isSubclassOfClass:baseClass], @"%@ must be a subclass of %@", customClass,
             baseClass);
    if (self == baseClass) return [customClass allocWithZone:zone];
  }
  return [super allocWithZone:zone];
}

#pragma mark - Cleanup methods

- (void)dealloc {
//    self.mediapipeGraph.delegate = nil;
//    [self.mediapipeGraph cancel];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // Ignore errors since we're cleaning up.
//        [self.mediapipeGraph closeAllInputStreamsWithError:nil];
//        [self.mediapipeGraph waitUntilDoneWithError:nil];
//    });
}

- (IBAction)close:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:true completion:nil];
    });
}

#pragma mark - MediaPipe graph methods

+ (MPPGraph*)loadGraphFromResource:(NSString*)resource {
  // Load the graph config resource.
  NSError* configLoadError = nil;
  NSBundle* bundle = [NSBundle bundleForClass:[self class]];
  if (!resource || resource.length == 0) {
    return nil;
  }
  NSURL* graphURL = [bundle URLForResource:resource withExtension:@"binarypb"];
  NSData* data = [NSData dataWithContentsOfURL:graphURL options:0 error:&configLoadError];
  if (!data) {
    NSLog(@"Failed to load MediaPipe graph config: %@", configLoadError);
    return nil;
  }

  // Parse the graph config resource into mediapipe::CalculatorGraphConfig proto object.
  mediapipe::CalculatorGraphConfig config;
  config.ParseFromArray(data.bytes, data.length);

  // Create MediaPipe graph with mediapipe::CalculatorGraphConfig proto object.
  MPPGraph* newGraph = [[MPPGraph alloc] initWithGraphConfig:config];
  return newGraph;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
  [super viewDidLoad];

  self.renderer = [[MPPLayerRenderer alloc] init];
  self.renderer.layer.frame = self.contentView.layer.bounds;
  [self.contentView.layer addSublayer:self.renderer.layer];
  self.renderer.frameScaleMode = MPPFrameScaleModeFillAndCrop;
    
    self.comparingRenderer = [[MPPLayerRenderer alloc] init];
    self.comparingRenderer.layer.frame = self.userContentView.layer.bounds;
    [self.userContentView.layer addSublayer:self.comparingRenderer.layer];
    self.comparingRenderer.frameScaleMode = MPPFrameScaleModeFillAndCrop;

  self.timestampConverter = [[MPPTimestampConverter alloc] init];

  dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_qos_class(
      DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, /*relative_priority=*/0);
  self.videoQueue = dispatch_queue_create(kVideoQueueLabel, qosAttribute);
    
    dispatch_queue_attr_t deinitQosAttribute = dispatch_queue_attr_make_with_qos_class(
        DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, /*relative_priority=*/0);
    self.deinitQueue = dispatch_queue_create(kDeinitQueueLabel, deinitQosAttribute);

    self.graphName = @"pose_tracking_gpu";
//    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GraphName"];
    self.graphInputStream = "input_video";
//      [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GraphInputStream"] UTF8String];
    self.graphOutputStream = "output_video";
//      [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GraphOutputStream"] UTF8String];
    
  self.mediapipeGraph = [[self class] loadGraphFromResource:self.graphName];
  [self.mediapipeGraph addFrameOutputStream:self.graphOutputStream
                           outputPacketType:MPPPacketTypePixelBuffer];

  self.mediapipeGraph.delegate = self;
    
    self.mediapipeComparingGraph = [[self class] loadGraphFromResource:self.graphName];
    [self.mediapipeComparingGraph addFrameOutputStream:self.graphOutputStream
                             outputPacketType:MPPPacketTypePixelBuffer];

    self.mediapipeComparingGraph.delegate = self;
}

// In this application, there is only one ViewController which has no navigation to other view
// controllers, and there is only one View with live display showing the result of running the
// MediaPipe graph on the live video feed. If more view controllers are needed later, the graph
// setup/teardown and camera start/stop logic should be updated appropriately in response to the
// appearance/disappearance of this ViewController, as viewWillAppear: can be invoked multiple times
// depending on the application navigation flow in that case.
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  switch (self.sourceMode) {
      case MediaPipeDemoSourceVideo: {
          AVAsset* video = [AVAsset assetWithURL:_sourceVideoURL];
          self.videoSource = [[MPPPlayerInputSource alloc] initWithAVAsset:video];
          [self.videoSource setDelegate:self queue:self.videoQueue];
          [self startGraphAndVideo];
          break;
      }
      case MediaPipeDemoSourceComparing: {
//      AVAsset* video = [AVAsset assetWithURL:_sourceVideoURL];
//        NSString* videoName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"VideoName"];
        NSURL* videoURL1 = [[NSBundle mainBundle] URLForResource:@"squats1"
                                                  withExtension:@"mp4"];
        NSURL* videoURL2 = [[NSBundle mainBundle] URLForResource:@"squats2"
                                                  withExtension:@"mov"];
        AVAsset* video1 = [AVAsset assetWithURL: videoURL1];
        AVAsset* video2 = [AVAsset assetWithURL: videoURL2];

      self.videoSource = [[MPPPlayerInputSource alloc] initWithAVAsset:video1];
        self.comparingVideoSource = [[MPPPlayerInputSource alloc] initWithAVAsset:video2];
      [self.videoSource setDelegate:self queue:self.videoQueue];
        [self.comparingVideoSource setDelegate:self queue:self.videoQueue];
        [self startGraphAndVideo];
      break;
    }
    case MediaPipeDemoSourceCamera: {
      self.cameraSource = [[MPPCameraInputSource alloc] init];
      [self.cameraSource setDelegate:self queue:self.videoQueue];
      self.cameraSource.sessionPreset = AVCaptureSessionPresetHigh;

      NSString* cameraPosition =
          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CameraPosition"];
      if (cameraPosition.length > 0 && [cameraPosition isEqualToString:@"back"]) {
        self.cameraSource.cameraPosition = AVCaptureDevicePositionBack;
      } else {
        self.cameraSource.cameraPosition = AVCaptureDevicePositionFront;
        // When using the front camera, mirror the input for a more natural look.
        _cameraSource.videoMirrored = YES;
      }

      // The frame's native format is rotated with respect to the portrait orientation.
      _cameraSource.orientation = AVCaptureVideoOrientationPortrait;

      [self.cameraSource requestCameraAccessWithCompletionHandler:^void(BOOL granted) {
        if (granted) {
          dispatch_async(dispatch_get_main_queue(), ^{
            self.noCameraLabel.hidden = YES;
          });
          [self startGraphAndCamera];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
              self.noCameraLabel.hidden = NO;
            });
        }
      }];

      break;
    }
  }
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
    
    if (![self.mediapipeComparingGraph startWithError:&error]) {
      NSLog(@"Failed to start graph: %@", error);
    }
    else if (![self.mediapipeComparingGraph waitUntilIdleWithError:&error]) {
      NSLog(@"Failed to complete graph initial run: %@", error);
    }
    
    // Start fetching frames from the camera.
    dispatch_async(self.videoQueue, ^{
      [self.videoSource start];
        [self.comparingVideoSource start];
    });
}

- (void)startGraphAndCamera {
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
    [self.cameraSource start];
  });
}

#pragma mark - MPPInputSourceDelegate methods

// Must be invoked on self.videoQueue.
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer
                timestamp:(CMTime)timestamp
               fromSource:(MPPInputSource*)source {
  if (source != self.cameraSource && source != self.videoSource && source != self.comparingVideoSource) {
    NSLog(@"Unknown source: %@", source);
    return;
  }
    
    if (source == self.videoSource || source == self.cameraSource) {
        [self.mediapipeGraph sendPixelBuffer:imageBuffer
                                  intoStream:self.graphInputStream
                                  packetType:MPPPacketTypePixelBuffer
                                   timestamp:[self.timestampConverter timestampForMediaTime:timestamp]];
    } else if (source == self.comparingVideoSource) {
        [self.mediapipeComparingGraph sendPixelBuffer:imageBuffer
                                  intoStream:self.graphInputStream
                                  packetType:MPPPacketTypePixelBuffer
                                   timestamp:[self.timestampConverter timestampForMediaTime:timestamp]];
    }
}

#pragma mark - MPPGraphDelegate methods

// Receives CVPixelBufferRef from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
    didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
              fromStream:(const std::string&)streamName {
  if (streamName == self.graphOutputStream) {
      // Display the captured image on the screen.
      CVPixelBufferRetain(pixelBuffer);
      dispatch_async(dispatch_get_main_queue(), ^{
          if (graph == self.mediapipeGraph) {
              [self.renderer renderPixelBuffer:pixelBuffer];
          } else if (graph == self.mediapipeComparingGraph) {
              [self.comparingRenderer renderPixelBuffer:pixelBuffer];
          }
        CVPixelBufferRelease(pixelBuffer);
      });
    }
}

@end
