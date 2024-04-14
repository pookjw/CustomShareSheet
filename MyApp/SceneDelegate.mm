//
//  SceneDelegate.mm
//  MyApp
//
//  Created by Jinwoo Kim on 4/12/24.
//

#import "SceneDelegate.hpp"
#import "RootCollectionViewController.hpp"
#import "RootCollectionViewLayout.hpp"

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    
    RootCollectionViewLayout *collectionViewLayout = [RootCollectionViewLayout new];
    RootCollectionViewController *rootViewController = [[RootCollectionViewController alloc] initWithImageNames: @[
        @"0", @"1", @"2", @"3", @"4", @"5", @"6"
    ]];
    [collectionViewLayout release];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [rootViewController release];
    
//    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
//    [appearance configureWithDefaultBackground];
//    navigationController.navigationBar.scrollEdgeAppearance = appearance;
//    [appearance release];
    
    window.rootViewController = navigationController;
    [navigationController release];
    
    [window makeKeyAndVisible];
    self.window = window;
    [window release];
}

@end
