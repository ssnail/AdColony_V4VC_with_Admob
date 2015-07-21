//
//  ViewController.m
//  AdColonyV4VC
//
//  Created by John Fernandes-Salling on 8/15/12.
//

#import <GoogleMobileAds/GADBannerView.h>

#import "ViewController.h"
#import "Constants.h"

#import <AdColony/AdColony.h>

#define V4VC_ZONE_ID @"vz3645c12ae95b4e47ab"

@interface ViewController () {
    GADBannerView *bannerView_;
}
@property IBOutlet UILabel* currencyLabel;
@property IBOutlet UIActivityIndicatorView* spinner;
@property IBOutlet UIButton* button;
- (void)updateCurrencyBalance;
@end


@implementation ViewController
@synthesize currencyLabel, spinner, button;

#pragma mark -
#pragma mark UIViewController Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateCurrencyBalance];
    [self zoneLoading];
    [self addObservers];
    
    [self testAdcolonyAPI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeObservers) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addObservers) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    // Replace this ad unit ID with your own ad unit ID.
    bannerView_.adUnitID = @"ca-app-pub-3914493622494342/9806468318";
    bannerView_.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
//    request.testDevices = @[
//                            @"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
//                            ];
    [self.view addSubview:bannerView_];
    [bannerView_ loadRequest:request];
    
}

- (void)testAdcolonyAPI
{
    NSLog(@"vendor id:%@", [UIDevice currentDevice].identifierForVendor.UUIDString);
    NSLog(@"getOpenUDID:%@", [AdColony getOpenUDID]);
    NSLog(@"getUniqueDeviceID:%@", [AdColony getUniqueDeviceID]);
    NSLog(@"getVendorIdentifier:%@", [AdColony getVendorIdentifier]);
    NSLog(@"getAdvertisingIdentifier:%@", [AdColony getAdvertisingIdentifier]);
    NSLog(@"getODIN1:%@", [AdColony getODIN1]);
    NSLog(@"getVideoCreditBalance:%d", [AdColony getVideoCreditBalance:V4VC_ZONE_ID]);
    NSLog(@"getVideosPerReward:%d", [AdColony getVideosPerReward:V4VC_ZONE_ID]);
    NSLog(@"getVirtualCurrencyNameForZone:%@", [AdColony getVirtualCurrencyNameForZone:V4VC_ZONE_ID]);
    NSLog(@"getVirtualCurrencyRewardAmountForZone:%d", [AdColony getVirtualCurrencyRewardAmountForZone:V4VC_ZONE_ID]);
    NSLog(@"getVirtualCurrencyRewardsAvailableTodayForZone:%d", [AdColony getVirtualCurrencyRewardsAvailableTodayForZone:V4VC_ZONE_ID]);
}
#pragma mark -
#pragma mark UI Updates

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrencyBalance) name:kCurrencyBalanceChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoneReady) name:kZoneReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoneOff) name:kZoneOff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoneLoading) name:kZoneLoading object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kZoneLoading object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kZoneOff object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kZoneReady object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCurrencyBalanceChange object:nil];
}

- (void)zoneReady
{
    [spinner stopAnimating];
    [spinner setHidden:YES];
    [button setEnabled:YES];
}

- (void)zoneOff
{
    [spinner stopAnimating];
    [spinner setHidden:YES];
    [button setEnabled:NO];
}

- (void)zoneLoading
{
    [spinner setHidden:NO];
    [spinner startAnimating];
    [button setEnabled:NO];
}

// Get currency balance from persistent storage and display it
- (void)updateCurrencyBalance
{
    NSNumber* wrappedBalance = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrencyBalance];
    NSUInteger balance = wrappedBalance && [wrappedBalance isKindOfClass:[NSNumber class]] ? [wrappedBalance unsignedIntValue] : 0;
    [currencyLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)balance]];
    
    [self testAdcolonyAPI];

}

#pragma mark -
#pragma mark AdColony-specific

- (IBAction)triggerVideo
{
	[AdColony playVideoAdForZone:V4VC_ZONE_ID withDelegate:nil withV4VCPrePopup:NO andV4VCPostPopup:NO];
}
@end
