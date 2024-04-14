//
//  ActivityImageCollectionViewCell.mm
//  MyApp
//
//  Created by Jinwoo Kim on 4/14/24.
//

#import "ActivityImageCollectionViewCell.hpp"
#import <objc/message.h>
#import <objc/runtime.h>

UIConfigurationStateCustomKey const ActivityImageCollectionViewCellCollectionViewStateKey = @"collectionView";

@implementation ActivityImageCollectionViewCell

- (UICellConfigurationState *)configurationState {
    UICellConfigurationState *configurationState = [super configurationState];
    
    UICollectionView *collectionView = ((id (*)(id, SEL))objc_msgSend)(self, sel_registerName("_collectionView"));
    __kindof NSValue *weakObjectValue = ((id (*)(id, SEL, id))objc_msgSend)([objc_lookUpClass("NSWeakObjectValue") alloc], sel_registerName("initWithObject:"), collectionView);
    
    [configurationState setObject:weakObjectValue forKeyedSubscript:ActivityImageCollectionViewCellCollectionViewStateKey];
    [weakObjectValue release];
    
    return configurationState;
}

@end
