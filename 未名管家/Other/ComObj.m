//
//  ComObj.m
//  未名管家
//
//  Created by apple on 15/11/20.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import "ComObj.h"

static ComObj* _comObj;
@implementation ComObj

@end

ComObj* g() {
    if(!_comObj) {
        _comObj = [[ComObj alloc] init];
    }
    return _comObj;
}
