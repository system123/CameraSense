/*
 *  CMMotionManagerSim.h
 *
 *  Created by Lloyd Hughes on 10/04/2013
 *
 *  Based off of the original work by
 *  Created by Otto Chrons on 9/26/08.
 *  Copyright 2008 Seastringo Oy. All rights reserved.
 *
 */
#import <TargetConditionals.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

// when compiling to ARM (iPhone device), hide everything and use system defaults
// if you wish to use simulation mode even on the device, remove the #if/#endif
#if !TARGET_CPU_ARM

@interface CMAccelerationSimulation: CMAccelerometerData
{
    NSTimeInterval timestamp;
	CMAcceleration acceleration;
}
@property(readwrite, nonatomic) CMAcceleration acceleration;
@property (readwrite, nonatomic) NSTimeInterval timestamp;

@end

@interface CMMagneticSimulation: CMMagnetometerData
{
    NSTimeInterval timestamp;
	CMMagneticField magneticField;
}
@property(readwrite, nonatomic) CMMagneticField magneticField;
@property (readwrite, nonatomic) NSTimeInterval timestamp;

@end

@interface CMRotationSimulation: CMGyroData
{
    NSTimeInterval timestamp;
	CMRotationRate rotationRate;
}
@property(readwrite, nonatomic) CMRotationRate rotationRate;
@property (readwrite, nonatomic) NSTimeInterval timestamp;

@end

@interface CMMotionManager (Simulation)
@property(readonly, nonatomic, getter=isAccelerometerAvailable) BOOL accelerometerAvailable;
@property(readonly, nonatomic, getter=isGyroAvailable) BOOL gyroAvailable;
@property(readonly, nonatomic, getter=isMagnetometerAvailable) BOOL magnetometerAvailable;

- (BOOL) isAccelerometerAvailable;
- (BOOL) isGyroAvailable;
- (BOOL) isMagnetometerAvailable;

@end

@interface CMMotionManager (Simulation) <NSMachPortDelegate>
{

	//CFSocketRef udpSocket;
	int udpSocket;
    
    BOOL gyroOn, accelOn, magOn;
    
	NSThread *thread;
	BOOL isExiting;
	CMAccelerationSimulation *accelerometerData;
    CMRotationSimulation *gyroData;
    CMMagneticSimulation *magnetometerData;

    // Threaded notification support 
    NSMutableArray *notifications;
    NSThread *notificationThread;
    NSLock *notificationLock;
    NSMachPort *notificationPort;
    __block CMAccelerometerHandler accelHandler;
    __block CMGyroHandler gyroHandler;
    __block CMMagnetometerHandler magHandler;
}

@property(readwrite, assign) CMAccelerationSimulation *accelerometerData;
@property(readwrite, assign) CMRotationSimulation *gyroData;
@property(readwrite, assign) CMMagneticSimulation *magnetometerData;

- (void)startAccelerometerUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMAccelerometerHandler)handler;
- (void)startGyroUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMGyroHandler)handler;
- (void)startMagnetometerUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMMagnetometerHandler)handler;

- (void) setUpThreadingSupport;
- (void) handleMachMessage:(void *) msg;
- (void) processNotification:(NSNotification *) notification;
- (CMMotionManagerSim *)init;

- (BOOL) isMagnetometerActive;
- (BOOL) isAccelerometerActive;
- (BOOL) isGyroActive;

@end

#endif
