#import <UIKit/UIKit.h>

/*
 *  CONSTANTS
 */

// View tags allow subview recovery
#define CASE_CONTROL	990
#define MIX_CONTROL		991
#define LENGTH_CONTROL	992
#define LABEL_TEXT		993
#define RLABEL_TEXT		994

// Define the groups of characters from which the passwords are generated
#define ALPHA_LC		@"abcdefghijklmnopqrstuvwxyz"
#define ALPHA_UC		[ALPHA_LC uppercaseString]
#define NUMBERS			@"0123456789"
#define PUNCTUATION		@"~!@#$%^&*+=?/|:;"


/*
 * TappableView and TappleViewDelegate : Creates a simple tappable view that relays taps to a delegate
 * which handles those taps. This view is used in the middle of the password generator screen.
 */

@class TappableView;

@protocol TappableViewDelegate
- (void) tapEnded: (TappableView *) aView;
@end

@interface TappableView : UIImageView
{
	id <TappableViewDelegate> delegate;
}
@property (nonatomic, retain) id delegate;
@end

@implementation TappableView
@synthesize delegate;
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// relay the end of the touch to the delegate for handling
	if (self.delegate) [self.delegate tapEnded:self];
}
@end

/*
 * DoubleTapSegmentedControl and DoubleTapSegmentedControlDelegate: Creates a segmented control that
 * accepts and responds to a second tap on an already selected item.
 */

@class DoubleTapSegmentedControl;

@protocol DoubleTapSegmentedControlDelegate <NSObject>
- (void) performSegmentAction;
@end

@interface DoubleTapSegmentedControl : UISegmentedControl
{
	id <DoubleTapSegmentedControlDelegate>	delegate;
}
@property (nonatomic, retain)	id delegate;
@end

@implementation DoubleTapSegmentedControl
@synthesize delegate;

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.delegate) [self.delegate performSegmentAction];
}
@end

/*
 * PWGenController: Password Generation Controller that allows users to generate passwords 
 * according to the conditions they have set in three segmented controls: alphanumeric, case, and
 * overall password length
 */

@interface PWGenController : UIViewController <DoubleTapSegmentedControlDelegate, TappableViewDelegate>
@end

@implementation PWGenController
-(void) generatePassword
{
	// initialize the set
	NSString *selectedSet = @"";
	
	switch ([(UISegmentedControl *)[self.view viewWithTag:CASE_CONTROL] selectedSegmentIndex])
	{
		case 0: // lowercase
			selectedSet = [selectedSet stringByAppendingString:ALPHA_LC];
			break;
		case 1: // mixed case
			selectedSet = [selectedSet stringByAppendingString:ALPHA_LC];
			selectedSet = [selectedSet stringByAppendingString:ALPHA_UC];
			break;
		case 2: // uppercase
			selectedSet = [selectedSet stringByAppendingString:ALPHA_UC];
			break;
		default: // should never get here
			break;
	}
	
	switch ([(DoubleTapSegmentedControl *)[self.view viewWithTag:MIX_CONTROL] selectedSegmentIndex])
	{
		case 0: // alpha only
			break;
		case 1: // add numbers
			selectedSet = [selectedSet stringByAppendingString:NUMBERS];
			break;
		case 2: // add numbers and punctuation
			selectedSet = [selectedSet stringByAppendingString:NUMBERS];
			selectedSet = [selectedSet stringByAppendingString:PUNCTUATION];
			break;
		default: // should never get here
			break;
	}
	
	NSString *result = @"";
	NSRange range;
	range.length = 1;

	int targetLength = [(DoubleTapSegmentedControl *)[self.view viewWithTag:LENGTH_CONTROL] selectedSegmentIndex] + 4;
	
	// Select n items from the selected sets to produce the password
	int i;
	for (i = 0; i < targetLength; i++)
	{
		range.location = random() % [selectedSet length];
		result = [result stringByAppendingString:[selectedSet substringWithRange:range]];
	}
	
	[(UILabel *)[self.view viewWithTag:LABEL_TEXT] setText:result];
	[(UILabel *)[self.view viewWithTag:RLABEL_TEXT] setText:result];
	
	// calculate text size
	float targetFontSize = (12 - targetLength)*3.5f + 28.0f;
	[(UILabel *)[self.view viewWithTag:LABEL_TEXT] setFont:[UIFont fontWithName:@"Verdana-Bold" size:targetFontSize]];
	[(UILabel *)[self.view viewWithTag:RLABEL_TEXT] setFont:[UIFont fontWithName:@"Verdana-Bold" size:targetFontSize]];
}

#pragma mark TappableView Delegate Methods
// Respond to a tap on the background view by generating a password
- (void) tapEnded: (TappableView *) aView;
{
	[self generatePassword];
}


#pragma mark DoubleTapSegmentedControl Delegate Methods
// Perform an action after a segment has been tapped by generating a password
- (void) performSegmentAction
{
	[self generatePassword];
}

#pragma mark UIViewController Setup Methods

- (void)loadView
{
	// Build the main view
	TappableView *contentView = [[TappableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentView.delegate = self;
	contentView.userInteractionEnabled = YES;
	contentView.image = [UIImage imageNamed:@"bg.png"];
	self.view = contentView;
	[contentView release];
	
	// Add the case control and set its delegate
	NSArray *caseItems = [NSArray arrayWithObjects:@"abc", @"aBc", @"ABC", nil];
	DoubleTapSegmentedControl *caseControl = [[DoubleTapSegmentedControl alloc] initWithItems:caseItems];
	caseControl.frame = CGRectMake(0.0f, 0.0f, 160.0f, 45.0f);
	caseControl.center = CGPointMake(80.0f, 24.0f);
	caseControl.momentary = NO;
	caseControl.selectedSegmentIndex = 1;
	caseControl.segmentedControlStyle = UISegmentedControlStyleBar;
	caseControl.tintColor = [UIColor darkGrayColor];
	caseControl.tag = CASE_CONTROL;
	caseControl.delegate = self;
	[self.view addSubview:caseControl];
	[caseControl release];

	// Add the mix control and set its delegate
	NSArray *mixItems = [NSArray arrayWithObjects:@"xyz", @"x2z", @"x%3", nil];
	DoubleTapSegmentedControl *mixControl = [[DoubleTapSegmentedControl alloc] initWithItems:mixItems];
	mixControl.frame = CGRectMake(0.0f, 0.0f, 160.0f, 45.0f);
	mixControl.center = CGPointMake(240.0f, 24.0f);
	mixControl.momentary = NO;
	mixControl.selectedSegmentIndex = 1;
	mixControl.segmentedControlStyle = UISegmentedControlStyleBar;
	mixControl.tintColor = [UIColor darkGrayColor];
	mixControl.delegate = self;
	mixControl.tag = MIX_CONTROL;
	[self.view addSubview:mixControl];
	[mixControl release];
	
	// Add the length control and set its delegate
	NSArray *lengthItems = [NSArray arrayWithObjects:@"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
	DoubleTapSegmentedControl *lengthControl = [[DoubleTapSegmentedControl alloc] initWithItems:lengthItems];
	lengthControl.frame = CGRectMake(0.0f, 0.0f, 320.0f, 45.0f);
	lengthControl.center = CGPointMake(160.0f, 460.0f - 24.0f);
	lengthControl.momentary = NO;
	lengthControl.selectedSegmentIndex = 2;
	lengthControl.segmentedControlStyle = UISegmentedControlStyleBar;
	lengthControl.tintColor = [UIColor darkGrayColor];
	lengthControl.delegate = self;
	lengthControl.tag = LENGTH_CONTROL;
	[self.view addSubview:lengthControl];
	[lengthControl release];
	
	// Add the password label
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 80.0f)];
	label.center = CGPointMake(160.0f, 460.0f / 2.0f);
	label.font = [UIFont fontWithName:@"Verdana-Bold" size:28.0f];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = UITextAlignmentCenter;
	label.tag = LABEL_TEXT;
	[self.view addSubview:label];
	[label release];

	// And add the password's reflection because without it the screen is a little too empty
	label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 80.0f)];
	label.center = CGPointMake(160.0f, 460.0f / 2.0f + 38.0f);
	label.font = [UIFont fontWithName:@"Verdana-Bold" size:28.0f];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor lightGrayColor];
	label.textAlignment = UITextAlignmentCenter;
	label.alpha = 0.2f;
	label.tag = RLABEL_TEXT;
	[label setTransform:CGAffineTransformMakeScale(1.0f, -0.90f)];
	[self.view addSubview:label];
	[label release];
	
	// Initialize with a password
	[self performSelector:@selector(generatePassword) withObject:NULL afterDelay:0.5f];
}
@end


@interface SampleAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation SampleAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	srandom(time(0));
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	PWGenController *pwgc = [[PWGenController alloc] init];
	[window addSubview:pwgc.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"SampleAppDelegate");
	[pool release];
	return retVal;
}
