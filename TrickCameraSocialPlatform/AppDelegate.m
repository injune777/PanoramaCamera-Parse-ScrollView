
#import "AppDelegate.h"

//Parse和Facebook-SDK4用
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <FBSDKCoreKit/FBSDKMacros.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)saveContext{
    
}
-(void)applicationDocumentsDirectory
{

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Parse的Key
    [Parse setApplicationId:@"ZMlDMw8mc4Q1GhllcZBWfYbvjGA8IH9xZR38OX6j"
                  clientKey:@"tchA8NA7eLageY5gq22avCT5VZz8bVuNt9Xeb8SK"];
    //初始化
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//Parse和Facebook-SDK4用Method
-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}
//Parse和Facebook-SDK4用Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}




@end
