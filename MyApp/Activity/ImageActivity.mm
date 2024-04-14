//
//  ImageActivity.mm
//  MyApp
//
//  Created by Jinwoo Kim on 4/14/24.
//

#import "ImageActivity.hpp"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

__attribute__((objc_direct_members))
@interface ImageActivity ()
@end

@implementation ImageActivity

- (instancetype)initWithImage:(UIImage *)image imageName:(NSString *)imageName {
    if (self = [super init]) {
        _imageName = [imageName copy];
        
        if (image) {
            _image = [image retain];
        } else {
            _image = [[UIImage imageNamed:imageName] retain];
        }
    }
    
    return self;
}

- (void)dealloc {
    [_image release];
    [_imageName release];
    [super dealloc];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return [_imageName isEqualToString:((ImageActivity *)other)->_imageName];
    }
}

- (NSUInteger)hash {
    return _imageName.hash;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    __kindof ImageActivity *copy = [[self class] new];
    
    if (copy) {
        copy->_imageName = [_imageName copy];
        copy->_image = [_image retain];
    }
    
    return copy;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return _image;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
    return _image;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType {
    return _imageName;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(UIActivityType)activityType {
    return [UTTypeImage identifier];
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(UIActivityType)activityType suggestedSize:(CGSize)size {
    return _image;
}

@end
