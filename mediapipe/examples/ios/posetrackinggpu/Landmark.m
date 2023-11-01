//
//  Landmark.m
//  PoseTrackingGpuApp
//
//  Created by admin on 31/10/2023.
//
#import "Landmark.h"



@implementation Landmark
- (id)initWithX:(float)x1 y:(float)y1 z:(float)z1 type:(LandmarkType)type1 {
    self = [super init];
    if (!self) return nil;
    self.x = x1;
    self.y = y1;
    self.z = z1;
    self.type = type1;
    return self;
}

- (NSString *)name {
    switch (self.type) {
        case nose:
            return @"nose";
            break;
        case leftEyeInner:
            return @"leftEyeInner";
            break;
        case leftEye:
            return @"leftEye";
            break;
        case leftEyeOuter:
            return @"leftEyeOuter";
            break;
        case rightEyeInner:
            return @"rightEyeInner";
            break;
        case rightEye:
            return @"rightEye";
            break;
        case rightEyeOuter:
            return @"rightEyeOuter";
            break;
        case leftEar:
            return @"leftEar";
            break;
        case rightEar:
            return @"rightEar";
            break;
        case mouthLeft:
            return @"mouthLeft";
            break;
        case mouthRight:
            return @"mouthRight";
            break;
        case leftShoulder:
            return @"leftShoulder";
            break;
        case rightShoulder:
            return @"rightShoulder";
            break;
        case leftElbow:
            return @"leftElbow";
            break;
        case rightElbow:
            return @"rightElbow";
            break;
        case leftWrist:
            return @"leftWrist";
            break;
        case rightWrist:
            return @"rightWrist";
            break;
        case leftPinky:
            return @"leftPinky";
            break;
        case rightPinky:
            return @"rightPinky";
            break;
        case leftIndex:
            return @"leftIndex";
            break;
        case rightIndex:
            return @"rightIndex";
            break;
        case leftThumb:
            return @"leftThumb";
            break;
        case rightThumb:
            return @"rightThumb";
            break;
        case leftHip:
            return @"leftHip";
            break;
        case rightHip:
            return @"rightHip";
            break;
        case leftKnee:
            return @"leftKnee";
            break;
        case rightKnee:
            return @"rightKnee";
            break;
        case leftAnkle:
            return @"leftAnkle";
            break;
        case rightAnkle:
            return @"rightAnkle";
            break;
        case leftHeel:
            return @"leftHeel";
            break;
        case rightHeel:
            return @"rightHeel";
            break;
        case leftFootIndex:
            return @"leftFootIndex";
            break;
        case rightFootIndex:
            return @"rightFootIndex";
            break;
    }
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@: x: %f - y: %f - z: %f", self.name, self.x, self.y, self.z];
}

@end

@implementation LandmarkList

- (id)initWithLandmarks:(NSArray *)landmarks1  timeStamp:(float)timeStamp1 {
    self = [super init];
    if (!self) return  nil;
    self.landmarks = landmarks1;
    self.timeStamp = timeStamp1;
    return self;
}

- (NSString *)description {
    NSMutableString *des = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < self.landmarks.count; i++) {
        [des appendString: [NSString stringWithFormat:@" %@", [self.landmarks[i] description]]];
    }
    return [NSString stringWithFormat:@"TS:%f - %@", self.timeStamp, des];
}
@end
