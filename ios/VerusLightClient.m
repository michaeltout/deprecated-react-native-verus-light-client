#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"

// Export a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
@interface RCT_EXTERN_MODULE(VerusLightClient, NSObject)

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

// Export methods to a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
RCT_EXTERN_METHOD(
                  request: (NSInteger *)id
                  method: (NSString *)method
                  params: (NSArray *)params
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )

// Export methods to a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
RCT_EXTERN_METHOD(
                  openWallet: (NSString *)coinId
                  coinProto: (NSString *)coinProto
                  accountHash: (NSString *)accountHash
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )

// Export methods to a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
RCT_EXTERN_METHOD(
                  closeWallet: (NSString *)coinId
                  coinProto: (NSString *)coinProto
                  accountHash: (NSString *)accountHash
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )

// Export methods to a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
RCT_EXTERN_METHOD(
                  deleteWallet: (NSString *)coinId
                  coinProto: (NSString *)coinProto
                  accountHash: (NSString *)accountHash
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )

// Export methods to a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
RCT_EXTERN_METHOD(
                  createWallet: (NSString *)coinId
                  coinProto: (NSString *)coinProto
                  accountHash: (NSString *)accountHash
                  address: (NSString *)address
                  port: (NSInteger *)port
                  numAddresses: (NSInteger *)numAddresses
                  seed: (NSString *)seed
                  birthday: (NSInteger *)birthday
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )

// Export methods to a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
RCT_EXTERN_METHOD(
                  startSync: (NSString *)coinId
                  coinProto: (NSString *)coinProto
                  accountHash: (NSString *)accountHash
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )

// Export methods to a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
RCT_EXTERN_METHOD(
                  stopSync: (NSString *)coinId
                  coinProto: (NSString *)coinProto
                  accountHash: (NSString *)accountHash
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )
@end
