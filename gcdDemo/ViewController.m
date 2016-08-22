//
//  ViewController.m
//  gdcdemo
//
//  Created by 刘东 on 16/4/13.
//  Copyright © 2016年 刘东. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    //创建一个串行队列
    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("serialQueue", NULL);
    //创建一个并行队列
    dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    //获取主线程
    //获取主线程
    dispatch_queue_t mainDispatchQueue = dispatch_get_main_queue();
    //高优先级
    dispatch_queue_t globalDispatchQueueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    //默认优先级
    dispatch_queue_t globalDispatchQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //低优先级
    dispatch_queue_t globalDispatchQueueLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW , 0);
    //后台优先级
    dispatch_queue_t globalDispatchQueueBackgroud = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND , 0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSLog(@"爱吃肉");
    });
    
    dispatch_set_target_queue(mySerialDispatchQueue, globalDispatchQueueBackgroud);
    
    dispatch_async(mySerialDispatchQueue, ^{
        NSLog(@"我是洛洛");
    });
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 6ull*NSEC_PER_USEC);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"6秒后");
    });
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk0");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk2");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk3");
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"结束了");
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_time_t time2 = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC);
    
    long result = dispatch_group_wait(group, time2);
    
    if (result == 0) {
        /*
         *属于Dispatch Group的全部处理结束执行
         */
    }else{
        /*
         *属于Dispatch Group的某一个处理还在执行中
         */
    }
    dispatch_async(globalDispatchQueueDefault, ^{
        NSLog(@"a");
    });
    
    
    dispatch_sync(queue, ^{
        NSLog(@"洛洛爱吃肉");
    });
    
    dispatch_async(queue, ^{
        dispatch_sync(queue, ^{
            NSLog(@"洛洛爱吃肉");
        });
    });
    
    
    //    dispatch_apply([array count], queue, ^(size_t index) {
    //        NSLog(@"%zu: %@",index,[array objectAtIndex:index]);
    //    })
    //
    
    dispatch_barrier_async(globalDispatchQueueDefault, ^{
        NSLog(@"writing");
    });
    
    dispatch_apply(10, globalDispatchQueueDefault, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    NSLog(@"done");
    
    
    
    static  int initialized = NO;
    if (initialized == NO) {
        
        /*
         *初始化
         */
        
        initialized = YES;
    }
    static dispatch_once_t pred;
    dispatch_once (&pred,^{
        
        /*
         *初始化
         */
        
    });
    
    //    dispatch_async(queue, blk0_for_reading);
    //    dispatch_async(queue, blk1_for_reading);
    //    dispatch_async(queue, blk2_for_reading);
    //    dispatch_async(queue, blk3_for_reading);
    //    dispatch_async(queue, blk4_for_reading);
    //    dispatch_async(queue, blk5_for_reading);
    //    dispatch_async(queue, blk6_for_reading);
    //    dispatch_async(queue, blk7_for_reading);
    
    
    
    //    dispatch_async(queue,blk1);
    //    dispatch_async(queue,blk2);
    //    dispatch_async(queue,blk3);
    //    dispatch_async(queue,blk4);
    //    dispatch_async(queue,blk5);
    
    
    dispatch_suspend(queue);
    
}

-(void)demoDispatch_apply{
    
    NSArray *array = [[NSArray alloc]init];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    /*
     *在Global Dispatch Queue中非同步执行
     */
    dispatch_async(queue, ^{
        /*
         *  Global Dispatch Queue
         *  等待dispatch_apply函数中全部处理结束
         */
        dispatch_apply([array count], queue, ^(size_t index) {
            /*
             *并列处理包含在NSArray对象的全部对象
             */
            NSLog(@"%zu: %@",index,[array objectAtIndex:index]);
        });
        /*
         *dispatch_apply函数中的处理全部执行结束
         */
        
        /*
         * 在Main Dispatch Queue 中非同步执行
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            /*
             * 在Main Dispatch Queue 中执行处理
             * 用户界面更新等
             */
            NSLog(@"done");
        });
    });
    
    
}

-(void)demoDispatch_semaphore{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<10000; i++) {
        dispatch_async(queue, ^{
            [array addObject:[NSNumber numberWithInt:i]];
        });
    }
    
    
    /*
     *  生成Dispatch Semaphore
     *  Dispatch Semaphore的计数初始值设定为"1"
     *
     *  保证可访问NSMutableArray类对象的线程
     *  同时只能有一个
     */
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    for (int i = 0; i<10000; i++) {
        dispatch_async(queue, ^{
            
            /*
             *  等待Dispatch Semaphore
             *
             *  一直等待,直到Dispatch Semaphore的计数值达到大于等于1。
             */
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            /*
             *  由于Dispatch Semaphore的计数值达到大于等于1
             *  所以将Dispatch Semaphore的计数值减去1
             *  dispatch_semaphore_wait函数执行返回
             *
             *  即执行到此时的
             *  Dispatch Semaphore的计数值恒为"0"
             *
             *  由于可访问的 NSMutableArray类对象的线程
             *  只有1个
             *  因此可安全的进行更新
             */
            
            [array addObject:[NSNumber numberWithInt:i]];
            
            /*
             *  排他控制处理结束
             *  所以通过dispatch_semaphore_signal函数
             *  将Dispatch Semaphore的计数值加1
             *
             *  如果有通过dispatch_semaphore_wait函数
             *  等待Dispatch Semaphore 的计数值增加的线程
             *  就由最先等待的线程执行
             */
            dispatch_semaphore_signal(semaphore);
        });
    }
    
    
    
    
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC);
    long result = dispatch_semaphore_wait(semaphore, time);
    if (result == 0) {
        /*
         *  由于Dispatch Semaphore 的计数值达到大于等于1
         *  或者在待机的等待时间内
         *  Dispatch Semaphore 的计数值达到大于等于1
         *  所以Dispatch Semaphore 的计数值减去1
         *
         *  可执行需要进行的排他控制的处理
         */
    }else{
        /*
         *  由于Dispatch Semaphore 的计数值为0
         *  因此在到达指定时间为止待机
         */
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
