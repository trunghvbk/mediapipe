//
//  CompareViewController.h
//  PoseTrackingGpuApp
//
//  Created by admin on 31/10/2023.
//

#import <UIKit/UIKit.h>
#import "Landmark.h"

@interface CompareViewController : UIViewController
@property (nonatomic, readwrite) NSMutableArray<LandmarkList*> *templateLandmarkListArray;
@property (nonatomic, readwrite) NSMutableArray<LandmarkList*> *comparingLandmarkListArray;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *resultLabel;

@end
