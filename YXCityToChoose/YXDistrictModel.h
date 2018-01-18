//  YXDistrictModel.h
//  Created by 一笑 on 2017/10/18.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <WHC_ModelSqlite.h>

@interface YXDistrictModel : NSObject  <NSCoding>

/**城市编码*/
@property (nonatomic, copy) NSString          *citycode;
/**地理编码*/
@property (nonatomic, copy) NSString          *adcode;
/**城市名称*/
@property (nonatomic, copy) NSString          *name;
/**中心点经纬度*/
@property (nonatomic, copy) NSString          *center;
/**城市级别*/
@property (nonatomic, copy) NSString          *level;
/**区域*/
@property (nonatomic, strong) NSArray         *districts;
/** 城市名称-拼音*/
@property (nonatomic, copy) NSString *pinyin;
/** 城市名称-拼音首字母*/
@property (nonatomic, copy) NSString *initials;

@end

