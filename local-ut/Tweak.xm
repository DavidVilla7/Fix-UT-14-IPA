#import <Foundation/Foundation.h>

typedef void (^NimbleLoginCompletion)(id result, id error);

static void FUTLog(NSString *message) {
    @autoreleasepool {
        NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *path = [documents stringByAppendingPathComponent:@"FIFA14LocalUT.log"];
        NSString *line = [NSString stringWithFormat:@"%@ %@\n", [NSDate date], message];
        NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
        if (handle) {
            [handle seekToEndOfFile];
            [handle writeData:data];
            [handle closeFile];
        }
    }
}

// Keep the Origin bypass under test, while recording whether Substrate loaded
// this tweak and which Origin webview/authentication methods the app reaches.
%hook NimbleAuthenticatorOrigin

- (void)login:(id)loginType callback:(NimbleLoginCompletion)completion {
    FUTLog(@"Origin login:callback: hook reached; returning (nil, nil)");
    if (completion) {
        completion(nil, nil);
    }
}

- (int)getState {
    FUTLog(@"Origin getState hook reached");
    return 3;
}

%end

%hook NimbleOriginWebController

- (void)loadBootstrap {
    FUTLog(@"Origin loadBootstrap reached");
    %orig;
}

- (void)handleRequest {
    FUTLog(@"Origin handleRequest reached");
    %orig;
}

- (void)webViewDidStartLoad:(id)webView {
    FUTLog([NSString stringWithFormat:@"Origin webViewDidStartLoad: %@", webView]);
    %orig(webView);
}

- (void)webViewDidFinishLoad:(id)webView {
    FUTLog([NSString stringWithFormat:@"Origin webViewDidFinishLoad: %@", webView]);
    %orig(webView);
}

- (void)webView:(id)webView didFailLoadWithError:(NSError *)error {
    FUTLog([NSString stringWithFormat:@"Origin webView didFailLoadWithError: %@", error]);
    %orig(webView, error);
}

%end

%ctor {
    FUTLog(@"Tweak loaded into FIFA14");
}
