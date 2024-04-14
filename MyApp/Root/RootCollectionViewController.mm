//
//  RootCollectionViewController.mm
//  MyApp
//
//  Created by Jinwoo Kim on 4/12/24.
//

#import "RootCollectionViewController.hpp"
#import "RootCollectionViewLayout.hpp"
#import "RootImageContentView.hpp"
#import "ActivityCollectionViewController.hpp"
#import <objc/message.h>
#import <objc/runtime.h>

__attribute__((objc_direct_members))
@interface RootCollectionViewController () <ActivityCollectionViewControllerDelegate>
@property (retain, readonly, nonatomic) UICollectionViewCellRegistration *cellRegistration;
@property (copy, readonly, nonatomic) NSArray<NSString *> *imageNames;
@end

@implementation RootCollectionViewController

@synthesize cellRegistration = _cellRegistration;

- (instancetype)initWithImageNames:(NSArray<NSString *> *)imageNames {
    RootCollectionViewLayout *collectionViewLayout = [RootCollectionViewLayout new];
    
    if (self = [super initWithCollectionViewLayout:collectionViewLayout]) {
        self.title = NSProcessInfo.processInfo.processName;
        _imageNames = [imageNames copy];
        
        UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonDidTrigger:)];
        self.navigationItem.rightBarButtonItem = shareBarButtonItem;
        [shareBarButtonItem release];
        
    }
    
    [collectionViewLayout release];
    return self;
}

- (void)dealloc {
    [_cellRegistration release];
    [_imageNames release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.bounces = NO;
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self cellRegistration];
}

- (UICollectionViewCellRegistration *)cellRegistration {
    if (auto cellRegistration = _cellRegistration) return cellRegistration;
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:UICollectionViewCell.class configurationHandler:^(__kindof UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        RootImageContentConfiguration *contentConfiguration = [[RootImageContentConfiguration alloc] initWithImageName:item];
        cell.contentConfiguration = contentConfiguration;
        [contentConfiguration release];
    }];
    
    _cellRegistration = [cellRegistration retain];
    return cellRegistration;
}

- (void)shareButtonDidTrigger:(UIBarButtonItem *)sender {
    UIActivityItemsConfiguration *configuration = [[UIActivityItemsConfiguration alloc] initWithObjects:@[]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItemsConfiguration:configuration];
    [configuration release];
    
    ((UIPopoverPresentationController *)activityController.presentationController).barButtonItem = sender;
    
    UICollectionView *collectionView = self.collectionView;
    CGRect bounds = collectionView.bounds;
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    RootImageContentView *contentView = (RootImageContentView *)cell.contentView;
    
    ActivityCollectionViewController *customViewController = [[ActivityCollectionViewController alloc] initWithImageNames:self.imageNames presentingIndex:indexPath.item presentingImage:contentView.imageView.image];
    customViewController.delegate = self;
    ((void (*)(id, SEL, id))objc_msgSend)(activityController, sel_registerName("setCustomViewController:"), customViewController);
    [customViewController release];
    
    ((void (*)(id, SEL, CGFloat))objc_msgSend)(activityController, sel_registerName("setCustomViewControllerSectionHeight:"), 400.f);
    ((void (*)(id, SEL, CGFloat))objc_msgSend)(activityController, sel_registerName("setCustomViewControllerVerticalInset:"), 10.f);
    
    [self presentViewController:activityController animated:YES completion:nil];
    
    UIImageView *fromImageView = contentView.imageView;
    UIImageView *toImageView = [[UIImageView alloc] initWithImage:fromImageView.image];
    
    CGRect fromFrame = [fromImageView frameInView:fromImageView.window];
    toImageView.contentMode = UIViewContentModeScaleAspectFill;
    toImageView.clipsToBounds = YES;
    toImageView.layer.cornerRadius = ((CGFloat (*)(id, SEL))objc_msgSend)(self.view.window.screen, sel_registerName("_displayCornerRadius"));
    
    [activityController.transitionCoordinator animateAlongsideTransitionInView:toImageView animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        fromImageView.hidden = YES;
        toImageView.layer.cornerRadius = 10.f;
        
        UIView *containerView = context.containerView;
        [containerView addSubview:toImageView];
        
        [UIView performWithoutAnimation:^{
            toImageView.frame = fromFrame;
            [containerView layoutIfNeeded];
        }];
        
        toImageView.frame = customViewController.targetFrameForPresentation;
    } 
                                                                    completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        fromImageView.hidden = NO;
        fromImageView.alpha = 0.f;
        
        [UIView animateWithDuration:0.2f animations:^{
            fromImageView.alpha = 1.f;
        }];
        [toImageView removeFromSuperview];
    }];
    
    [toImageView release];
    [activityController release];
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

- (void)activityCollectionViewController:(ActivityCollectionViewController *)activityCollectionViewController didScrollToIndex:(NSInteger)index {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

@end
