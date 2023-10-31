//
//  PoseHelper.m
//  PoseTrackingGpuApp
//
//  Created by admin on 31/10/2023.
//

#import "PoseHelper.h"

@implementation PoseHelper
-(NSMutableArray* )analyzeCheckmarks:(::mediapipe::NormalizedLandmarkList[]) landmarksArray {
    NSMutableArray *leftKneeX = [[NSMutableArray alloc] init];
    for (int i = 0; i < landmarksArray->landmark_size(); i++) {
        ::mediapipe::NormalizedLandmarkList landmarks = landmarksArray[i];
        if (landmarks.landmark_size() == 33) {
            ::mediapipe::NormalizedLandmark leftKnee = landmarks.landmark(25);
            [leftKneeX addObject: [NSNumber numberWithFloat:leftKnee.x()]];
        }
    }
    return leftKneeX;
}
@end
