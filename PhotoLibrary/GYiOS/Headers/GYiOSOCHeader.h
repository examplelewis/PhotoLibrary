//
//  GYiOSOCHeader.h
//  PodsGYiOS
//
//  Created by 龚宇 on 21/12/29.
//

#ifndef GYiOSOCHeader_h
#define GYiOSOCHeader_h

#define screenWidth (MAX(kScreenWidth, kScreenHeight))
#define screenHeight (MIN(kScreenWidth, kScreenHeight))

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }
#endif

#endif /* GYiOSOCHeader_h */
