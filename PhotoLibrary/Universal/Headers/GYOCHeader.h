//
//  GYOCHeader.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#ifndef GYOCHeader_h
#define GYOCHeader_h

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define BS(blockSelf)  __block __typeof(&*self)blockSelf = self;
#define SS(strongSelf) __strong __typeof(&*self)strongSelf = weakSelf;

// block
#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

#endif /* GYOCHeader_h */
