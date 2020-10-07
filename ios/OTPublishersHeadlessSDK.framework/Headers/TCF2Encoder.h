//
//  TCF2_Encoder.h
//  TCF_2_String_Encode
//
//  Copyright © 2020 OneTrust, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCF2Encoder : NSObject

+ (instancetype)sharedInstance;

-(NSString *)buildStringFromValues:(NSDictionary *)values;
-(NSDictionary *)getAllTCFStringsFromLocalStorage;
-(void)clearAllTCFStringsFromLocalStorage;

@end

NS_ASSUME_NONNULL_END
