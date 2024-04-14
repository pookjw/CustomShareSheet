//
//  ActivityCollectionViewController.mm
//  MyApp
//
//  Created by Jinwoo Kim on 4/12/24.
//

#import "ActivityCollectionViewController.hpp"
#import "ActivityCollectionViewLayout.hpp"
#import "ActivityImageContentView.hpp"
#import "ActivityImageCollectionViewCell.hpp"
#import "ImageActivity.hpp"
#import <objc/message.h>
#import <objc/runtime.h>
#import <LinkPresentation/LinkPresentation.h>

__attribute__((objc_direct_members))
@interface ActivityCollectionViewController ()
@property (retain, readonly, nonatomic) UICollectionViewCellRegistration *cellRegistration;
@property (copy, readonly, nonatomic) NSArray<NSString *> *imageNames;
@property (assign, nonatomic) NSInteger presentingIndex;
@property (retain, nonatomic, nullable) UIImage *presentingImage;
@property (copy, nonatomic, nullable) NSIndexPath *lastDelegateIndexPath;
@property (readonly, nonatomic) UIActivityViewController *activityViewController;
@property (copy, nonatomic) NSOrderedSet<ImageActivity *> *imageActivities;
@end

@implementation ActivityCollectionViewController

@synthesize cellRegistration = _cellRegistration;

- (instancetype)initWithImageNames:(NSArray<NSString *> *)imageNames presentingIndex:(NSInteger)presentingIndex presentingImage:(UIImage * _Nullable)presentingImage {
    ActivityCollectionViewLayout *collectionViewLayout = [ActivityCollectionViewLayout new];
    
    if (self = [super initWithCollectionViewLayout:collectionViewLayout]) {
        _imageNames = [imageNames copy];
        _presentingIndex = presentingIndex;
        _presentingImage = [presentingImage retain];
        self.imageActivities = [NSOrderedSet orderedSet];
    }
    
    [collectionViewLayout release];
    return self;
}

- (void)dealloc {
    [_cellRegistration release];
    [_imageNames release];
    [_presentingImage release];
    [_lastDelegateIndexPath release];
    [_imageActivities release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionView *collectionView = self.collectionView;
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    collectionView.allowsMultipleSelection = YES;
    
    [self cellRegistration];
}

- (void)viewIsAppearing:(BOOL)animated {
    [super viewIsAppearing:animated];
    
    UICollectionView *collectionView = self.collectionView;
    NSInteger presentingIndex = _presentingIndex;
    UIImage *loadedImage = _presentingImage;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:presentingIndex inSection:0];
    
    if (presentingIndex != NSNotFound) {
        ((void (*)(id, SEL, id, BOOL, NSUInteger, BOOL))objc_msgSend)(collectionView, sel_registerName("_selectItemAtIndexPath:animated:scrollPosition:notifyDelegate:"), indexPath, NO, UICollectionViewScrollPositionCenteredHorizontally, NO);
        
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            ActivityCollectionViewLayout *collectionViewLayout = [ActivityCollectionViewLayout new];
            collectionViewLayout.appearingTransition = YES;
            [collectionView setCollectionViewLayout:collectionViewLayout animated:NO];
            [collectionView layoutIfNeeded];
            [collectionViewLayout release];
        }
                                                    completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            // UICollectionView Transition이 작동하지 않아서 이렇게 처리
            [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
            
            ActivityImageCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            ActivityImageContentConfiguration *oldConfiguration = cell.contentConfiguration;
            ActivityImageContentConfiguration *newConfiguretion = [[ActivityImageContentConfiguration alloc] initWithFrame:collectionView.bounds imageName:oldConfiguration.imageName forPresenting:NO loadedImage:loadedImage isSelected:cell.isSelected];
            
            cell.contentConfiguration = newConfiguretion;
            [newConfiguretion release];
            
            _presentingIndex = NSNotFound;
            _presentingImage = nil;
        }];
    }
}

- (CGRect)targetFrameForPresentation {
    UIWindow *window = self.view.window;
    
    if (window == nil) return CGRectNull;
    
    CGRect oldRect = self.view.frame;
    
    CGRect newRect = CGRectMake(CGRectGetMinX(oldRect) + ((CGRectGetWidth(oldRect) - 16.f) * 0.125f) + 8.f,
                                CGRectGetMinY(oldRect),
                                (CGRectGetWidth(oldRect) * 0.75f) - 16.f,
                                CGRectGetHeight(oldRect));
    
    return [window convertRect:newRect fromView:self.view];
}

- (UICollectionViewCellRegistration *)cellRegistration {
    if (auto cellRegistration = _cellRegistration) return cellRegistration;
    
    __weak auto weakSelf = self;
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:ActivityImageCollectionViewCell.class configurationHandler:^(__kindof ActivityImageCollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        auto loadedSelf = weakSelf;
        NSInteger presentingIndex = loadedSelf.presentingIndex;
        BOOL forPresenting;
        UIImage * _Nullable loadedImage;
        
        if (presentingIndex == NSNotFound) {
            forPresenting = NO;
            loadedImage = nil;
        } else if (presentingIndex == indexPath.item) {
            forPresenting = YES;
            loadedImage = loadedSelf.presentingImage;
        } else {
            forPresenting = NO;
            loadedImage = nil;
        }
        
        ActivityImageContentConfiguration *contentConfiguration = [[ActivityImageContentConfiguration alloc] initWithFrame:cell.bounds imageName:item forPresenting:forPresenting loadedImage:loadedImage isSelected:cell.isSelected];
        cell.contentConfiguration = contentConfiguration;
        [contentConfiguration release];
    }];
    
    _cellRegistration = [cellRegistration retain];
    return cellRegistration;
}

- (UIActivityViewController *)activityViewController {
    __kindof UIViewController *activityContentViewController = self.parentViewController;
    id presenter = ((id (*)(id, SEL))objc_msgSend)(activityContentViewController, sel_registerName("presenter"));
    id router = ((id (*)(id, SEL))objc_msgSend)(presenter, sel_registerName("router"));
    UIActivityViewController *activityViewController = ((id (*)(id, SEL))objc_msgSend)(router, sel_registerName("rootViewController"));
    
    return activityViewController;
}

- (void)setImageActivities:(NSOrderedSet<ImageActivity *> *)imageActivities {
    [_imageActivities release];
    _imageActivities = [imageActivities copy];
    
    UIActivityViewController *activityViewController = self.activityViewController;
    
    ((void (*)(id, SEL, id))objc_msgSend)(activityViewController, sel_registerName("_updateActivityItems:"), imageActivities.array);
    
    id headerTitleView = ((id (*)(id, SEL))objc_msgSend)(self.parentViewController, sel_registerName("headerTitleView"));
    LPLinkView *linkView = ((id (*)(id, SEL))objc_msgSend)(headerTitleView, sel_registerName("linkView"));
    
    LPLinkMetadata *metadata = [LPLinkMetadata new];
    
    if (ImageActivity *imageActivity = imageActivities.lastObject) {
        NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:imageActivity.image];
        metadata.imageProvider = itemProvider;
        [itemProvider release];
    }
    
    if (imageActivities.count > 1) {
        metadata.title = [NSString stringWithFormat:@"%ld images selected", imageActivities.count];
    } else {
        metadata.title = @"Image";
    }
    
    linkView.metadata = metadata;
    [metadata release];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageNames.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueConfiguredReusableCellWithRegistration:self.cellRegistration forIndexPath:indexPath item:self.imageNames[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ActivityImageCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSString *imageName;
    
    if (NSString *_imageName = ((ActivityImageContentConfiguration *)cell.contentConfiguration).imageName) {
        imageName = _imageName;
    } else {
        imageName = self.imageNames[indexPath.item];
    }
    
    NSOrderedSet<ImageActivity *> *imageActivites = self.imageActivities;
    for (ImageActivity *imageActivity in imageActivites) {
        if ([imageName isEqualToString:imageActivity.imageName]) return;
    }
    
    UIImage * _Nullable image = ((ActivityImageContentView *)cell.contentView).imageView.image;
    NSMutableOrderedSet *mutableImageActivity = [imageActivites mutableCopy];
    ImageActivity *imageActivity = [[ImageActivity alloc] initWithImage:image imageName:imageName];
    [mutableImageActivity addObject:imageActivity];
    [imageActivity release];
    
    self.imageActivities = mutableImageActivity;
    [mutableImageActivity release];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.indexPathsForSelectedItems.count > 1;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ActivityImageCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSString *imageName = ((ActivityImageContentConfiguration *)cell.contentConfiguration).imageName;
    
    NSOrderedSet<ImageActivity *> *imageActivites = self.imageActivities;
    __block NSInteger index = NSNotFound;
    [imageActivites enumerateObjectsUsingBlock:^(ImageActivity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.imageName isEqualToString:imageName]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    if (index == NSNotFound) return;
    
    
    
    NSMutableOrderedSet *mutableImageActivity = [imageActivites mutableCopy];
    [mutableImageActivity removeObjectAtIndex:index];
    
    self.imageActivities = mutableImageActivity;
    [mutableImageActivity release];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UICollectionView *collectionView = self.collectionView;
    if (![collectionView isEqual:scrollView]) return;
    
    for (ActivityImageCollectionViewCell *cell in collectionView.visibleCells) {
        [cell setNeedsUpdateConfiguration];
    }
    
    if (auto delegate = self.delegate) {
        if (self.transitionCoordinator) {
            return;
        }
        
        if (delegate == nil) return;
        
        CGPoint contentOffset = collectionView.contentOffset;
        CGRect bounds = collectionView.bounds;
        CGPoint center = CGPointMake(contentOffset.x + CGRectGetWidth(bounds) * 0.5f,
                                     contentOffset.y + CGRectGetHeight(bounds) * 0.5f);
        
        NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:center];
        
        if (indexPath == nil) return;
        if ([self.lastDelegateIndexPath isEqual:indexPath]) return;
        
        self.lastDelegateIndexPath = indexPath;
        [delegate activityCollectionViewController:self didScrollToIndex:indexPath.item];
    }
}

@end
