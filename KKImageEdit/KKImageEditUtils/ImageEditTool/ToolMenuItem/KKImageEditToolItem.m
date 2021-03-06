//
//  ImageEditToolItem.m
//  
//
//  Created by finger on 17/2/13.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKImageEditToolItem.h"
#import "UIView+Extension.h"

@implementation KKImageEditToolItem
{
}

- (instancetype)init
{
    self = [super init];
    
    if(self){
        
        self.itemImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.width - 35) / 2, 0, 35, 35)];
        self.itemImageView.image = self.itemImage ;
        [self addSubview:self.itemImageView];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.itemImageView.y + self.itemImageView.height + 3, self.width, self.height - self.itemImageView.height)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentCenter ;
        [self addSubview:self.titleLabel];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [self addGestureRecognizer:recognizer];
        
    }
    
    return self ;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        
        self.itemImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.width - 35) / 2, 0, 35, 35)];
        self.itemImageView.image = self.itemImage ;
        [self addSubview:self.itemImageView];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.itemImageView.y + self.itemImageView.height + 3, self.width, self.height - self.itemImageView.height)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentCenter ;
        [self addSubview:self.titleLabel];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [self addGestureRecognizer:recognizer];
        
    }
    
    return self ;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.itemImageView.frame = CGRectMake((self.width - 35) / 2, 0, 35, 35) ;
    self.titleLabel.frame = CGRectMake(0, self.itemImageView.y + self.itemImageView.height + 3, self.width, self.height - self.itemImageView.height) ;
}

#pragma mark -- @property

- (void)setItemImage:(UIImage *)itemImage
{
    _itemImage = itemImage ;
    
    self.itemImageView.image = itemImage ;
}

- (void)setItemTitle:(NSString *)itemTitle
{
    _itemTitle = itemTitle ;
    
    self.titleLabel.text = itemTitle ;
    
    if(!itemTitle.length){
        [self setHideTitle:YES];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected ;
    
    if(_selected){
        self.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:0.5];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setHideTitle:(BOOL)hideTitle
{
    _hideTitle = hideTitle ;
    
    self.titleLabel.hidden = hideTitle ;
    
    self.itemImageView.x = (self.width - self.itemImageView.width) / 2 ;
    self.itemImageView.y = (self.height - self.itemImageView.height) / 2 ;
}

#pragma mark -- 点击事件

- (void)tapClick:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(imageEditItem:clickItemWithType:editInfo:)]){
        [_delegate imageEditItem:self clickItemWithType:self.editType editInfo:self.editInfo];
    }
}

@end
