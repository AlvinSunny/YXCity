//  YXPublicServiceFactory.h
//  Created by 一笑 on 2017/10/18.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol YXPublicServiceFactoryDelegate <NSObject>

/**将要弹出*/
- (void)keyboardWillShow:(CGRect)rect keyboardAnimateDur:(CGFloat)keyboardAnimateDur;

/**将要收回*/
- (void)keyboardWillHide;

/**已经收回*/
- (void)keyboardDidHideSc;

@end

@interface YXPublicServiceFactory : NSObject

@property (nonatomic, strong) id <YXPublicServiceFactoryDelegate> delegate;

+ (YXPublicServiceFactory *)sharedServiceFactory;

/**
 查看键盘位置
 */
- (void)lookAtTheKeyboardPosition;

@end
