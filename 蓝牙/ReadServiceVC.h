//
//  ReadServiceVC.h
//  蓝牙
//
//  Created by 李志权 on 2017/6/21.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface ReadServiceVC : UIViewController<CBPeripheralDelegate>
/**外界设备*/
@property (nonatomic,strong)CBPeripheral *peripheral;
@end
