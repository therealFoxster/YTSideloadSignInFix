#import <Foundation/Foundation.h>

/**
 *	Fix YouTube sign-in
 *	YTSignInFix.xm (https://gist.github.com/AhmedBafkir/0c16b806b3fb233995aa01b93da44f93)
 */

%hook SSORPCService

+ (id)URLFromURL:(id)arg1 withAdditionalFragmentParameters:(NSDictionary *)arg2 {
    NSURL *orig = %orig;
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:orig resolvingAgainstBaseURL:NO];
    NSMutableArray *newQueryItems = [urlComponents.queryItems mutableCopy];
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"system_version"]
            || [queryItem.name isEqualToString:@"app_version"]
            || [queryItem.name isEqualToString:@"kdlc"]
            || [queryItem.name isEqualToString:@"kss"]
            || [queryItem.name isEqualToString:@"lib_ver"]
            || [queryItem.name isEqualToString:@"device_model"]) {
            [newQueryItems removeObject:queryItem];
        }
    }
    urlComponents.queryItems = [newQueryItems copy];
    return urlComponents.URL;
}

%end

/**
 *	Fix YouTube keychain
 *	fixYouTubeLogin.m (https://gist.github.com/BandarHL/492d50de46875f9ac7a056aad084ac10)
 */

static NSString *accessGroupID() {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status != errSecSuccess)
            return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];

    return accessGroup;
}

// Versions >= 17.33.2
%hook SSOKeychainCore

+ (NSString *)accessGroup {
    return accessGroupID();
}

+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}

%end

// Versions < 17.33.2
%hook SSOKeychain

+ (NSString *)accessGroup {
    return accessGroupID();
}

+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}

%end

// Fix appGroup path
%hook NSFileManager

- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier != nil) {
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsURL = [paths lastObject];
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }
    return %orig(groupIdentifier);
}

%end