//
//  MSCommCore.m
//  MSAdSDK
//
//  Created by yang on 2019/8/23.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MSCommCore.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "sys/utsname.h"
#import <AdSupport/AdSupport.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)

#define IOS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation MSCommCore

//获取文本大小
+ (CGSize)getTextSize:(NSString *)message fontSize:(NSInteger)fontSize maxChatWidth:(NSInteger)maxChatWidth{
    CGSize contentSize;
    if (IOS_8_OR_LATER) {
        contentSize = [message sizeWithFont:[UIFont systemFontOfSize:fontSize]
                          constrainedToSize:CGSizeMake(maxChatWidth, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    }
    else{
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        //        NSDictionary *attributes = @{NSFontAttributeName:CELL_CONTENT_FONT_SIZE, NSParagraphStyleAttributeName:paragraphStyle.copy}
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
        
        contentSize = [message boundingRectWithSize:CGSizeMake(maxChatWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
    }
    
    return contentSize;
    
}

+ (NSString *)getCurrentDeviceModel{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
//    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
//    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
//    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
//    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
//    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
//    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
//    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
//    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
//    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
//    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
//    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
//    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
//    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
//    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
//    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
//    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
//    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
//    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
//    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
//    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
//    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
//    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
//    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
//    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
//    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
//    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
//    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
//    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
//    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
//    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
//    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
//    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
//    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
//    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
//    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
//    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
//
//    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
//    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
//    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
//    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";
//
//    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
//    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    return deviceModel;
}

+ (NSString*)getDevicePPI:(NSString*)deviceModel{
    if ([deviceModel rangeOfString:@"4"].location != NSNotFound) {
        return @"326ppi";
    }
    else  if ([deviceModel rangeOfString:@"5"].location != NSNotFound ||[deviceModel rangeOfString:@"SE"].location != NSNotFound ) {
        return @"326ppi";
    }
    else  if ([deviceModel rangeOfString:@"Plus"].location != NSNotFound ) {
        return @"401ppi";
    }
    
    
    else  if ([deviceModel rangeOfString:@"6"].location != NSNotFound ||[deviceModel rangeOfString:@"7"].location != NSNotFound ||[deviceModel rangeOfString:@"8"].location != NSNotFound) {
        return @"326ppi";
    }
    
    else  if ([deviceModel rangeOfString:@"XR"].location != NSNotFound ) {
        return @"326ppi";
    }
    else  if ([deviceModel rangeOfString:@"Xs Max"].location != NSNotFound ) {
        return @"458ppi";
    }
    else  if ([deviceModel rangeOfString:@"X"].location != NSNotFound ||[deviceModel rangeOfString:@"XS"].location != NSNotFound) {
        return @"458ppi";
    }
    
    return @"286ppi";
}


+ (UIImage *)imageNamed:(NSString *)name{
    
    UIImage *image = nil;
    
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"BUAdSDK"];
    
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];;
    
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    
    return image;
}

+ (NSString*)OpenUDID{
    return [[NSProcessInfo processInfo] globallyUniqueString];
}
+ (NSMutableDictionary *)publicParams{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //    http://123.59.48.113/sdk/req_ad?device_type=phone&device_width=1080&device_type_os=6.0&pid=100424013&device_os=Android&device_geo_lon=103.930777&app_ver=1.0&device_adid=474c270519e94493&app_id=101343&device_network=MOBILE&device_imsi=460018175278208&app_name=SdkDemo&is_mobile=1&device_height=1812&device_geo_lat=30.759109&device_mac=8c%3A34%3Afd%3A3d%3A15%3A51&version=3.0&device_model=HUAWEI%20MT7-TL10&app_package=com.meishu.sdkdemo&device_orientation=0&device_brand=Huawei&device_ppi=480&device_ua=Mozilla%2F5.0%20%28Linux%3B%20Android%206.0%3B%20HUAWEI%20MT7-TL10%20Build%2FHuaweiMT7-TL10%3B%20wv%29%20AppleWebKit%2F537.36%20%28KHTML%2C%20like%20Gecko%29%20Version%2F4.0%20Chrome%2F49.0.2623.105%20Mobile%20Safari%2F537.36&device_imei=867066020602242
   
    //手机别名： 用户定义的名称
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", userPhoneName);
    //设备名称
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    NSLog(@"设备名称: %@",deviceName );
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", phoneVersion);
    //手机型号
    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSLog(@"手机型号: %@",phoneModel );
    //地方型号  （国际化区域名称）
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    NSLog(@"国际化区域名称: %@",localPhoneModel );
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSLog(@"当前应用名称：%@",appCurName);
    
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"当前应用软件版本:%@",appCurVersion);
    // 当前应用版本号码   int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"当前应用版本号码：%@",appCurVersionNum);
    
    if (!appCurName) {
        appCurName = @"SdkDemo";
    }
    [dict setObject:appCurName forKey:@"app_name"];
    [dict setObject:appCurVersion forKey:@"app_ver"];
    [dict setObject:@"30.759109" forKey:@"device_geo_lat"];
    [dict setObject:@"103.930777" forKey:@"device_geo_lon"];
    [dict setObject:@"idfa" forKey:@"device_adid"];
    //    苹果设备唯一标识号;
    NSString *device_openudid =  [[NSProcessInfo processInfo] globallyUniqueString];
    [dict setObject:device_openudid forKey:@"device_openudid"];
    
    //手机序列号
    NSString* identifierNumber = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSLog(@"手机序列号: %@",identifierNumber);
    [dict setObject:identifierNumber forKey:@"device_idfv"];

    //device_model 手机型号("MHA-AL00"、"SM-G9280"、"iPhone8"、"MIX 2S" 等)
    NSString *device_model = [self getCurrentDeviceModel];
    [dict setObject:device_model forKey:@"device_model"];

    //设备屏幕像素密度:286ppi
    [dict setObject:[self getDevicePPI:device_model] forKey:@"device_ppi"];

    //获取mac地址
    [dict setObject:[self macaddress] forKey:@"device_mac"];

    //获取操作系统版本
    [dict setObject:phoneVersion forKey:@"device_type_os"];
    
    //获取设备类型
    if(IS_IPHONE){
        [dict setObject:@"0" forKey:@"device_type"];
    }
    else{
        [dict setObject:@"1" forKey:@"device_type"];
    }
    
    //获取设备品牌、生产厂商
    [dict setObject:@"Apple" forKey:@"device_brand"];

    [dict setObject:[NSString stringWithFormat:@"%f",[UIScreen mainScreen].bounds.size.width] forKey:@"device_width"];
    [dict setObject:[NSString stringWithFormat:@"%f",[UIScreen mainScreen].bounds.size.height] forKey:@"device_height"];

    //获取网络运营商代码取值
    [dict setObject:[self networkInfo] forKey:@"device_imsi"];
    
    //获取网络类型
    [dict setObject:[self getNetconnType] forKey:@"device_network"];
    
    //获取网络类型
    [dict setObject:@"iOS" forKey:@"device_os"];
    
    //获取屏幕分辨率值
    [dict setObject:[NSString stringWithFormat:@"%f",[UIScreen mainScreen].scale] forKey:@"device_density"];
    
    //获取客户端 ip(必须是外网可访问 IP，客户端直接)
    [dict setObject:[self getIPAddress:YES] forKey:@"device_ip"];
    
    //获取User-Agent(GET 请求须进行一次 urlencode)必须是标准 Webview UA 而非自定义 UA
    [dict setObject:@"ios" forKey:@"device_ua"];
    
    //获取横竖屏
    [dict setObject:@"1" forKey:@"device_orientation"];
    
    return dict;
}

//获取ip地址
//获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}
//获取所有相关IP信息
+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString*)networkInfo{
    // 状态栏是由当前app控制的，首先获取当前app
//    UIApplication *app = [UIApplication sharedApplication];
//    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
//    for (id child in children) {
//        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarServiceItemView")]) {
//            id type = [child valueForKeyPath:@"serviceString"];
//            NSLog(@"carrier is %@", type);
//            if([type isEqualToString:@"中国移动"]){
//                return @"46000";
//            }
//            else  if([type isEqualToString:@"中国联通"]){
//                return @"46001";
//            }
//            else  if([type isEqualToString:@"中国电信"]){
//                return @"46003";
//            }
//            break;
//        }
//    }
    
    return @"-1";
}

+ (NSString *)getNetconnType{
    
    NSString *netconnType = @"";
    
    // 获取手机网络类型
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    NSString *currentStatus = info.currentRadioAccessTechnology;
    
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
        netconnType = @"GPRS";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
        
        netconnType = @"2.75G EDGE";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
        
        netconnType = @"3G";
        return @"3";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
        
        netconnType = @"3.5G HSDPA";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
        
        netconnType = @"3.5G HSUPA";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
        
        netconnType = @"2G";
        return @"4";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
        
        netconnType = @"3G";
        return @"3";

    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
        
        netconnType = @"3G";
        return @"3";

    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
        
        netconnType = @"3G";
        return @"3";

    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
        
        netconnType = @"HRPD";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
        netconnType = @"4G";
        return @"2";

    }
    else{
        return @"-1";
    }
    return @"1";
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
+ (NSString *) macaddress
{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    //    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    NSLog(@"outString:%@", outstring);
    
    free(buf);
    
    return [outstring uppercaseString];
}

@end
