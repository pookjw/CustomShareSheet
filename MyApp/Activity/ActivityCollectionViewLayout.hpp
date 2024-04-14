//
//  ActivityCollectionViewLayout.hpp
//  MyApp
//
//  Created by Jinwoo Kim on 4/13/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActivityCollectionViewLayout : UICollectionViewCompositionalLayout
@property (assign, nonatomic, direct) BOOL appearingTransition;
+ (instancetype)new;
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
