//
//  interaction.h
//  蓝牙
//
//  Created by 李志权 on 2017/6/21.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface interaction : UIViewController
/**外界设备*/
@property (nonatomic,strong)CBPeripheral *peripheral;
/**外界设备的服务里面的特征*/
@property (nonatomic,strong)CBCharacteristic *characteristic;
@end
