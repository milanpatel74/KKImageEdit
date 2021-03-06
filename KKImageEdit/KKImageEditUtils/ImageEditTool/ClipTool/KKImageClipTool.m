//
//  ClippingTool.m
//
//  Created by finger on 2015/10/18.
//  Copyright (c) 2015年 finger. All rights reserved.
//

#import "KKImageClipTool.h"
#import "UIImage+Extension.h"

static NSString* const kClippingToolRatioValue1 = @"value1";
static NSString* const kClippingToolRatioValue2 = @"value2";
static NSString* const kClippingToolRatioTitleFormat = @"titleFormat";

#pragma mark- UI components

@interface ClippingCircle : UIView
{
    
}

@property (nonatomic) UIColor *bgColor;

@end

@implementation ClippingCircle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.clipsToBounds = YES ;
        self.backgroundColor = [UIColor clearColor];
    }
    return self ;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    
    CGContextSetFillColorWithColor(context, _bgColor.CGColor);
    CGContextFillEllipseInRect(context, rct);
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor ;
    
    [self setNeedsDisplay];
}

@end

@interface GridLayar : CALayer
{
    
}

@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;

@end

@implementation GridLayar

+ (BOOL)needsDisplayForKey:(NSString*)key
{
    if ([key isEqualToString:@"clippingRect"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    
    if(self && [layer isKindOfClass:[GridLayar class]]){
        self.bgColor   = ((GridLayar*)layer).bgColor;
        self.gridColor = ((GridLayar*)layer).gridColor;
        self.clippingRect = ((GridLayar*)layer).clippingRect;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rct = self.bounds;
    
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillRect(context, rct);
    
    CGContextClearRect(context, _clippingRect);
    
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextSetLineWidth(context, 0.7);
    
    rct = self.clippingRect;
    
    CGContextBeginPath(context);
    CGFloat dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x+dW, rct.origin.y);
        CGContextAddLineToPoint(context, rct.origin.x+dW, rct.origin.y+rct.size.height);
        dW += _clippingRect.size.width/3;
    }
    
    dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW);
        CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW);
        dW += rct.size.height/3;
    }
    CGContextStrokePath(context);
}

@end


@interface RatioUnit : NSObject
{
    CGFloat _longSide;
    CGFloat _shortSide;
}

@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, readonly) CGFloat ratio;
@property (nonatomic, strong) NSString *titleFormat;

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2;

@end

@implementation RatioUnit

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2
{
    self = [super init];
    if(self){
        _longSide  = MAX(fabs(value1), fabs(value2));
        _shortSide = MIN(fabs(value1), fabs(value2));
    }
    return self;
}

- (NSString*)description
{
    NSString *format = (self.titleFormat) ? self.titleFormat : @"%g : %g";
    
    if(self.isLandscape){
        return [NSString stringWithFormat:format, _longSide, _shortSide];
    }
    return [NSString stringWithFormat:format, _shortSide, _longSide];
}

- (CGFloat)ratio
{
    if(_longSide==0 || _shortSide==0){
        return 0;
    }
    
    if(self.isLandscape){
        return _shortSide / (CGFloat)_longSide;
    }
    
    return _longSide / (CGFloat)_shortSide;
}

@end


@interface RatioMenuItem : UIView
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) UIImage *iconImage;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, readonly) UIImageView *iconView;
@property (nonatomic, strong) RatioUnit *ratioUnit;

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

- (void)changeOrientation;

@end

@implementation RatioMenuItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 5.0f ;
        
        CGFloat W = frame.size.width;
        CGFloat H = frame.size.height ;
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, W, H-20)];
        _iconView.clipsToBounds = YES;
        _iconView.layer.cornerRadius = 5;
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _iconView.frame.origin.y + _iconView.frame.size.height + 2, W, 18)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
    self = [self initWithFrame:frame];
    if(self){
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (NSString*)title
{
    return _titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (UIImage*)iconImage
{
    return _iconView.image;
}

- (void)setIconImage:(UIImage *)iconImage
{
    _iconView.image = iconImage;
}

- (void)setRatioUnit:(RatioUnit *)ratioUnit
{
    if(ratioUnit != _ratioUnit){
        _ratioUnit = ratioUnit;
        [self refreshViews];
    }
}

- (void)refreshViews
{
    _titleLabel.text = [_ratioUnit description];
    
    CGPoint center = _iconView.center;
    CGFloat W, H;
    if(_ratioUnit.ratio!=0){
        
        if(_ratioUnit.isLandscape){
            W = 35;
            H = 35*_ratioUnit.ratio;
        }else{
            W = 35/_ratioUnit.ratio;
            H = 35;
        }
        
    }else{
        
        CGFloat maxW  = MAX(_iconView.image.size.width, _iconView.image.size.height);
        W = 35 * _iconView.image.size.width / maxW;
        H = 35 * _iconView.image.size.height / maxW;
        
    }
    _iconView.frame = CGRectMake(center.x-W/2, center.y-H/2, W, H);
}

- (void)changeOrientation
{
    self.ratioUnit.isLandscape = !self.ratioUnit.isLandscape;

    [self refreshViews];
}

@end


@interface ClippingPanel : UIView
{
    GridLayar *_gridLayer;
    
    ClippingCircle *_ltView;
    ClippingCircle *_lbView;
    ClippingCircle *_rtView;
    ClippingCircle *_rbView;
}

@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) RatioUnit *clippingRatio;

- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame;
- (void)setBgColor:(UIColor*)bgColor;
- (void)setGridColor:(UIColor*)gridColor;
- (void)clippingRatioDidChange;

@end

@implementation ClippingPanel

- (ClippingCircle*)clippingCircleWithTag:(NSInteger)tag
{
    ClippingCircle *view = [[ClippingCircle alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    view.bgColor = [UIColor clearColor];
    view.tag = tag;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
    [view addGestureRecognizer:panGesture];
    
    [self.superview addSubview:view];
    
    return view;
}

- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        
        [superview addSubview:self];
        
        _gridLayer = [[GridLayar alloc] init];
        _gridLayer.frame = self.bounds;
        _gridLayer.bgColor   = [UIColor colorWithWhite:1 alpha:0.6];
        _gridLayer.gridColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self.layer addSublayer:_gridLayer];
        
        _ltView = [self clippingCircleWithTag:0];
        _lbView = [self clippingCircleWithTag:1];
        _rtView = [self clippingCircleWithTag:2];
        _rbView = [self clippingCircleWithTag:3];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
        [self addGestureRecognizer:panGesture];
        
        UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinGesture:)];
        [self addGestureRecognizer:pinGesture];
        
        self.clippingRect = self.bounds;
        
    }
    
    return self;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
    [_ltView removeFromSuperview];
    [_lbView removeFromSuperview];
    [_rtView removeFromSuperview];
    [_rbView removeFromSuperview];
}

- (void)setBgColor:(UIColor *)bgColor
{
    _gridLayer.bgColor = bgColor;
}

- (void)setGridColor:(UIColor *)gridColor
{
    _gridLayer.gridColor = gridColor;
}

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    
    _ltView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:self];
    _lbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    _rtView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:self];
    _rbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    
    _gridLayer.clippingRect = clippingRect;
    
    [self setNeedsDisplay];
}

- (void)setClippingRect:(CGRect)clippingRect animated:(BOOL)animated
{
    if(animated){
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _ltView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y) fromView:self];
            _lbView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y+clippingRect.size.height) fromView:self];
            _rtView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y) fromView:self];
            _rbView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y+clippingRect.size.height) fromView:self];
            
        }];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
        animation.duration = 0.3;
        animation.fromValue = [NSValue valueWithCGRect:_clippingRect];
        animation.toValue = [NSValue valueWithCGRect:clippingRect];
        [_gridLayer addAnimation:animation forKey:nil];
        
        _gridLayer.clippingRect = clippingRect;
        _clippingRect = clippingRect;
        
        [self setNeedsDisplay];
        
    }else{
        self.clippingRect = clippingRect;
    }
}

- (void)clippingRatioDidChange
{
    CGRect rect = self.bounds;
    
    if(self.clippingRatio){
        
        CGFloat H = rect.size.width * self.clippingRatio.ratio;
        if(H<=rect.size.height){
            rect.size.height = H;
        }else{
            rect.size.width *= rect.size.height / H;
        }
        
        rect.origin.x = (self.bounds.size.width - rect.size.width) / 2;
        rect.origin.y = (self.bounds.size.height - rect.size.height) / 2;
    }
    
    [self setClippingRect:rect animated:YES];
}

- (void)setClippingRatio:(RatioUnit *)clippingRatio
{
    if(clippingRatio != _clippingRatio){
        _clippingRatio = clippingRatio;
        [self clippingRatioDidChange];
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    [_gridLayer setNeedsDisplay];
}

- (void)panCircleView:(UIPanGestureRecognizer*)sender
{
    if(_clippingRatio != nil){
        return ;
    }
    CGPoint point = [sender locationInView:self];
    CGPoint dp = [sender translationInView:self];
    
    CGRect rct = self.clippingRect;
    
    const CGFloat W = self.frame.size.width;
    const CGFloat H = self.frame.size.height;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = W;
    CGFloat maxY = H;
    
    CGFloat ratio = (sender.view.tag == 1 || sender.view.tag==2) ? -self.clippingRatio.ratio : self.clippingRatio.ratio;
    
    switch (sender.view.tag)
    {
        case 0: // upper left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
                CGFloat x0 = -y0 / ratio;
                minX = MAX(x0, 0);
                minY = MAX(y0, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.x = point.x;
            rct.origin.y = point.y;
            break;
        }
        case 1: // lower left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
                CGFloat xh = (H - y0) / ratio;
                minX = MAX(xh, 0);
                maxY = MIN(y0, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
            break;
        }
        case 2: // upper right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat x0 = -y0 / ratio;
                maxX = MIN(x0, W);
                minY = MAX(yw, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.y = point.y;
            break;
        }
        case 3: // lower right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat xh = (H - y0) / ratio;
                maxX = MIN(xh, W);
                maxY = MIN(yw, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
            break;
        }
        default:break;
    }
    self.clippingRect = rct;
}

- (void)panGridView:(UIPanGestureRecognizer*)sender
{
    static BOOL dragging = NO;
    static CGRect initialRect;
    
    if(sender.state==UIGestureRecognizerStateBegan){
        
        CGPoint point = [sender locationInView:self];
        
        dragging = CGRectContainsPoint(_clippingRect, point);
        
        initialRect = self.clippingRect;
        
    }else if(dragging){
        
        CGPoint point = [sender translationInView:self];
        CGFloat left  = MIN(MAX(initialRect.origin.x + point.x, 0), self.frame.size.width-initialRect.size.width);
        CGFloat top   = MIN(MAX(initialRect.origin.y + point.y, 0), self.frame.size.height-initialRect.size.height);
        
        CGRect rct = self.clippingRect;
        rct.origin.x = left;
        rct.origin.y = top;
        self.clippingRect = rct;
        
    }
}

- (void)pinGesture:(UIPinchGestureRecognizer*)gesture
{
    if(_clippingRatio != nil){
        return ;
    }
    
    static CGRect initialFrame;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        initialFrame = _clippingRect;
    }
    
    CGFloat scale = gesture.scale;
    CGRect rct;
    rct.size.width  = MAX(MIN(initialFrame.size.width*scale, self.frame.size.width), 0.1*self.frame.size.width);
    rct.size.height = MAX(MIN(initialFrame.size.height*scale, self.frame.size.height), 0.1*self.frame.size.height);
    rct.origin.x = initialFrame.origin.x + (initialFrame.size.width-rct.size.width)/2;
    rct.origin.y = initialFrame.origin.y + (initialFrame.size.height-rct.size.height)/2;
    
    if(rct.origin.x + rct.size.width > self.frame.size.width){
        if(rct.size.width < self.frame.size.width){
            rct.origin.x -= rct.origin.x + rct.size.width - self.frame.size.width ;
            rct.size.width += (rct.origin.x + rct.size.width - self.frame.size.width) ;
        }else{
            rct.origin.x = 0 ;
            rct.size.width = self.frame.size.width ;
        }
    }
    if(rct.origin.y + rct.size.height > self.frame.size.height){
        if(rct.size.height < self.frame.size.height){
            rct.origin.y -= rct.origin.y + rct.size.height - self.frame.size.height ;
            rct.size.height += (rct.origin.y + rct.size.height - self.frame.size.height) ;
        }else{
            rct.origin.y = 0 ;
            rct.size.height = self.frame.size.height ;
        }
    }
    if(rct.origin.x < 0){
        rct.origin.x = 0 ;
    }
    if(rct.origin.y < 0){
        rct.origin.y = 0 ;
    }
    
    self.clippingRect = rct;
}
@end


#pragma mark- KKImageClipTool

@interface KKImageClipTool()
{
    UIView *superView ;
    
    UIImage *originalImage ;
    
    ClippingPanel *_gridView;
    
    UIView *_menuContainer;
    UIScrollView *_menuScroll;
    
    NSArray *clipArray ;
}

@property (nonatomic, strong) RatioMenuItem *selectedMenu;

@end

@implementation KKImageClipTool

- (id)init
{
    self = [super init];
    
    if(self){
        clipArray = @[
                      @{kClippingToolRatioValue1:@0, kClippingToolRatioValue2:@0, kClippingToolRatioTitleFormat:@"Custom"},
                      @{kClippingToolRatioValue1:@1, kClippingToolRatioValue2:@1, kClippingToolRatioTitleFormat:@"%g : %g"},
                      @{kClippingToolRatioValue1:@4, kClippingToolRatioValue2:@3, kClippingToolRatioTitleFormat:@"%g : %g"},
                      @{kClippingToolRatioValue1:@3, kClippingToolRatioValue2:@2, kClippingToolRatioTitleFormat:@"%g : %g"},
                      @{kClippingToolRatioValue1:@16, kClippingToolRatioValue2:@9, kClippingToolRatioTitleFormat:@"%g : %g"},
                      ];
    }
    
    return self ;
}

- (void)setupWithSuperView:(UIView *)view imageViewFrame:(CGRect)frame menuView:(UIView *)menuView image:(UIImage *)image
{
    superView = view ;
    
    originalImage = image ;
    
    _menuContainer = [[UIView alloc] initWithFrame:menuView.bounds];
    _menuContainer.backgroundColor = [UIColor blackColor];
    [menuView addSubview:_menuContainer];
    
    _menuScroll = [[UIScrollView alloc] initWithFrame:menuView.bounds];
    _menuScroll.backgroundColor = [UIColor clearColor];
    _menuScroll.showsHorizontalScrollIndicator = NO;
    _menuScroll.clipsToBounds = NO;
    [_menuContainer addSubview:_menuScroll];
    
    _gridView = [[ClippingPanel alloc] initWithSuperview:view frame:frame];
    _gridView.bgColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    _gridView.gridColor = [UIColor redColor];
    _gridView.clipsToBounds = NO;
    
    _menuContainer.transform = CGAffineTransformMakeTranslation(0, _menuContainer.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        _menuContainer.transform = CGAffineTransformIdentity;
    }];
    
    [self setCropMenu];
}

- (void)cleanup
{
    [_gridView removeFromSuperview];
    
    [UIView animateWithDuration:0.3 animations:^{
        _menuContainer.transform = CGAffineTransformMakeTranslation(0, _menuContainer.frame.size.height);
    }completion:^(BOOL finished) {
        [_menuContainer removeFromSuperview];
    }];
}

#pragma mark -- 裁剪图片

- (void)clipImageWithBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    CGFloat zoomScale = superView.frame.size.width / originalImage.size.width;
    
    CGRect rct = _gridView.clippingRect;
    rct.size.width  /= zoomScale;
    rct.size.height /= zoomScale;
    rct.origin.x    /= zoomScale;
    rct.origin.y    /= zoomScale;
    
    UIImage *result = [originalImage clipImageInRect:rct];
    
    completionBlock(result, nil, nil);
}

#pragma mark -- 重新调整大小

- (UIImage*)resizeImage:(UIImage *)image size:(CGSize)size
{
    int W = size.width;
    int H = size.height;
    
    CGImageRef imageRef   = image.CGImage;
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, W, H, 8, 4*W, colorSpaceInfo, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    
    if(image.imageOrientation == UIImageOrientationLeft ||
       image.imageOrientation == UIImageOrientationRight){
        W = size.height;
        H = size.width;
    }
    
    if(image.imageOrientation == UIImageOrientationLeft ||
       image.imageOrientation == UIImageOrientationLeftMirrored){
        CGContextRotateCTM (bitmap, M_PI/2);
        CGContextTranslateCTM (bitmap, 0, -H);
    }else if (image.imageOrientation == UIImageOrientationRight ||
              image.imageOrientation == UIImageOrientationRightMirrored){
        CGContextRotateCTM (bitmap, -M_PI/2);
        CGContextTranslateCTM (bitmap, -W, 0);
    }else if (image.imageOrientation == UIImageOrientationUp ||
              image.imageOrientation == UIImageOrientationUpMirrored){
        // Nothing
    }else if (image.imageOrientation == UIImageOrientationDown ||
              image.imageOrientation == UIImageOrientationDownMirrored){
        CGContextTranslateCTM (bitmap, W, H);
        CGContextRotateCTM (bitmap, -M_PI);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, W, H), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

#pragma mark -- 菜单栏

- (void)setCropMenu
{
    CGFloat W = 70;
    CGFloat x = 0;
    
    CGSize  imgSize = originalImage.size;
    CGFloat maxW = MIN(imgSize.width, imgSize.height);
    UIImage *iconImage = [self resizeImage:originalImage size:CGSizeMake(W * imgSize.width/maxW, W * imgSize.height/maxW)];
    
    UIView *maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, _menuContainer.frame.size.height)];
    [maskView setBackgroundColor:[UIColor blackColor]];
    [_menuContainer addSubview:maskView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, (_menuContainer.frame.size.height - 40) / 2, 40, 40);
    [btn addTarget:self action:@selector(pushedRotateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"clip_mode"] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blackColor]];
    btn.adjustsImageWhenHighlighted = YES;
    [_menuContainer addSubview:btn];
    
    _menuScroll.frame = CGRectMake(btn.frame.size.width, 0, _menuContainer.frame.size.width - btn.frame.size.width, _menuContainer.frame.size.height);
    
    for(NSDictionary *info in clipArray){
        
        CGFloat val1 = [info[kClippingToolRatioValue1] floatValue];
        CGFloat val2 = [info[kClippingToolRatioValue2] floatValue];
        
        RatioUnit *ratio = [[RatioUnit alloc] initWithValue1:val1 value2:val2];
        ratio.titleFormat = info[kClippingToolRatioTitleFormat];
        ratio.isLandscape = (imgSize.width > imgSize.height);

        RatioMenuItem *view = [[RatioMenuItem alloc] initWithFrame:CGRectMake(x, 0, W, _menuScroll.frame.size.height) target:self action:@selector(tappedMenu:)];
        view.iconImage = iconImage;
        view.ratioUnit = ratio;
        
        [_menuScroll addSubview:view];
        
        x += W;
        
        if(self.selectedMenu==nil){
            self.selectedMenu = view;
        }
    }
    
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedMenu:(UITapGestureRecognizer*)sender
{
    RatioMenuItem *view = (RatioMenuItem*)sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
    }];
    
    self.selectedMenu = view;
}

- (void)setSelectedMenu:(RatioMenuItem *)selectedMenu
{
    if(selectedMenu != _selectedMenu){
        
        _selectedMenu.backgroundColor = [UIColor clearColor];
        _selectedMenu = selectedMenu;
        _selectedMenu.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.5];
        
        if(selectedMenu.ratioUnit.ratio==0){
            _gridView.clippingRatio = nil;
        }else{
            _gridView.clippingRatio = selectedMenu.ratioUnit;
        }
    }
}

- (void)pushedRotateBtn:(UIButton*)sender
{
    for(RatioMenuItem *item in _menuScroll.subviews){
        if([item isKindOfClass:[RatioMenuItem class]]){
            [item changeOrientation];
        }
    }
    
    if(_gridView.clippingRatio.ratio!=0 && _gridView.clippingRatio.ratio!=1){
        [_gridView clippingRatioDidChange];
    }
}

@end
