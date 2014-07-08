//
//  BGPrePermissionDialogsVC.m
//  Users-Permissions
//
//  Created by Leapfrog on 7/8/14.
//
//

#import "BGPrePermissionDialogsVC.h"

// UIAlert Blocked Based
#import "UIAlertView+Blocks.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>

@interface BGPrePermissionDialogsVC () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *micButton;

@end

@implementation BGPrePermissionDialogsVC

#define kMicrophonePermissionKey @"kMicrophonePermissionKey"

typedef NS_ENUM(NSInteger, AlertViewButton) {
    AlertViewButtonCancel = 0,
    AlertViewButtonYes,
};

// Custom Permission Dialog

- (void)permissionDialog {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPermissionShown = [defaults boolForKey:kMicrophonePermissionKey];
    if (!isPermissionShown) {
        [UIAlertView showWithTitle:@"Let Access Microphone?" message:@"Would you like this app to access the Microphone" cancelButtonTitle:@"Not Now" otherButtonTitles:@[@"Give Access"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            NSLog(@"%ld", (long)buttonIndex);
            switch (buttonIndex) {
                case  AlertViewButtonCancel:
                    
                    break;
                case  AlertViewButtonYes: {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:kMicrophonePermissionKey];
                    [defaults synchronize];
                    
                    [self checkPermission:^(BOOL flagPermission) {
                        [self changeButtonState:flagPermission];
                        NSLog(@"checkPermission %hhd",  flagPermission);
                    }];
                    break;
                }
                default:
                    break;
            }
        }];
    } else {
        [self checkPermission:^(BOOL flagPermission) {
            [self changeButtonState:flagPermission];
            NSLog(@"checkPermission %hhd",  flagPermission);
        }];
    }
}

- (void)changeButtonState:(BOOL)isPermitted {
    UIImage *img = [UIImage new];
    if (isPermitted) {
        img = [UIImage imageNamed:@"MicButtonImage"];
    } else {
        img = [UIImage imageNamed:@"MicButtonImage_disable"];
    }
    
    [self.micButton setImage:img forState:UIControlStateNormal];
}


typedef void (^checkPermissionBlock)(BOOL flagPermission);

- (void)checkPermission:(checkPermissionBlock)completion {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                // Microphone enabled code
                NSLog(@"Microphone is enabled..");
                // return YES;
                completion(YES);
            }
            else {
                // Microphone disabled code
                NSLog(@"Microphone is disabled..");
                // return  NO;
                // We're in a background thread here, so jump to main thread to do UI work.
                dispatch_async(dispatch_get_main_queue(), ^{
                });
                completion(NO);
            }
        }];
    }
}

- (IBAction)micBtnAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPermissionShown = [defaults boolForKey:kMicrophonePermissionKey];
    if (isPermissionShown) {
        [self checkPermission:^(BOOL flagPermission) {
            [self changeButtonState:flagPermission];
            if (!flagPermission) {
                [[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                            message:@"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
                                           delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            } else {
                NSLog(@"Take Action");
                // Take Action
            }
        }];
    } else {
        [self permissionDialog];
    }
}

#pragma mark - View Life Cycle

// Do any additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPermissionShown = [defaults boolForKey:kMicrophonePermissionKey];
    if (isPermissionShown) {
        [self permissionDialog];
    }
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
