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
#import "CompareViewController.h"

#include "mediapipe/framework/formats/landmark.pb.h"
#import <MobileCoreServices/MobileCoreServices.h>

static const char* kLandmarksOutputStream = "pose_landmarks";

@interface PoseTrackingViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation PoseTrackingViewController
BOOL didRunSourceVideo = false;
#pragma mark - UIViewController methods
- (void)viewDidLoad {
  [super viewDidLoad];
    didRunSourceVideo = false;
  [self.mediapipeGraph addFrameOutputStream:kLandmarksOutputStream
                           outputPacketType:MPPPacketTypeRaw];
    
    self.landmarkListArray = [[NSMutableArray alloc] init];
    self.templateLandmarkListArray = [[NSMutableArray alloc] init];
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
    
    if (self.sourceMode == MediaPipeDemoSourceMultipleVideo) {
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
}

- (void)videoDidPlayToEnd:(CMTime)timestamp {
    if (self.sourceMode == MediaPipeDemoSourceComparing) {
        if (self.videoSource.isRunning) {
            [self.videoSource stop];
            NSMutableString *info = [[NSMutableString alloc] initWithString:@""];
            for (int i = 0; i < self.landmarkListArray.count; i++) {
                LandmarkList *landmarkList = self.landmarkListArray[i];
                [info appendString:[NSString stringWithFormat:@"\n%@", [landmarkList description]]];
                if (!didRunSourceVideo) [self.templateLandmarkListArray addObject:landmarkList];
                else [self.comparingLandmarkListArray addObject:landmarkList];
            }
            NSLog([NSString stringWithFormat:@"LandmarkListArray:\n%@", info]);
            NSLog([NSString stringWithFormat:@"LandmarkListArray Count:\n%d", self.landmarkListArray.count]);
            if (self.sourceMode == MediaPipeDemoSourceComparing) {
                NSString *title = didRunSourceVideo ? @"COMPARE" : @"PICK OTHER VIDEO";
                [self.landmarkListArray removeAllObjects];
                [self showCompareButton: true title:title];
            }
        }
    }
}

- (IBAction)compareOtherVideo:(id)sender {
    if (!didRunSourceVideo) {
        [self pickAnotherVideo];
    } else {
        CompareViewController *vc = [self compareViewController];
        [self presentModalViewController:vc animated:true];
    }
    didRunSourceVideo = true;
    [self showCompareButton:false title:@""];
}

- (void) pickAnotherVideo {
    // Create a UIImagePickerController instance.
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    // Set the media types that the UIImagePickerController should allow the user to select.
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.mediaTypes = @[(NSString*)kUTTypeMovie];
    
    // Set the delegate for the UIImagePickerController.
    imagePickerController.delegate = self;
    
    // Present the UIImagePickerController modally.
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the video URL from the info dictionary.
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    
    // Dismiss the UIImagePickerController.
    [picker dismissViewControllerAnimated:YES completion:^{
        AVAsset* video = [AVAsset assetWithURL: videoURL];
        [self.videoSource initWithAVAsset: video];
        [self.videoSource start];
    }];
    
    // Do something with the video URL.
}

- (void)showCompareButton: (BOOL) showed title: (NSString* )title {
    // Show Comparing Button
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.compareButton setTitle:title forState:UIControlStateNormal];
        [self.compareButton setHidden:!showed];
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
            if (self.sourceMode != MediaPipeDemoSourceMultipleVideo) {
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
      
      if (self.sourceMode != MediaPipeDemoSourceMultipleVideo) {
          dispatch_async(dispatch_get_main_queue(), ^{
              self.poseInfoLabel.text = infoString;
          });
      }
  }
}

- (UIViewController *) compareViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CompareViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CompareViewController"];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    return vc;
}

@end
