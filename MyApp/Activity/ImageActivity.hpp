//
//  ImageActivity.hpp
//  MyApp
//
//  Created by Jinwoo Kim on 4/14/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ImageActivity : NSObject <UIActivityItemSource, NSCopying>
@property (copy, readonly, nonatomic) NSString *imageName;
@property (retain, readonly, nonatomic) UIImage *image;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithImage:(UIImage * _Nullable)image imageName:(NSString *)imageName NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
