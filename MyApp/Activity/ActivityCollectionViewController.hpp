//
//  ActivityCollectionViewController.hpp
//  MyApp
//
//  Created by Jinwoo Kim on 4/12/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ActivityCollectionViewController;
@protocol ActivityCollectionViewControllerDelegate <NSObject>
- (void)activityCollectionViewController:(ActivityCollectionViewController *)activityCollectionViewController didScrollToIndex:(NSInteger)index;
@end

__attribute__((objc_direct_members))
@interface ActivityCollectionViewController : UICollectionViewController
@property (assign, readonly, nonatomic) CGRect targetFrameForPresentation;
@property (weak, nonatomic) id<ActivityCollectionViewControllerDelegate> delegate;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithImageNames:(NSArray<NSString *> *)imageNames presentingIndex:(NSInteger)presentingIndex presentingImage:(UIImage * _Nullable)presentingImage NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
