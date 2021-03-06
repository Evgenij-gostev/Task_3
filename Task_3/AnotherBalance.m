//
//  AnotherBalance.m
//  Task_3
//
//  Created by Евгений Гостев on 25.10.2018.
//  Copyright © 2018 Evgenij Gostev. All rights reserved.
//

#import "AnotherBalance.h"

@implementation AnotherBalance

- (instancetype)initWithJSON:(JSON *)json {
  if (json && [json isKindOfClass:[NSDictionary class]]) {
    if ([json objectForKey:@"accountId"]) {
      self.accountId = [json[@"accountId"] intValue];
    }
    if ([json objectForKey:@"iconUrl"]) {
      self.iconURL = json[@"iconUrl"];
    }
    
    NSDictionary* balanceDict = json[@"balance"];
    if (balanceDict) {
      NSTimeInterval unixTimeStamp = [balanceDict[@"time"] doubleValue];
      NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
      NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
      [dateformatter setLocale:[NSLocale currentLocale]];
      [dateformatter setDateFormat:@"HH:mm"];
      NSString *dateString = [dateformatter stringFromDate:date];
      self.currentTime = dateString;
      
      NSDictionary *resultDict = balanceDict[@"result"];
      if (![resultDict objectForKey:@"__tariff"]) {
        self.tariff = [NSString string];
      } else {
        self.tariff = resultDict[@"__tariff"];
      }
      
      NSDictionary *balanceNameDict = resultDict[@"balance"];
      if (balanceNameDict) {
        if ([balanceNameDict objectForKey:@"name"]) {
          self.balanceName = balanceNameDict[@"name"];
        }
        
        NSString *units = [NSString string];
        if ([balanceNameDict objectForKey:@"value"]) {
          self.baseBalanceValue = balanceNameDict[@"value"];
        }
        if (![balanceNameDict objectForKey:@"units"]) {
          units = @"";
        } else if ([balanceNameDict[@"units"] isEqualToString:@" {@currency}"]) {
          if ([resultDict[@"currency"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *currencyDict = resultDict[@"currency"];
            units = currencyDict[@"value"];
          } else {
            units = resultDict[@"currency"];
          }
        } else {
          units = balanceNameDict[@"units"];
        }
        self.baseBalanceValue = [NSString stringWithFormat:@"%@%@",
                                 balanceNameDict[@"value"],
                                 units];
      } else {
        self.balanceName = [NSString string];
        self.baseBalanceValue = [NSString string];
      }
    }
    NSDictionary *accountSettings = json[@"accountSettings"];
    if (accountSettings) {
      self.accountName = accountSettings[@"name"];
    }
  } else {
    return nil;
  }
  return self;
}

- (NSMutableArray *)getDetailBalanceFromJSON:(JSON *)json {
  if (!json || ![json isKindOfClass:[NSDictionary class]]) {
    return nil;
  } else {
    NSMutableArray *details = [NSMutableArray array];
    NSDictionary* balanceDict = json[@"balance"];
    if (balanceDict) {
      NSDictionary *resultDict = balanceDict[@"result"];
      if (resultDict) {
        for (NSString *key in [resultDict allKeys]) {
          if ([resultDict[key] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *detail = [NSMutableDictionary dictionary];
            [detail setObject:[resultDict[key] objectForKey:@"value"] forKey:@"value"];
            [detail setObject:[resultDict[key] objectForKey:@"name"] forKey:@"name"];
            
            if ([resultDict[key] objectForKey:@"units"]) {
              if ([[resultDict[key] objectForKey:@"units"] isEqualToString:@" {@currency}"]) {
                if ([[resultDict objectForKey:@"currency"] isKindOfClass:[NSDictionary class]]) {
                  NSDictionary *currencyDict = resultDict[@"currency"];
                  [detail setObject:currencyDict[@"value"] forKey:@"currency"];
                } else {
                  [detail setObject:[resultDict objectForKey:@"currency"] forKey:@"currency"];
                }
              } else {
                [detail setObject:[resultDict[key] objectForKey:@"units"] forKey:@"units"];
              }
            }
            
            if ([resultDict[key] objectForKey:@"format"]) {
              [detail setObject:[resultDict[key] objectForKey:@"format"] forKey:@"format"];
            }
            [details addObject:detail];
          }
        }
      }
    }
    return details;
  }
}

@end
