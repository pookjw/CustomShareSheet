//
//  ActivityImageContentView.mm
//  MyApp
//
//  Created by Jinwoo Kim on 4/13/24.
//

#import "ActivityImageContentView.hpp"
#import "ActivityImageCollectionViewCell.hpp"
#import <objc/message.h>
#import <objc/runtime.h>

__attribute__((objc_direct_members))
@interface ActivityImageContentConfiguration ()
@property (weak, nonatomic) UICollectionView * _Nullable collectionView;
@end

@implementation ActivityImageContentConfiguration

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName forPresenting:(BOOL)forPresenting loadedImage:(UIImage * _Nullable)loadedImage isSelected:(BOOL)isSelected {
    if (self = [super init]) {
        _frame = frame;
        _imageName = [imageName copy];
        _forPresenting = forPresenting;
        _loadedImage = [loadedImage retain];
        _isSelected = isSelected;
    }
    
    return self;
}

- (void)dealloc {
    [_imageName release];
    [_loadedImage release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    __kindof ActivityImageContentConfiguration *copy = [[self class] new];
    
    if (copy) {
        copy->_frame = _frame;
        copy->_imageName = [_imageName copy];
        copy->_forPresenting = _forPresenting;
        copy->_loadedImage = [_loadedImage retain];
        copy->_isSelected = _isSelected;
        copy->_collectionView = _collectionView;
    }
    
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        ActivityImageContentConfiguration *_other = other;
        return CGRectEqualToRect(_frame, _other->_frame) && 
        [_imageName isEqualToString:_other->_imageName] && 
        _forPresenting == _other->_forPresenting && 
        [_loadedImage isEqual:_other->_loadedImage] &&
        _isSelected == _other->_isSelected;
    }
}

- (NSUInteger)hash {
    return [NSValue valueWithCGRect:_frame].hash ^
    _imageName.hash ^
    _forPresenting ^
    _loadedImage.hash ^
    _isSelected;
}

- (nonnull __kindof UIView<UIContentView> *)makeContentView { 
    return [[[ActivityImageContentView alloc] initWithFrame:_frame contentConfiguration:self] autorelease];
}

- (nonnull instancetype)updatedConfigurationForState:(nonnull id<UIConfigurationState>)state {
    ActivityImageContentConfiguration *copy = [self copy];
    copy->_isSelected = ((UICellConfigurationState *)state).isSelected;
    
    __kindof NSValue *weakObjectValue = state[ActivityImageCollectionViewCellCollectionViewStateKey];
    copy->_collectionView = ((id (*)(id, SEL))objc_msgSend)(weakObjectValue, sel_registerName("weakObjectValue"));
    
    return [copy autorelease];
}

@end

__attribute__((objc_direct_members))
@interface ActivityImageContentView ()
@property (copy, nonatomic) ActivityImageContentConfiguration *contentConfiguration;
@property (retain, nonatomic) UIImageView *selectedImageView;
@property (retain, nonatomic) NSLayoutConstraint *selectedImageViewTrailingConstraint;
@end

@implementation ActivityImageContentView

@synthesize imageView = _imageView;
@synthesize selectedImageView = _selectedImageView;

- (instancetype)initWithFrame:(CGRect)frame contentConfiguration:(ActivityImageContentConfiguration *)contentConfiguration {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10.f;
        
        UIImageView *imageView = self.imageView;
        [self addSubview:imageView];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        UIImageView *selectedImageView = self.selectedImageView;
        [self addSubview:selectedImageView];
        selectedImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *selectedImageViewTrailingConstraint = [selectedImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8.f];
        
        [NSLayoutConstraint activateConstraints:@[
            [selectedImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8.f],
            selectedImageViewTrailingConstraint,
            [selectedImageView.widthAnchor constraintEqualToConstant:30.f],
            [selectedImageView.heightAnchor constraintEqualToConstant:30.f]
        ]];
        
        self.contentConfiguration = contentConfiguration;
        self.selectedImageViewTrailingConstraint = selectedImageViewTrailingConstraint;
    }
    
    return self;
}

- (void)dealloc {
    [_contentConfiguration release];
    [_imageView release];
    [_selectedImageView release];
    [_selectedImageViewTrailingConstraint release];
    [super dealloc];
}

- (id<UIContentConfiguration>)configuration {
    return _contentConfiguration;
}

- (void)setConfiguration:(id<UIContentConfiguration>)configuration {
    self.contentConfiguration = configuration;
}

- (BOOL)supportsConfiguration:(id<UIContentConfiguration>)configuration {
    return [configuration isKindOfClass:ActivityImageContentConfiguration.class];
}

- (void)setContentConfiguration:(ActivityImageContentConfiguration *)contentConfiguration {
    ActivityImageContentConfiguration *oldContentConfiguration = [[_contentConfiguration retain] autorelease];
    [_contentConfiguration release];
    
    ActivityImageContentConfiguration *copy = [contentConfiguration copy];
    _contentConfiguration = copy;
    
    //
    
    UICollectionView *collectionView = copy.collectionView;
    CGPoint contentOffset = collectionView.contentOffset;
    
    CGRect frameInCollectionView = [self convertRect:self.bounds toCoordinateSpace:collectionView];
    frameInCollectionView.origin = CGPointMake(frameInCollectionView.origin.x - contentOffset.x,
                                               frameInCollectionView.origin.y - contentOffset.y);
    
    CGFloat selectedImageViewXPosInCollectionView = (CGRectGetMaxX(frameInCollectionView) - 8.f - 30.f);
    CGFloat maxXInCollectionView = CGRectGetWidth(collectionView.bounds);
    
    self.selectedImageViewTrailingConstraint.constant = MAX(MIN(maxXInCollectionView - selectedImageViewXPosInCollectionView - 46.f, -8.f), -CGRectGetWidth(self.bounds) + 38.f);
    
    //
    
    UIImageView *selectedImageView = self.selectedImageView;
    
    NSSymbolEffectOptions *transitionOptions = [NSSymbolEffectOptions optionsWithNonRepeating];
    ((void (*)(id, SEL, CGFloat))objc_msgSend)(transitionOptions, sel_registerName("set_speed:"), 1.5f);
    
    if (copy.isSelected) {
        [selectedImageView setSymbolImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]
                    withContentTransition:[[NSSymbolReplaceContentTransition replaceUpUpTransition] transitionWithByLayer]
                                  options:transitionOptions];
    } else {
        [selectedImageView setSymbolImage:[UIImage systemImageNamed:@"circle"]
                    withContentTransition:[[NSSymbolReplaceContentTransition replaceDownUpTransition] transitionWithByLayer]
                                  options:transitionOptions];
    }
    
    UIImageView *imageView = self.imageView;
    
    if ((![oldContentConfiguration.imageName isEqualToString:copy.imageName]) || (oldContentConfiguration.forPresenting != copy.forPresenting)) {
        if (copy.forPresenting) {
            imageView.image = nil;
            imageView.hidden = YES;
        } else if (UIImage *loadedImage = copy.loadedImage) {
            imageView.image = loadedImage;
            imageView.hidden = NO;
        } else {
            UIImage *image = [UIImage imageNamed:copy.imageName];
            
            imageView.image = nil;
            imageView.hidden = NO;
            
            [image prepareForDisplayWithCompletionHandler:^(UIImage * _Nullable preparedImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.contentConfiguration.imageName isEqualToString:copy.imageName]) {
                        imageView.image = preparedImage;
                        imageView.alpha = 0.f;
                        
                        [UIView animateWithDuration:0.2f animations:^{
                            imageView.alpha = 1.f;
                        }];
                    }
                });
            }];
        }
    }
}

- (UIImageView *)imageView {
    if (auto imageView = _imageView) return imageView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _imageView = [imageView retain];
    return [imageView autorelease];
}

- (UIImageView *)selectedImageView {
    if (auto selectedImageView = _selectedImageView) return selectedImageView;
    
    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectNull];
    selectedImageView.backgroundColor = UIColor.clearColor;
    selectedImageView.layer.shadowColor = UIColor.blackColor.CGColor;
    selectedImageView.layer.shadowRadius = 8.f;
    selectedImageView.layer.shadowOpacity = 0.5f;
    selectedImageView.layer.shadowOffset = CGSizeZero;
    
    _selectedImageView = [selectedImageView retain];
    return [selectedImageView autorelease];
}

@end
