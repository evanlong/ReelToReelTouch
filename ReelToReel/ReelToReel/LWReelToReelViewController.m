//
//  LWReelToReelViewController.m
//  ReelToReel
//
//  Created by Evan Long on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LWReelToReelViewController.h"

@interface LWReelToReelViewController ()

@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;

- (void)_startRecording;
- (void)_updateState;

@end

@implementation LWReelToReelViewController

@synthesize recordButton = _recordButton;
@synthesize playButton = _playButton;
@synthesize stopButton = _stopButton;

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
    }
    else {
        self.recordButton.enabled = YES;
        self.playButton.enabled = YES;
        self.stopButton.enabled = NO;
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.player = nil;
}

@end
