//
//  ViewController.m
//  蓝牙
//
//  Created by 李志权 on 2017/6/20.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ReadServiceVC.h"
@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate>
{
    //系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
    CBCentralManager *manager;
    NSMutableArray *peripherals;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *arrayData;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end

@implementation ViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.textLabel.numberOfLines = 0;
    }
    if (self.arrayData && self.arrayData.count>indexPath.row) {
        NSDictionary *dic = self.arrayData[indexPath.row];
        CBPeripheral *peripheral = dic[@"CBPeripheral"];
        NSDictionary *advertisementData = dic[@"advertisementData"];
        if (peripheral.name && peripheral.name.length) {
            cell.textLabel.text = peripheral.name;
        }else if (advertisementData[@"kCBAdvDataLocalName"])
        {
            cell.textLabel.text =[NSString stringWithFormat:@"%@",advertisementData[@"kCBAdvDataLocalName"]];
        }
        if (cell.textLabel.text.length) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@",cell.textLabel.text,advertisementData[@"kCBAdvDataManufacturerData"]];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",advertisementData[@"kCBAdvDataManufacturerData"]];
        }
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",self.arrayData[indexPath.row]);
    CBPeripheral *pripheral = self.arrayData[indexPath.row][@"peripheral"];
    [manager stopScan];
    [manager connectPeripheral:pripheral options:nil];
    [peripherals addObject:pripheral];
}
//###1 导入CoreBluetooth头文件，建立主设备管理类，设置主设备委托
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    for (CBPeripheral *peripheral in peripherals) {
        [manager cancelPeripheralConnection:peripheral];
    }
    [self saomao:nil];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayData = [NSMutableArray array];
    peripherals = [NSMutableArray array];
     self.automaticallyAdjustsScrollViewInsets = NO;
    /*
     设置主设备的委托,CBCentralManagerDelegate
     必须实现的：
     - (void)centralManagerDidUpdateState:(CBCentralManager *)central;//主设备状态改变的委托，在初始化CBCentralManager的适合会打开设备，只有当设备正确打开后才能使用
     其他选择实现的委托中比较重要的：
     - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI; //找到外设的委托
     - (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;//连接外设成功的委托
     - (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//外设连接失败的委托
     - (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//断开外设的委托
     */
    //初始化并设置委托和线程队列，最好一个线程的参数可以为nil，默认会就main线程
    manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];

    
       // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)saomao:(id)sender {
    [self.arrayData removeAllObjects];
    [self.activity startAnimating];
    self.activity.hidden = NO;
     [manager scanForPeripheralsWithServices:nil options:nil];
}
//###2 扫描外设（discover），扫描外设的方法我们放在centralManager成功打开的委托中，因为只有设备成功打开，才能开始扫描，否则会报错。
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
             //状态未知
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown未知状态");
            break;
             //连接断开 即将重置
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting连接断开，即将重置");
            break;
            //该平台不支持蓝牙
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported，该设备部支持蓝牙");
            break;
            //未授权蓝牙使用 hovertree.com
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized，蓝牙未授权");
            break;
            //蓝牙关闭
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff，蓝牙关闭");
            break;
            //蓝牙正常开启
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn，蓝牙正常");
            //开始扫描周围的外设
            /*
             第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
             - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
             */
            [manager scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            break;
    }
    
}
//###3 连接外设(connect)
//扫描到设备会进入方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    [self.activity stopAnimating];
    self.activity.hidden = YES;
    [self.arrayData addObject:@{@"peripheral":peripheral,@"advertisementData":advertisementData,@"RSSI":RSSI}];
    [self.tableView reloadData];
    //接下连接我们的测试设备，如果你没有设备，可以下载一个app叫lightbule的app去模拟一个设备
    //这里自己去设置下连接规则，我设置的是P开头的设备
    if ([peripheral.name hasPrefix:@"P"]){
        /*
         一个主设备最多能连7个外设，每个外设最多只能给一个主设备连接,连接成功，失败，断开会进入各自的委托
         - (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;//连接外设成功的委托
         - (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//外设连接失败的委托
         - (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//断开外设的委托
         */
        //连接设备
        [manager connectPeripheral:peripheral options:nil];
    }
}


//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    
}
//###4 扫描外设中的服务和特征(discover)

//设备连接成功后，就可以扫描设备的服务了，同样是通过委托形式，扫描到结果后会进入委托方法。但是这个委托已经不再是主设备的委托（CBCentralManagerDelegate），而是外设的委托（CBPeripheralDelegate）,这个委托包含了主设备与外设交互的许多 回叫方法，包括获取services，获取characteristics，获取characteristics的值，获取characteristics的Descriptor，和Descriptor的值，写数据，读rssi，用通知的方式订阅数据等等。
//4.1获取外设的services
//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    //设置的peripheral委托CBPeripheralDelegate
    //@interface ViewController : UIViewController            [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    [peripheral discoverServices:nil];
    
    ReadServiceVC *VC = [[ReadServiceVC alloc]init];
    VC.peripheral = peripheral;
    VC.peripheral.delegate = VC;
    [self.navigationController pushViewController:VC animated:YES];
}

@end
