/*
 *  CMMotionManagerSim.m
 *
 *  Created by Lloyd Hughes on 10/04/2013
 *
 *  Based off of the original work by
 *  Created by Otto Chrons on 9/26/08.
 *  Copyright 2008 Seastringo Oy. All rights reserved.
 */

#import "CMMotionManagerSim.h"

// when compiling to ARM (iPhone device), hide everything and use system defaults
// if you wish to use simulation mode even on the device, remove the #if/#endif
#if !TARGET_CPU_ARM

#import <netdb.h>

#define kAccelerometerSimulationPort 10553

@implementation CMAccelerationSimulation

@synthesize acceleration;
@synthesize timestamp;

-(CMAccelerationSimulation*)init:(NSTimeInterval)aTimeStamp X:(double)ax Y:(double)ay Z:(double)az
{
	self.timestamp = aTimeStamp;
	acceleration.x = ax;
    acceleration.y = ay;
    acceleration.z = az;
    
	return self;
}
@end

@implementation CMMagneticSimulation

@synthesize magneticField;
@synthesize timestamp;

-(CMMagneticSimulation*)init:(NSTimeInterval)aTimeStamp X:(double)ax Y:(double)ay Z:(double)az
{
	self.timestamp = aTimeStamp;
	magneticField.x = ax;
    magneticField.y = ay;
    magneticField.z = az;
    
	return self;
}
@end

@implementation CMRotationSimulation

@synthesize rotationRate;
@synthesize timestamp;

-(CMRotationSimulation*)init:(NSTimeInterval)aTimeStamp X:(double)ax Y:(double)ay Z:(double)az
{
	self.timestamp = aTimeStamp;
	rotationRate.x = ax;
    rotationRate.y = ay;
    rotationRate.z = az;
    
	return self;
}
@end

@implementation CMMotionManager (Simulation)

// override the static method and return our simulated version instead

- (BOOL) isAccelerometerAvailable{
    return YES;
}

- (BOOL) isGyroAvailable{
    return YES;
}

- (BOOL) isMagnetometerAvailable{
    return YES;
}

@end

@implementation CMMotionManager (Simulation)  

// this is straight from developer guide example for multi-threaded notifications
- (void) setUpThreadingSupport {
    if ( notifications ) return;
	
    notifications      = [[NSMutableArray alloc] init];
    notificationLock   = [[NSLock alloc] init];
    notificationThread = [[NSThread currentThread] retain];
	
    notificationPort = [[NSMachPort alloc] init];
    [notificationPort setDelegate:self];
    [[NSRunLoop currentRunLoop] addPort:notificationPort
								forMode:(NSString *) kCFRunLoopCommonModes];
}

// this is straight from developer guide example


- (void)startAccelerometerUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMAccelerometerHandler)handler{
    accelHandler = [handler copy];
    accelOn = true;
}

- (void)startGyroUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMGyroHandler)handler {
    gyroHandler = [handler copy];
    gyroOn = true;
}

- (void)startMagnetometerUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMMagnetometerHandler)handler {
    magHandler = [handler copy];
    magOn = true;
}

- (BOOL) isMagnetometerActive {
    return magOn;
}

- (BOOL) isAccelerometerActive {
    return accelOn;
}

- (BOOL) isGyroActive {
    return gyroOn;
}

- (void) processNotification:(NSNotification *) notification {
    if( [NSThread currentThread] != notificationThread ) {
        // Forward the notification to the correct thread, this is the socket thread
		NSDate* date = [[NSDate alloc] init];
        [notificationLock lock];
        [notifications addObject:notification];
        [notificationLock unlock];
        [notificationPort sendBeforeDate:date
							  components:nil
									from:nil
								reserved:0];
		[date release];
    }
    else {
		// now we are in the main thread
        // Process the notification here;
		NSString *data = (NSString*)[notification object];
		
		// parse the data, no error handling!
		NSArray *components = [data componentsSeparatedByString:@","];
		
        NSString *type = [[components objectAtIndex:0] retain];
        
        if (([type isEqualToString:@"ACC: 0"]) && accelHandler && accelOn){
            
            [accelerometerData init:[[components objectAtIndex:1] doubleValue]
                                  X:[[components objectAtIndex:2] doubleValue]
                                  Y:[[components objectAtIndex:3] doubleValue]
                                  Z:[[components objectAtIndex:4] doubleValue]];
            
            accelHandler(accelerometerData, nil);
            
        }
        else if (([type isEqualToString:@"GYRO: 0"]) && gyroHandler && gyroOn){
            
            [gyroData init:[[components objectAtIndex:1] doubleValue]
                                  X:[[components objectAtIndex:2] doubleValue]
                                  Y:[[components objectAtIndex:3] doubleValue]
                                  Z:[[components objectAtIndex:4] doubleValue]];
            
            gyroHandler(gyroData, nil);
            
        }
        else if (([type isEqualToString:@"MAG: 0"]) && magHandler && magOn){
            
            [magnetometerData init:[[components objectAtIndex:1] doubleValue]
                                  X:[[components objectAtIndex:2] doubleValue]
                                  Y:[[components objectAtIndex:3] doubleValue]
                                  Z:[[components objectAtIndex:4] doubleValue]];
            
            magHandler(magnetometerData, nil);
            
        }
        else {  }
    }
}

// this is straight from developer guide example
- (void) handleMachMessage:(void *) msg {
    [notificationLock lock];
    while ( [notifications count] ) {
        NSNotification *notification = [[notifications objectAtIndex:0] retain];
        [notifications removeObjectAtIndex:0];
        [notificationLock unlock];
        [self processNotification:notification];
        [notification release];
        [notificationLock lock];
    };
    [notificationLock unlock];
}

- (void)threadLoop:(id)object
{
	char buffer[1024];
	// we never exit...
	while(1) {
		int count = recv( udpSocket, buffer, sizeof(buffer), 0 );
		if( count > 0 )
		{
			// got data, let's pass it on
			buffer[count] = 0;
			NSString *str = [[NSString alloc] initWithUTF8String:buffer];
			[[NSNotificationCenter defaultCenter]  postNotificationName:@"ThreadAccelNotification" object:str];
			[str release];
		}
		
	}
}

// initialize our version of the accelerometer
- (CMMotionManagerSim *)init
{
    [super init];
	accelerometerData = [CMAccelerationSimulation alloc];
	isExiting = false;
    gyroOn = magOn = accelOn = NO;
	
	// couldn't get the CFSocket version to work with UDP and runloop, so used Berkely sockets and a thread instead
	
	udpSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	struct sockaddr_in sin;
	memset(&sin, 0, sizeof(sin));
	// listen on all interfaces
	sin.sin_addr.s_addr = INADDR_ANY;
	sin.sin_len = sizeof(struct sockaddr_in);
	sin.sin_family = AF_INET;
	sin.sin_port = htons(kAccelerometerSimulationPort);
	
	bind(udpSocket, (const struct sockaddr*)&sin, sizeof(sin));
	
	// create a separate thread for receiving UDP packets
	thread = [[NSThread alloc] initWithTarget:self
									 selector:@selector(threadLoop:)
									   object:nil];
	[thread start];	
	
	// cross-thread communication setup
	[self setUpThreadingSupport];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(processNotification:)
	 name:@"ThreadAccelNotification"
	 object:nil];

	return self;
}

@end

#endif


