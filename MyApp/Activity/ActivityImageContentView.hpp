//
//  ActivityImageContentView.hpp
//  MyApp
//
//  Created by Jinwoo Kim on 4/13/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ActivityImageContentConfiguration : NSObject <UIContentConfiguration>
@property (assign, readonly) CGRect frame;
@property (copy, readonly, nonatomic) NSString *imageName;
@property (assign, readonly, nonatomic) BOOL forPresenting;
@property (retain, readonly, nonatomic, nullable) UIImage *loadedImage;
@property (assign, readonly, nonatomic) BOOL isSelected;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName forPresenting:(BOOL)forPresenting loadedImage:(UIImage * _Nullable)loadedImage isSelected:(BOOL)isSelected NS_DESIGNATED_INITIALIZER;
@end

__attribute__((objc_direct_members))
@interface ActivityImageContentView : UIView <UIContentView>
@property (retain, readonly, nonatomic) UIImageView *imageView;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame contentConfiguration:(ActivityImageContentConfiguration *)contentConfiguration NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
