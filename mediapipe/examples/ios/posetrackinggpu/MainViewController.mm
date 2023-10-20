//
//  MainViewController.m
//  PoseTrackingGpuApp
//
//  Created by admin on 19/10/2023.
//

#import "MainViewController.h"
#import "PoseTrackingViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation MainViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (IBAction)selectVideo:(id)sender {
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
        PoseTrackingViewController *vc = [self trackingViewController];
        vc.sourceMode = MediaPipeDemoSourceVideo;
        vc.sourceVideoURL = videoURL;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:YES completion:nil];
        });
    }];
    
    // Do something with the video URL.
}

- (IBAction)openLiveCamera:(id)sender {
    PoseTrackingViewController *vc = [self trackingViewController];
    vc.sourceMode = MediaPipeDemoSourceCamera;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (UIViewController *) trackingViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PoseTrackingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CommonViewController"];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    return vc;
}

@end
