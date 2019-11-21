//
//  MSSDKModel.m
//  MSAdSDK
//
//  Created by yang on 2019/9/3.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MSSDKModel.h"

@implementation MSSDKModel
- (instancetype)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;}
+ (instancetype)provinceWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}
@end
