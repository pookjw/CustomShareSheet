//
//  ActivityCollectionViewLayout.mm
//  MyApp
//
//  Created by Jinwoo Kim on 4/13/24.
//

#import "ActivityCollectionViewLayout.hpp"
#import <objc/runtime.h>
#import <objc/message.h>

OBJC_EXPORT id objc_msgSendSuper2(void);

@interface ActivityCollectionViewLayout ()
@end

@implementation ActivityCollectionViewLayout

- (instancetype)init {
    UICollectionViewCompositionalLayoutConfiguration *configuration = [UICollectionViewCompositionalLayoutConfiguration new];
    configuration.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    configuration.contentInsetsReference = UIContentInsetsReferenceNone;
    
    __weak auto weakSelf = self;
    
    self = [super initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
        BOOL appearingTransition = !weakSelf.appearingTransition;
        
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f] 
                                                                          heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1.f]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize
                                                               supplementaryItems:@[]];
        
        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.75f] 
                                                                           heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1.f]];
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:groupSize subitems:@[item]];
        
        CGSize contentSize = layoutEnvironment.container.contentSize;
        CGFloat padding = (contentSize.width - 16.f) * 0.125f;
        
        NSCollectionLayoutEdgeSpacing *edgeSpacing;
        if (appearingTransition) {
            
            edgeSpacing = [NSCollectionLayoutEdgeSpacing spacingForLeading:[NSCollectionLayoutSpacing fixedSpacing:padding]
                                                                       top:[NSCollectionLayoutSpacing fixedSpacing:0.f]
                                                                  trailing:[NSCollectionLayoutSpacing fixedSpacing:padding]
                                                                    bottom:[NSCollectionLayoutSpacing fixedSpacing:0.f]];
        } else {
            edgeSpacing = [NSCollectionLayoutEdgeSpacing spacingForLeading:[NSCollectionLayoutSpacing fixedSpacing:0.f]
                                                                       top:[NSCollectionLayoutSpacing fixedSpacing:0.f]
                                                                  trailing:[NSCollectionLayoutSpacing fixedSpacing:0.f]
                                                                    bottom:[NSCollectionLayoutSpacing fixedSpacing:0.f]];
        }
        
        group.edgeSpacing = edgeSpacing;
        group.contentInsets = NSDirectionalEdgeInsetsMake(0.f, 8.f, 0.f, 8.f);
        
        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        
        if (!appearingTransition) {
            section.contentInsets = NSDirectionalEdgeInsetsMake(0.f,
                                                                padding,
                                                                0.f,
                                                                padding);
        }
        
        return section;
    } 
                            configuration:configuration];
    
    [configuration release];
    
    return self;
}

- (CGPoint)transitionContentOffsetForProposedContentOffset:(CGPoint)contentOffset keyItemIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *targetLayoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    CGPoint result = CGPointMake(CGRectGetMinX(targetLayoutAttributes.frame) - 8.f - (CGRectGetWidth(self.collectionView.bounds) - 16.f) * 0.125f,
                        0.f);
    
    return result;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    UICollectionView *collectionView = self.collectionView;
    
    CGPoint contentOffset = collectionView.contentOffset;
    CGRect bounds = collectionView.bounds;
    CGRect contentRect = CGRectMake(contentOffset.x, contentOffset.y, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    CGPoint center = CGPointMake(contentOffset.x + CGRectGetWidth(bounds) * 0.5f, contentOffset.y + CGRectGetHeight(bounds) * 0.5f);
    
    NSArray<__kindof UICollectionViewLayoutAttributes *> *layoutAttributesArray = [self layoutAttributesForElementsInRect:contentRect];
    NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *leftLayoutAttributesArray = [NSMutableArray array];
    NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *rightLayoutAttributesArray = [NSMutableArray array];
    
    for (__kindof UICollectionViewLayoutAttributes *layoutAttributes in layoutAttributesArray) {
        CGFloat dist = CGRectGetMidX(layoutAttributes.frame) - center.x;
        
        if (dist < 0.f) {
            [leftLayoutAttributesArray addObject:layoutAttributes];
        } else {
            [rightLayoutAttributesArray addObject:layoutAttributes];
        }
    }
    
    [leftLayoutAttributesArray sortUsingComparator:^NSComparisonResult(__kindof UICollectionViewLayoutAttributes *obj1, __kindof UICollectionViewLayoutAttributes *obj2) {
        CGFloat obj1X = CGRectGetMaxX(obj1.frame);
        CGFloat obj2X = CGRectGetMaxX(obj2.frame);
        
        if (obj1X < obj2X) {
            return NSOrderedAscending;
        } else if (obj1X > obj2X) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    [rightLayoutAttributesArray sortUsingComparator:^NSComparisonResult(__kindof UICollectionViewLayoutAttributes *obj1, __kindof UICollectionViewLayoutAttributes *obj2) {
        CGFloat obj1X = CGRectGetMaxX(obj1.frame);
        CGFloat obj2X = CGRectGetMaxX(obj2.frame);
        
        if (obj1X < obj2X) {
            return NSOrderedAscending;
        } else if (obj1X > obj2X) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    __kindof UICollectionViewLayoutAttributes *leftLayoutAttributes = leftLayoutAttributesArray.lastObject;
    __kindof UICollectionViewLayoutAttributes *rightLayoutAttributes = rightLayoutAttributesArray.firstObject;
    
    CGPoint (^leftContentOffset)() = ^CGPoint {
        return CGPointMake(CGRectGetMinX(leftLayoutAttributes.frame) - (CGRectGetWidth(bounds) - 20.f) * 0.125f - 10.f,
                                               contentOffset.y);
    };
    CGPoint (^rightContentOffset)() = ^CGPoint {
        return CGPointMake(CGRectGetMinX(rightLayoutAttributes.frame) - (CGRectGetWidth(bounds) - 20.f) * 0.125f - 10.f,
                                           contentOffset.y);
    };
    
    if (leftLayoutAttributes == nil && rightLayoutAttributes == nil) {
        return proposedContentOffset;
    } else if (leftLayoutAttributes == nil) {
        return rightContentOffset();
    } else if (rightLayoutAttributes == nil) {
        return leftContentOffset();
    }
    
    if (velocity.x > 0.f) {
        return rightContentOffset();
    } else if (velocity.x < 0.f) {
        return leftContentOffset();
    } else {
        CGFloat leftDist = abs(CGRectGetMaxX(leftLayoutAttributes.frame) - center.x);
        CGFloat rightDist = abs(CGRectGetMinX(rightLayoutAttributes.frame) - center.x);
        
        if (leftDist < rightDist) {
            return leftContentOffset();
        } else {
            return rightContentOffset();
        }
    }
}

@end
