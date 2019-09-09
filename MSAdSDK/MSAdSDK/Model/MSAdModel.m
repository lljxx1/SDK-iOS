//
//  MSAdModel.m
//  MSAdSDK
//
//  Created by yang on 2019/8/28.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MSAdModel.h"

@implementation MSAdModel

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;}
+ (instancetype)provinceWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}

@end
