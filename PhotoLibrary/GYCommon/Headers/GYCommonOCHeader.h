//
//  GYCommonOCHeader.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#ifndef GYCommonOCHeader_h
#define GYCommonOCHeader_h

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define BS(blockSelf)  __block __typeof(&*self)blockSelf = self;
#define SS(strongSelf) __strong __typeof(&*self)strongSelf = weakSelf;

#endif /* GYCommonOCHeader_h */
