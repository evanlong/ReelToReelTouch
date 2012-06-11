//
//  LWReelToReelViewController.m
//  ReelToReel
//
//  Created by Evan Long on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LWReelToReelViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LWReelToReelViewController ()

@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIImageView *leftReelImageView;
@property (nonatomic, strong) IBOutlet UIImageView *rightReelImageView;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;

- (void)_startRecording;
- (void)_updateState;
- (void)_startAnimating;
- (void)_stopAnimating;

@end

@implementation LWReelToReelViewController

@synthesize recordButton = _recordButton;
@synthesize playButton = _playButton;
@synthesize stopButton = _stopButton;
@synthesize leftReelImageView = _leftReelImageView;
@synthesize rightReelImageView = _rightReelImageView;

@synthesize recorder = _recorder;
- (void)setRecorder:(AVAudioRecorder *)recorder {
    _recorder = recorder;
    [self _updateState];
}

@synthesize player = _player;
- (void)setPlayer:(AVAudioPlayer *)player {
    _player = player;
    [self _updateState];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _updateState];
}

- (void)viewDidUnload {
    self.recordButton = nil;
    self.playButton = nil;
    self.stopButton = nil;
    [super viewDidUnload];
}

#pragma mark - IB Callbacks

- (IBAction)stop {
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
    else if (self.recorder) {
        [self.recorder stop];
        self.recorder = nil;
    }
}

- (IBAction)record {
    if (self.player == nil && self.recorder == nil) {
        [self _startRecording];
    }
}

- (IBAction)play {
    if (self.player == nil && self.recorder == nil) {
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *recordingUrl = [documentsDirectory URLByAppendingPathComponent:@"recording.wav"];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordingUrl error:NULL];
        self.player.delegate = self;
        [self.player play];
    }
}

#pragma mark - Private

- (void)_startRecording {
    NSParameterAssert(self.recorder == nil);
    NSParameterAssert(self.player == nil);
    
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *recordingUrl = [documentsDirectory URLByAppendingPathComponent:@"recording.wav"];
    [[NSFileManager defaultManager] removeItemAtURL:recordingUrl error:nil];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                              [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                              nil];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:recordingUrl settings:settings error:NULL];
    self.recorder.delegate = self;
    [self.recorder record];
}

- (void)_updateState {
    if (self.player || self.recorder) {
        self.recordButton.enabled = NO;
        self.playButton.enabled = NO;
        self.stopButton.enabled = YES;
        [self _startAnimating];
    }
    else {
        self.recordButton.enabled = YES;
        self.playButton.enabled = YES;
        self.stopButton.enabled = NO;
        [self _stopAnimating];
    }
}

- (void)_startAnimating {
    NSNumber *leftRotation = [self.leftReelImageView.layer valueForKeyPath:@"transform.rotation"];
    NSNumber *rightRotation = [self.rightReelImageView.layer valueForKeyPath:@"transform.rotation"];
    
    CABasicAnimation *leftReelAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    leftReelAnimation.fromValue = [NSNumber numberWithFloat:[leftRotation floatValue]];
    leftReelAnimation.toValue = [NSNumber numberWithFloat:M_PI * -2];
    leftReelAnimation.duration = 4.5f;
    leftReelAnimation.repeatCount = MAXFLOAT;
    [self.leftReelImageView.layer addAnimation:leftReelAnimation forKey:@"leftReel"];
    
    CABasicAnimation *rightReelAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rightReelAnimation.fromValue = [NSNumber numberWithFloat:[rightRotation floatValue]];
    rightReelAnimation.toValue = [NSNumber numberWithFloat:M_PI * -2];
    rightReelAnimation.duration = 4.5f;
    rightReelAnimation.repeatCount = MAXFLOAT;
    [self.rightReelImageView.layer addAnimation:rightReelAnimation forKey:@"rightReel"];
}

- (void)_stopAnimating {
    CALayer *pLayer = (CALayer *)self.leftReelImageView.layer.presentationLayer;
    if (pLayer) {
        CATransform3D leftPreviousTransform = pLayer.transform;
        pLayer = (CALayer *)self.rightReelImageView.layer.presentationLayer;
        CATransform3D rightPreviousTransform = pLayer.transform;
        
        self.leftReelImageView.layer.transform = leftPreviousTransform;
        self.rightReelImageView.layer.transform = rightPreviousTransform;
        
        [self.leftReelImageView.layer removeAllAnimations];
        [self.rightReelImageView.layer removeAllAnimations];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.player = nil;
}

@end
