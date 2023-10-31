//
//  Landmark.h
//  PoseTrackingGpuApp
//
//  Created by admin on 31/10/2023.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LandmarkType) {
    nose = 0,
    leftEyeInner,
    leftEye,
    leftEyeOuter,
    rightEyeInner,
    rightEye,
    rightEyeOuter,
    leftEar,
    rightEar,
    mouthLeft,
    mouthRight,
    leftShoulder,
    rightShoulder,
    leftElbow,
    rightElbow,
    leftWrist,
    rightWrist,
    leftPinky,
    rightPinky,
    leftIndex,
    rightIndex,
    leftThumb,
    rightThumb,
    leftHip,
    rightHip,
    leftKnee,
    rightKnee,
    leftAnkle,
    rightAnkle,
    leftHeel,
    rightHeel,
    leftFootIndex,
    rightFootIndex
};

@interface Landmark: NSObject {
    float x;
    float y;
    float z;
    LandmarkType type;
}
- (id)initWithX:(float) x1 y: (float) y1 z:(float) z1 type: (LandmarkType) type;
- (NSString *) description;
- (NSString *) name;
@end

@interface LandmarkList : NSObject {
    NSArray<Landmark *> *landmarks;
    float timeStamp;
}
- (id)initWithLandmarks:(NSArray *) landmarks timeStamp: (float) timeStamp;
- (NSString *) description;
@end
