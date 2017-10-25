//
//  ViewController.m
//  CLYTest
//
//  Created by hsx770911@126.com on 2017/10/25.
//  Copyright © 2017年 hsx770911@126.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self loadDispatch];
//    [self loadDispatchValidity];
    [self loadDispatchSemaphore];

}



/**
 在每个请求开始之前，我们创建一个信号量，初始为0，在请求操作之后，我们设一个dispatch_semaphore_wait，在请求到结果之后，再将信号量+1，也即是dispatch_semaphore_signal。这样做的目的是保证在请求结果没有返回之前，一直让线程等待在那里，这样一个线程的任务一直在等待，就不会算作完成，notify的内容也就不会执行了，直到每个请求的结果都返回了，线程任务才能够结束，这时候notify也才能够执行。
 
 */
- (void)loadDispatchSemaphore{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"处理事件A");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"处理事件B");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"处理事件C");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"完成了网络请求，不管网络请求失败还是成功");
    });

}


/**
 和dispatch_async相比，当我们调用n次dispatch_group_enter后再调用n次dispatch_group_level时，dispatch_group_notify和dispatch_group_wait会收到同步信号；这个特点使得它非常适合处理异步任务的同步当异步任务开始前调用dispatch_group_enter异步任务结束后调用dispatch_group_leve；
 
    效果不明显，看项目中的图片把
 
 */
- (void)loadDispatchValidity{
    
    int sum1 =0;
    int sum2 =0;
    int sum3 =0;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSLog(@"任务一开始");
    for (int i =0; i<10000000; i++) {
        sum1 = sum1 +i *sum1+999;
        if (i==999999) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"任务一完成 ==%d",sum1);
                dispatch_group_leave(group);
            });
        }
    }
    
    
    dispatch_group_enter(group);
    NSLog(@"任务二开始");
    for (int i =0; i<100; i++) {
        sum2 = sum2 +i;
        if (i==99) {
            NSLog(@"任务二完成 ==%d",sum2);
            dispatch_group_leave(group);
        }
    }
    
    dispatch_group_enter(group);
    NSLog(@"任务三开始");
    for (int i =0; i<1000000; i++) {
        sum3 = sum3 +i;
        if (i==999999) {
            NSLog(@"任务三完成 ==%d",sum3);
            dispatch_group_leave(group);
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"处理任务四");
    });

}


/**
 网络请求需要时间，所以这个无效
 */
- (void)loadDispatch{
    dispatch_queue_t queue = dispatch_queue_create("CLYTest.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t  disgroup = dispatch_group_create();
    
    dispatch_group_async(disgroup, queue, ^{
        NSLog(@"任务一开始");
        sleep(2);
        NSLog(@"任务一完成");
    });
    
    
    dispatch_group_async(disgroup, queue, ^{
        NSLog(@"任务二开始");
        sleep(5);
        NSLog(@"任务二完成");
    });
    
    dispatch_group_async(disgroup, queue, ^{
        NSLog(@"任务三开始");
        sleep(2);
        NSLog(@"任务三完成");
    });
    
    dispatch_group_notify(disgroup, queue, ^{
        NSLog(@" notify: 任务都完成了");
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
