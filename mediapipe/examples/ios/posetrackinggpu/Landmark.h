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

@interface Landmark: NSObject
- (id)initWithX:(float) x1 y: (float) y1 z:(float) z1 type: (LandmarkType) type;
- (NSString *) description;
- (NSString *) name;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;
@property (nonatomic) LandmarkType type;
@end

@interface LandmarkList : NSObject
- (id)initWithLandmarks:(NSArray *) landmarks timeStamp: (float) timeStamp;
- (NSString *) description;
@property (nonatomic, readwrite) NSArray<Landmark*>* landmarks;
@property (nonatomic) float timeStamp;
@end
