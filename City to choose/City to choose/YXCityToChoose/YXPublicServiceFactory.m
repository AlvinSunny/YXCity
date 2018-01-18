//  YXPublicServiceFactory.m
//  Created by 一笑 on 2017/10/18.


#import "YXPublicServiceFactory.h"

@interface YXPublicServiceFactory ()

/**键盘弹出监听*/
@property (nonatomic, assign)    NSInteger keyboardShowTime;

@property (nonatomic, assign)     BOOL     isThirdPartKeyboard;

@property (nonatomic, assign)     CGRect    keyboardFrame;

@property (nonatomic, assign)     CGFloat   keyboardAnimateDur;
/**结束*/

@end

@implementation YXPublicServiceFactory

+ (YXPublicServiceFactory *)sharedServiceFactory {
    
    static YXPublicServiceFactory *shared = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        shared = [[self alloc] init];
        
    });
    
    return shared;
    
}

#pragma mark - 键盘事件
- (void)lookAtTheKeyboardPosition
{
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowh:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShowh:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideh:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHideh:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}

- (void)keyboardWillShowh:(NSNotification*)notification
{
    
    NSValue* keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [keyboardBoundsValue CGRectValue];
    
    NSNumber* keyboardAnimationDur = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    float animationDur = [keyboardAnimationDur floatValue];
    _keyboardShowTime++;
    
    // 第三方输入法有bug,第一次弹出没有keyboardRect
    if (animationDur > 0.0f && keyboardRect.size.height == 0)
    {
        _isThirdPartKeyboard = YES;
    }
    
    // 第三方输入法,有动画间隔时,没有高度
    if (_isThirdPartKeyboard)
    {
        // 第三次调用keyboardWillShow的时候 键盘完全展开
        if (_keyboardShowTime == 3 && keyboardRect.size.height != 0 && keyboardRect.origin.y != 0)
        {
            _keyboardFrame = keyboardRect;
            NSLog(@"_keyboardFrame.size.height--%f",_keyboardFrame.size.height);
            //Animate change
            [self.delegate keyboardWillShow:keyboardRect keyboardAnimateDur:_keyboardAnimateDur];
        }
        if (animationDur > 0.0)
        {
            _keyboardAnimateDur = animationDur;
        }
    }
    else
    {
        if (animationDur > 0.0)
        {
            _keyboardFrame = keyboardRect;
            _keyboardAnimateDur = animationDur;
            //Animate change
            [self.delegate keyboardWillShow:keyboardRect keyboardAnimateDur:_keyboardAnimateDur];
        }
    }
}

- (void)keyboardDidShowh:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 工具条的Y值 == 键盘的Y值 - 工具条的高度
    duration = duration +0.2;
    [UIView animateWithDuration:duration animations:^{
        
        if (keyboardF.origin.y > [UIScreen mainScreen].bounds.size.height) {
         
        }else
        {
            
        }
    }];
    
}

- (void)keyboardWillHideh:(NSNotification*)notification
{
    
    NSNumber* keyboardAnimationDur = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    float animationDur = [keyboardAnimationDur floatValue];
    
    _isThirdPartKeyboard = NO;
    _keyboardShowTime = 0;
    
    if (animationDur > 0.0)
    {
        [self.delegate keyboardWillHide];
    }
}

- (void)keyboardDidHideh:(NSNotification*)notification{
    
//    [self.delegate keyboardDidHideSc];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
