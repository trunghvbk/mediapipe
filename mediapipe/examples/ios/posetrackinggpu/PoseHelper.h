//
//  PoseHelper.h
//  PoseTrackingGpuApp
//
//  Created by admin on 31/10/2023.
//

#import <Foundation/Foundation.h>
#import "mediapipe/objc/MPPCameraInputSource.h"
#import "mediapipe/objc/MPPGraph.h"
#import "mediapipe/objc/MPPLayerRenderer.h"
#import "mediapipe/objc/MPPPlayerInputSource.h"
#import "mediapipe/objc/MPPTimestampConverter.h"

#include "mediapipe/framework/formats/landmark.pb.h"

@interface PoseHelper : NSObject
- (NSMutableArray* )analyzeCheckmarks:(::mediapipe::NormalizedLandmarkList[]) landmarksArray;
@end

// List landmarks and corresponding locations
//0 - nose
//1 - left eye (inner)
//2 - left eye
//3 - left eye (outer)
//4 - right eye (inner)
//5 - right eye
//6 - right eye (outer)
//7 - left ear
//8 - right ear
//9 - mouth (left)
//10 - mouth (right)
//11 - left shoulder
//12 - right shoulder
//13 - left elbow
//14 - right elbow
//15 - left wrist
//16 - right wrist
//17 - left pinky
//18 - right pinky
//19 - left index
//20 - right index
//21 - left thumb
//22 - right thumb
//23 - left hip
//24 - right hip
//25 - left knee
//26 - right knee
//27 - left ankle
//28 - right ankle
//29 - left heel
//30 - right heel
//31 - left foot index
//32 - right foot index
// https://developers.google.com/static/mediapipe/images/solutions/pose_landmarks_index.png
