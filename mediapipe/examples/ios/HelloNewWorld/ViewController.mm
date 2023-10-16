//
//  ViewController.m
//  HelloWorld
//
//  Created by admin on 13/10/2023.
//

#import "ViewController.h"
#import "mediapipe/objc/MPPCameraInputSource.h"
#import "mediapipe/objc/MPPLayerRenderer.h"
#import "mediapipe/objc/MPPGraph.h"

static const char* kVideoQueueLabel = "com.google.mediapipe.example.videoQueue";
static NSString* const kGraphName = @"mobile_gpu";

static const char* kInputStream = "input_video";
static const char* kOutputStream = "output_video";

@interface ViewController () <MPPInputSourceDelegate, MPPGraphDelegate>
// Display the camera preview frames.
@property (weak, nonatomic) IBOutlet UIView* liveView;
// The MediaPipe graph currently in use. Initialized in viewDidLoad, started in viewWillAppear: and
// sent video frames on _videoQueue.
@property(nonatomic) MPPGraph* mediapipeGraph;
@end

@implementation ViewController
// Handles camera access via AVCaptureSession library.
MPPCameraInputSource* _cameraSource;
// Process camera frames on this queue.
dispatch_queue_t _videoQueue;
// Render frames in a layer.
MPPLayerRenderer* _renderer;

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_qos_class(
                                                                                 DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, /*relative_priority=*/0);
    _videoQueue = dispatch_queue_create(kVideoQueueLabel, qosAttribute);
    // Do any additional setup after loading the view.
    _cameraSource = [[MPPCameraInputSource alloc] init];
    _cameraSource.sessionPreset = AVCaptureSessionPresetHigh;
    _cameraSource.cameraPosition = AVCaptureDevicePositionBack;
    // The frame's native format is rotated with respect to the portrait orientation.
    _cameraSource.orientation = AVCaptureVideoOrientationPortrait;
    [_cameraSource setDelegate:self queue:_videoQueue];
    _renderer = [[MPPLayerRenderer alloc] init];
    _renderer.layer.frame = _liveView.layer.bounds;
    [_liveView.layer addSublayer:_renderer.layer];
    _renderer.frameScaleMode = MPPFrameScaleModeFillAndCrop;
    
    self.mediapipeGraph = [[self class] loadGraphFromResource:kGraphName];
    self.mediapipeGraph.delegate = self;
    // Set maxFramesInFlight to a small value to avoid memory contention for real-time processing.
    self.mediapipeGraph.maxFramesInFlight = 2;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_cameraSource requestCameraAccessWithCompletionHandler:^void(BOOL granted) {
        if (granted) {
            // Start running self.mediapipeGraph.
            NSError* error;
            if (![self.mediapipeGraph startWithError:&error]) {
                NSLog(@"Failed to start graph: %@", error);
            }
            else if (![self.mediapipeGraph waitUntilIdleWithError:&error]) {
                NSLog(@"Failed to complete graph initial run: %@", error);
            }
            dispatch_async(_videoQueue, ^{
                [_cameraSource start];
            });
        }
    }];
}

// Must be invoked on _videoQueue.
-   (void)processVideoFrame:(CVPixelBufferRef)imageBuffer
                  timestamp:(CMTime)timestamp
                 fromSource:(MPPInputSource*)source {
    if (source != _cameraSource) {
        NSLog(@"Unknown source: %@", source);
        return;
    }
//    // Display the captured image on the screen.
//    CFRetain(imageBuffer);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_renderer renderPixelBuffer:imageBuffer];
//        CFRelease(imageBuffer);
//    });
    [self.mediapipeGraph sendPixelBuffer:imageBuffer
                                intoStream:kInputStream
                                packetType:MPPPacketTypePixelBuffer];
}

+   (MPPGraph*)loadGraphFromResource:(NSString*)resource {
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
    [newGraph addFrameOutputStream:kOutputStream outputPacketType:MPPPacketTypePixelBuffer];
    return newGraph;
}

-   (void)mediapipeGraph:(MPPGraph*)graph
   didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
             fromStream:(const std::string&)streamName {
  if (streamName == kOutputStream) {
    // Display the captured image on the screen.
    CVPixelBufferRetain(pixelBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
      [_renderer renderPixelBuffer:pixelBuffer];
      CVPixelBufferRelease(pixelBuffer);
    });
  }
}
@end
