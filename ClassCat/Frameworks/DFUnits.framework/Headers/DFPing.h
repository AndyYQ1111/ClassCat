//
//  DFPing.h
//  MusicTest
//
//  Created by DFung on 2018/3/30.
//  Copyright © 2018年 DFung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <AssertMacros.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>

#pragma once
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/select.h>
#include <sys/time.h>
#include <fcntl.h>
#include <string.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/errno.h>
#include <pthread.h>
#define kNET_TIME_GAP 100
#define kDFPING_TIMEOUT @"DFPING_TIMEOUT"

struct net_ping_addr_t{
    const char *name;
    const char *host;
    const int port;
};
typedef struct net_ping_addr_t n_ping_addr_t;
/**
 *  return 1:OK  0:Not good
 */
int do_net_ping(void);
int do_net_ping_1(n_ping_addr_t *paddrs);



NS_ASSUME_NONNULL_BEGIN

@protocol DFPingDelegate;

/*! Controls the IP address version used by DFPing instances.
 */

typedef NS_ENUM(NSInteger, DFPingAddressStyle) {
    DFPingAddressStyleAny,          ///< Use the first IPv4 or IPv6 address found; the default.
    DFPingAddressStyleICMPv4,       ///< Use the first IPv4 address found.
    DFPingAddressStyleICMPv6        ///< Use the first IPv6 address found.
};

/*! An object wrapper around the low-level BSD Sockets ping function.
 *  \details To use the class create an instance, set the delegate and call `-start`
 *      to start the instance on the current run loop.  If things go well you'll soon get the
 *      `-DFPing:didStartWithAddress:` delegate callback.  From there you can can call
 *      `-sendPingWithData:` to send a ping and you'll receive the
 *      `-DFPing:didReceivePingResponsePacket:sequenceNumber:` and
 *      `-DFPing:didReceiveUnexpectedPacket:` delegate callbacks as ICMP packets arrive.
 *
 *      The class can be used from any thread but the use of any single instance must be
 *      confined to a specific thread and that thread must run its run loop.
 */
@interface DFPing : NSObject
- (instancetype)init NS_UNAVAILABLE;

/*! Initialise the object to ping the specified host.
 *  \param hostName The DNS name of the host to ping; an IPv4 or IPv6 address in string form will
 *      work here.
 *  \returns The initialised object.
 */

- (instancetype)initWithHostName:(NSString *)hostName NS_DESIGNATED_INITIALIZER;

/*! A copy of the value passed to `-initWithHostName:`.
 */

@property (nonatomic, copy, readonly) NSString * hostName;

/*! The delegate for this object.
 *  \details Delegate callbacks are schedule in the default run loop mode of the run loop of the
 *      thread that calls `-start`.
 */

@property (nonatomic, weak, readwrite, nullable) id<DFPingDelegate> delegate;

/*! Controls the IP address version used by the object.
 *  \details You should set this value before starting the object.
 */

@property (nonatomic, assign, readwrite) DFPingAddressStyle addressStyle;

/*! The address being pinged.
 *  \details The contents of the NSData is a (struct sockaddr) of some form.  The
 *      value is nil while the object is stopped and remains nil on start until
 *      `-DFPing:didStartWithAddress:` is called.
 */

@property (nonatomic, copy, readonly, nullable) NSData * hostAddress;

/*! The address family for `hostAddress`, or `AF_UNSPEC` if that's nil.
 */

@property (nonatomic, assign, readonly) sa_family_t hostAddressFamily;

/*! The identifier used by pings by this object.
 *  \details When you create an instance of this object it generates a random identifier
 *      that it uses to identify its own pings.
 */

@property (nonatomic, assign, readonly) uint16_t identifier;

/*! The next sequence number to be used by this object.
 *  \details This value starts at zero and increments each time you send a ping (safely
 *      wrapping back to zero if necessary).  The sequence number is included in the ping,
 *      allowing you to match up requests and responses, and thus calculate ping times and
 *      so on.
 */

@property (nonatomic, assign, readonly) uint16_t nextSequenceNumber;

/*! Starts the object.
 *  \details You should set up the delegate and any ping parameters before calling this.
 *
 *      If things go well you'll soon get the `-DFPing:didStartWithAddress:` delegate
 *      callback, at which point you can start sending pings (via `-sendPingWithData:`) and
 *      will start receiving ICMP packets (either ping responses, via the
 *      `-DFPing:didReceivePingResponsePacket:sequenceNumber:` delegate callback, or
 *      unsolicited ICMP packets, via the `-DFPing:didReceiveUnexpectedPacket:` delegate
 *      callback).
 *
 *      If the object fails to start, typically because `hostName` doesn't resolve, you'll get
 *      the `-DFPing:didFailWithError:` delegate callback.
 *
 *      It is not correct to start an already started object.
 */

- (void)start;

/*! Sends a ping packet containing the specified data.
 *  \details Sends an actual ping.
 *
 *      The object must be started when you call this method and, on starting the object, you must
 *      wait for the `-DFPing:didStartWithAddress:` delegate callback before calling it.
 *  \param data Some data to include in the ping packet, after the ICMP header, or nil if you
 *      want the packet to include a standard 56 byte payload (resulting in a standard 64 byte
 *      ping).
 */

- (void)sendPingWithData:(nullable NSData *)data;

/*! Stops the object.
 *  \details You should call this when you're done pinging.
 *
 *      It's safe to call this on an object that's stopped.
 */

- (void)stop;

@end

/*! A delegate protocol for the DFPing class.
 */

@protocol DFPingDelegate <NSObject>

@optional

/*! A DFPing delegate callback, called once the object has started up.
 *  \details This is called shortly after you start the object to tell you that the
 *      object has successfully started.  On receiving this callback, you can call
 *      `-sendPingWithData:` to send pings.
 *
 *      If the object didn't start, `-DFPing:didFailWithError:` is called instead.
 *  \param pinger The object issuing the callback.
 *  \param address The address that's being pinged; at the time this delegate callback
 *      is made, this will have the same value as the `hostAddress` property.
 */

- (void)DFPing:(DFPing *)pinger didStartWithAddress:(NSData *)address;

/*! A DFPing delegate callback, called if the object fails to start up.
 *  \details This is called shortly after you start the object to tell you that the
 *      object has failed to start.  The most likely cause of failure is a problem
 *      resolving `hostName`.
 *
 *      By the time this callback is called, the object has stopped (that is, you don't
 *      need to call `-stop` yourself).
 *  \param pinger The object issuing the callback.
 *  \param error Describes the failure.
 */

- (void)DFPing:(DFPing *)pinger didFailWithError:(NSError *)error;

/*! A DFPing delegate callback, called when the object has successfully sent a ping packet.
 *  \details Each call to `-sendPingWithData:` will result in either a
 *      `-DFPing:didSendPacket:sequenceNumber:` delegate callback or a
 *      `-DFPing:didFailToSendPacket:sequenceNumber:error:` delegate callback (unless you
 *      stop the object before you get the callback).  These callbacks are currently delivered
 *      synchronously from within `-sendPingWithData:`, but this synchronous behaviour is not
 *      considered API.
 *  \param pinger The object issuing the callback.
 *  \param packet The packet that was sent; this includes the ICMP header (`ICMPHeader`) and the
 *      data you passed to `-sendPingWithData:` but does not include any IP-level headers.
 *  \param sequenceNumber The ICMP sequence number of that packet.
 */

- (void)DFPing:(DFPing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber;

/*! A DFPing delegate callback, called when the object fails to send a ping packet.
 *  \details Each call to `-sendPingWithData:` will result in either a
 *      `-DFPing:didSendPacket:sequenceNumber:` delegate callback or a
 *      `-DFPing:didFailToSendPacket:sequenceNumber:error:` delegate callback (unless you
 *      stop the object before you get the callback).  These callbacks are currently delivered
 *      synchronously from within `-sendPingWithData:`, but this synchronous behaviour is not
 *      considered API.
 *  \param pinger The object issuing the callback.
 *  \param packet The packet that was not sent; see `-DFPing:didSendPacket:sequenceNumber:`
 *      for details.
 *  \param sequenceNumber The ICMP sequence number of that packet.
 *  \param error Describes the failure.
 */

- (void)DFPing:(DFPing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error;

/*! A DFPing delegate callback, called when the object receives a ping response.
 *  \details If the object receives an ping response that matches a ping request that it
 *      sent, it informs the delegate via this callback.  Matching is primarily done based on
 *      the ICMP identifier, although other criteria are used as well.
 *  \param pinger The object issuing the callback.
 *  \param packet The packet received; this includes the ICMP header (`ICMPHeader`) and any data that
 *      follows that in the ICMP message but does not include any IP-level headers.
 *  \param sequenceNumber The ICMP sequence number of that packet.
 */

- (void)DFPing:(DFPing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber;

/*! A DFPing delegate callback, called when the object receives an unmatched ICMP message.
 *  \details If the object receives an ICMP message that does not match a ping request that it
 *      sent, it informs the delegate via this callback.  The nature of ICMP handling in a
 *      BSD kernel makes this a common event because, when an ICMP message arrives, it is
 *      delivered to all ICMP sockets.
 *
 *      IMPORTANT: This callback is especially common when using IPv6 because IPv6 uses ICMP
 *      for important network management functions.  For example, IPv6 routers periodically
 *      send out Router Advertisement (RA) packets via Neighbor Discovery Protocol (NDP), which
 *      is implemented on top of ICMP.
 *
 *      For more on matching, see the discussion associated with
 *      `-DFPing:didReceivePingResponsePacket:sequenceNumber:`.
 *  \param pinger The object issuing the callback.
 *  \param packet The packet received; this includes the ICMP header (`ICMPHeader`) and any data that
 *      follows that in the ICMP message but does not include any IP-level headers.
 */

- (void)DFPing:(DFPing *)pinger didReceiveUnexpectedPacket:(NSData *)packet;
@end

#pragma mark * ICMP On-The-Wire Format

/*! Describes the on-the-wire header format for an ICMP ping.
 *  \details This defines the header structure of ping packets on the wire.  Both IPv4 and
 *      IPv6 use the same basic structure.
 *
 *      This is declared in the header because clients of DFPing might want to use
 *      it parse received ping packets.
 */

struct DF_ICMPHeader {
    uint8_t     type;
    uint8_t     code;
    uint16_t    checksum;
    uint16_t    identifier;
    uint16_t    sequenceNumber;
};
typedef struct DF_ICMPHeader DF_ICMPHeader;

__Check_Compile_Time(sizeof(DF_ICMPHeader) == 8);
__Check_Compile_Time(offsetof(DF_ICMPHeader, type) == 0);
__Check_Compile_Time(offsetof(DF_ICMPHeader, code) == 1);
__Check_Compile_Time(offsetof(DF_ICMPHeader, checksum) == 2);
__Check_Compile_Time(offsetof(DF_ICMPHeader, identifier) == 4);
__Check_Compile_Time(offsetof(DF_ICMPHeader, sequenceNumber) == 6);

enum {
    DF_ICMPv4TypeEchoRequest = 8,          ///< The ICMP `type` for a ping request; in this case `code` is always 0.
    DF_ICMPv4TypeEchoReply   = 0           ///< The ICMP `type` for a ping response; in this case `code` is always 0.
};

enum {
    DF_ICMPv6TypeEchoRequest = 128,        ///< The ICMP `type` for a ping request; in this case `code` is always 0.
    DF_ICMPv6TypeEchoReply   = 129         ///< The ICMP `type` for a ping response; in this case `code` is always 0.
};

NS_ASSUME_NONNULL_END

typedef void(^DFPING_RET)(int ret);
@interface DFSimplePing : NSObject

+(id _Nonnull )sharedMe;
-(void)pingNetWork:(DFPING_RET _Nonnull )result;

@end



