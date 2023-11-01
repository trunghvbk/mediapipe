//
//  CompareViewController.m
//  PoseTrackingGpuApp
//
//  Created by admin on 31/10/2023.
//

#import "CompareViewController.h"
#import <math.h>

@interface CompareMetric : NSObject
@property (nonatomic, readwrite) float timeRange;
@property (nonatomic, readwrite) float leftKneeFolding;
- (id) initWithTimeRange: (float) timeRange leftKneeFolding: (float) leftKneeFolding;
@end

@implementation CompareMetric
- (id) initWithTimeRange: (float) timeRange leftKneeFolding: (float) leftKneeFolding {
    self = [super init];
    self.timeRange = timeRange;
    self.leftKneeFolding = leftKneeFolding;
    return self;
}
@end

@implementation CompareViewController
CompareMetric* templateMetric;
CompareMetric* comparingMetric;
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self calculateMatching];
}

- (void) calculateMatching {
    LandmarkList* minTemplateX = [self findMinXLandmarkList:self.templateLandmarkListArray ofType:leftKnee];
    LandmarkList* maxTemplateX = [self findMaxXLandmarkList:self.templateLandmarkListArray ofType:leftKnee];
    float templateTimeRange = fabsf(minTemplateX.timeStamp - maxTemplateX.timeStamp);
    LandmarkList* minComparingX = [self findMinXLandmarkList:self.comparingLandmarkListArray ofType:leftKnee];
    LandmarkList* maxComparingX = [self findMaxXLandmarkList:self.comparingLandmarkListArray ofType:leftKnee];
    float comparingTimeRange = fabsf(minComparingX.timeStamp - maxComparingX.timeStamp);
    
    templateMetric = [[CompareMetric alloc] initWithTimeRange:templateTimeRange leftKneeFolding:minTemplateX.landmarks[leftKnee].x];
    
    comparingMetric = [[CompareMetric alloc] initWithTimeRange:comparingTimeRange leftKneeFolding:minComparingX.landmarks[leftKnee].x];
    
    [self showComparingMetrics];
}

- (LandmarkList* ) findMinXLandmarkList: (NSArray<LandmarkList*> *) landmarkListArray ofType:(LandmarkType) type {
    LandmarkList* minXLandmarkList = landmarkListArray[0];
    for (int i = 1; i < landmarkListArray.count; i++) {
        LandmarkList *landmarkList = landmarkListArray[i];
        NSNumber* x = [NSNumber numberWithFloat: landmarkList.landmarks[type].x];
        NSNumber* minX = [NSNumber numberWithFloat: minXLandmarkList.landmarks[type].x];
        if ([x compare: minX] == NSOrderedAscending) {
            minXLandmarkList = landmarkList;
        }
    }
    return minXLandmarkList;
}

- (LandmarkList* ) findMaxXLandmarkList: (NSArray<LandmarkList*> *) landmarkListArray ofType:(LandmarkType) type {
    LandmarkList* maxXLandmarkList = landmarkListArray[0];
    for (int i = 1; i < landmarkListArray.count; i++) {
        LandmarkList *landmarkList = landmarkListArray[i];
        NSNumber* x = [NSNumber numberWithFloat: landmarkList.landmarks[type].x];
        NSNumber* minX = [NSNumber numberWithFloat: maxXLandmarkList.landmarks[type].x];
        if ([x compare: minX] == NSOrderedDescending) {
            maxXLandmarkList = landmarkList;
        }
    }
    return maxXLandmarkList;
}

- (void) showComparingMetrics {
    NSMutableString *comparingText = [[NSMutableString alloc] initWithString:@""];
    float speed = (comparingMetric.timeRange / templateMetric.timeRange) * 100;
    float kneeFolding = ((1 - comparingMetric.leftKneeFolding) / (1 - templateMetric.leftKneeFolding)) * 100;
    [comparingText appendString:@"Template pose:\n"];
    [comparingText appendFormat:@"\t- Finish Time: %.2f seconds", templateMetric.timeRange / 1000000];
    [comparingText appendString:@"\n"];
    [comparingText appendFormat:@"\t- Left knee Folding: %f", templateMetric.leftKneeFolding];
    [comparingText appendString:@"\n\n"];
    [comparingText appendString:@"User pose:\n"];
    [comparingText appendFormat:@"\t -Finish Time: %.2f seconds, comparing to template time: %.2f%%", comparingMetric.timeRange / 1000000, speed];
    [comparingText appendString:@"\n"];
    [comparingText appendString:[NSString stringWithFormat:@"\t -Left knee Folding: %f, comparing to template folding: %.2f%%", comparingMetric.leftKneeFolding, kneeFolding]];
    
    _resultLabel.text = comparingText;
}
@end
