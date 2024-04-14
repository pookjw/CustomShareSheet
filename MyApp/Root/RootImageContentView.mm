//
//  RootImageContentView.mm
//  MyApp
//
//  Created by Jinwoo Kim on 4/12/24.
//

#import "RootImageContentView.hpp"

__attribute__((objc_direct_members))
@interface RootImageContentConfiguration ()
@end

@implementation RootImageContentConfiguration

- (instancetype)initWithImageName:(NSString *)imageName {
    if (self = [super init]) {
        _imageName = [imageName copy];
    }
    
    return self;
}

- (void)dealloc {
    [_imageName release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    __kindof RootImageContentConfiguration *copy = [[self class] new];
    
    if (copy) {
        copy->_imageName = [_imageName copy];
    }
    
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        RootImageContentConfiguration *_other = other;
        return [_imageName isEqualToString:_other->_imageName];
    }
}

- (NSUInteger)hash {
    return _imageName.hash;
}

- (nonnull __kindof UIView<UIContentView> *)makeContentView { 
    return [[[RootImageContentView alloc] initWithFrame:CGRectNull contentConfiguration:self] autorelease];
}

- (nonnull instancetype)updatedConfigurationForState:(nonnull id<UIConfigurationState>)state { 
    return self;
}

@end

__attribute__((objc_direct_members))
@interface RootImageContentView ()
@property (copy, nonatomic) RootImageContentConfiguration *contentConfiguration;
@end

@implementation RootImageContentView

@synthesize imageView = _imageView;

- (instancetype)initWithFrame:(CGRect)frame contentConfiguration:(RootImageContentConfiguration *)contentConfiguration {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        
        UIImageView *imageView = self.imageView;
        [self addSubview:imageView];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        self.contentConfiguration = contentConfiguration;
    }
    
    return self;
}

- (void)dealloc {
    [_contentConfiguration release];
    [_imageView release];
    [super dealloc];
}

- (id<UIContentConfiguration>)configuration {
    return _contentConfiguration;
}

- (void)setConfiguration:(id<UIContentConfiguration>)configuration {
    self.contentConfiguration = configuration;
}

- (BOOL)supportsConfiguration:(id<UIContentConfiguration>)configuration {
    return [configuration isKindOfClass:RootImageContentConfiguration.class];
}

- (void)setContentConfiguration:(RootImageContentConfiguration *)contentConfiguration {
    if ([_contentConfiguration isEqual:contentConfiguration]) return;
    
    [_contentConfiguration release];
    
    RootImageContentConfiguration *copy = [contentConfiguration copy];
    _contentConfiguration = copy;
    
    UIImageView *imageView = self.imageView;
    UIImage *image = [UIImage imageNamed:copy.imageName];
    
    imageView.image = nil;
    [image prepareForDisplayWithCompletionHandler:^(UIImage * _Nullable preparedImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.contentConfiguration isEqual:copy]) {
                imageView.image = preparedImage;
                imageView.alpha = 0.f;
                
                [UIView animateWithDuration:0.2f animations:^{
                    imageView.alpha = 1.f;
                }];
            }
        });
    }];
}

- (UIImageView *)imageView {
    if (auto imageView = _imageView) return imageView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _imageView = [imageView retain];
    return [imageView autorelease];
}

@end
