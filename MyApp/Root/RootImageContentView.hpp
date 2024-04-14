//
//  RootImageContentView.hpp
//  MyApp
//
//  Created by Jinwoo Kim on 4/12/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface RootImageContentConfiguration : NSObject <UIContentConfiguration>
@property (copy, readonly, nonatomic) NSString *imageName;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithImageName:(NSString *)imageName NS_DESIGNATED_INITIALIZER;
@end

__attribute__((objc_direct_members))
@interface RootImageContentView : UIView <UIContentView>
@property (retain, readonly, nonatomic) UIImageView *imageView;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame contentConfiguration:(RootImageContentConfiguration *)contentConfiguration NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
