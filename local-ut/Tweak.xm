#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

typedef void (^NimbleLoginCompletion)(id result, id error);

static void FUTWriteLine(const char *path, const char *line) {
    int fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0644);
    if (fd < 0) return;
    size_t length = strlen(line);
    while (length) {
        ssize_t written = write(fd, line, length);
        if (written <= 0) break;
        line += written;
        length -= (size_t)written;
    }
    close(fd);
}

// This runs without Objective-C/Foundation, so it proves whether dyld loaded
// the tweak even if Logos or an app hook fails later.
__attribute__((constructor(101)))
static void FUTEarlyConstructor(void) {
    char line[160];
    snprintf(line, sizeof(line), "FIFA14LocalUT dylib constructor pid=%d\n", getpid());
    FUTWriteLine("/tmp/FIFA14LocalUT.log", line);
    FUTWriteLine("/var/mobile/Library/Logs/FIFA14LocalUT.log", line);
}

static void FUTLog(NSString *message) {
    @autoreleasepool {
        time_t now = time(NULL);
        struct tm tmNow;
        localtime_r(&now, &tmNow);
        const char *text = [message UTF8String];
        if (!text) text = "(message encoding failed)";
        char line[2048];
        snprintf(line, sizeof(line),
                 "%04d-%02d-%02d %02d:%02d:%02d pid=%d %s\n",
                 tmNow.tm_year + 1900, tmNow.tm_mon + 1, tmNow.tm_mday,
                 tmNow.tm_hour, tmNow.tm_min, tmNow.tm_sec, getpid(), text);
        FUTWriteLine("/tmp/FIFA14LocalUT.log", line);
        FUTWriteLine("/var/mobile/Library/Logs/FIFA14LocalUT.log", line);

        NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *path = [documents stringByAppendingPathComponent:@"FIFA14LocalUT.log"];
        FUTWriteLine([path fileSystemRepresentation], line);
        NSLog(@"[FIFA14LocalUT] %@", message);
    }
}

static void FUTReportMethod(const char *className, const char *selectorName) {
    Class cls = objc_getClass(className);
    BOOL present = cls && class_getInstanceMethod(cls, sel_registerName(selectorName));
    FUTLog([NSString stringWithFormat:@"runtime check %s -%s: %@",
            className, selectorName, present ? @"present" : @"MISSING"]);
}

// These are the class names and selectors read from FIFA14's Objective-C
// metadata. The old package targeted a class that does not exist in this app.
%hook NimbleIdentityAuthenticatorBase

- (void)setState:(int)state {
    FUTLog([NSString stringWithFormat:@"Nimble authenticator setState:%d", state]);
    %orig(state);
}

- (int)getState {
    int state = %orig;
    if (state != 3) {
        FUTLog([NSString stringWithFormat:@"Nimble authenticator state %d -> 3; committing local-authenticated state", state]);
        [self setState:3];
        state = %orig;
    }
    return state;
}

%end

%hook NimbleAuthenticatorAnonymous

- (void)autoLogin {
    FUTLog(@"Anonymous autoLogin reached; suppressing retired UPID token request");
    // The only automatic login request in the supplied Nimble.log is the dead
    // accounts.ea.com/connect/upidtoken exchange.
}

- (void)getUpidToken {
    FUTLog(@"Anonymous getUpidToken reached; suppressed");
}

- (void)exchangeUpidTokenForAuthCode {
    FUTLog(@"Anonymous exchangeUpidTokenForAuthCode reached; suppressed");
}

- (void)login:(id)loginType callback:(NimbleLoginCompletion)completion {
    FUTLog(@"Anonymous login:callback: reached; invoking completion with no server result");
    if (completion) completion(nil, nil);
}

%end

%hook NimbleOriginCore

- (BOOL)isOriginReady {
    FUTLog(@"Origin isOriginReady forced YES for offline mode");
    return YES;
}

- (int)getLoginStatus {
    int status = %orig;
    if (status != 3) {
        FUTLog([NSString stringWithFormat:@"Origin login status %d -> 3; committing local-ready state", status]);
        [self updateStatus:3];
        status = %orig;
    }
    return status;
}

- (void)loadOrigin {
    FUTLog(@"Origin loadOrigin suppressed for offline mode");
}

- (void)updateStatus:(int)status {
    FUTLog([NSString stringWithFormat:@"Origin updateStatus:%d", status]);
    %orig(status);
}

- (id)getAuthentications {
    id value = %orig;
    FUTLog([NSString stringWithFormat:@"Origin getAuthentications -> %@", value]);
    return value;
}

- (void)showView:(int)view {
    FUTLog([NSString stringWithFormat:@"Origin showView:%d", view]);
    %orig(view);
}

%end

%hook NimbleIdentityImpl

- (id)getLoggedInAuthenticators {
    id result = %orig;
    FUTLog([NSString stringWithFormat:@"Identity getLoggedInAuthenticators -> %@", result]);
    return result;
}

- (void)onAuthenticatorStateChange:(id)authenticator {
    FUTLog([NSString stringWithFormat:@"Identity onAuthenticatorStateChange:%@", authenticator]);
    %orig(authenticator);
}

%end

%hook NimbleSynergyIdManagerImpl

- (id)loginWithSynergyId:(id)synergyId withAuthenticator:(id)authenticator {
    FUTLog([NSString stringWithFormat:@"Synergy login requested: id=%@ authenticator=%@", synergyId, authenticator]);
    id result = %orig(synergyId, authenticator);
    FUTLog([NSString stringWithFormat:@"Synergy login returned: %@", result]);
    return result;
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
    FUTLog(@"Origin webview did start load");
    %orig(webView);
}

- (void)webViewDidFinishLoad:(id)webView {
    FUTLog(@"Origin webview did finish load");
    %orig(webView);
}

- (void)webView:(id)webView didFailLoadWithError:(NSError *)error {
    FUTLog([NSString stringWithFormat:@"Origin webview failed: %@", error]);
    %orig(webView, error);
}

%end

%ctor {
    FUTLog(@"Logos constructor entered");
    FUTReportMethod("NimbleIdentityAuthenticatorBase", "getState");
    FUTReportMethod("NimbleAuthenticatorAnonymous", "autoLogin");
    FUTReportMethod("NimbleOriginCore", "getLoginStatus");
    FUTReportMethod("NimbleIdentityImpl", "getLoggedInAuthenticators");
    FUTReportMethod("NimbleSynergyIdManagerImpl", "loginWithSynergyId:withAuthenticator:");
    FUTReportMethod("NimbleOriginWebController", "loadBootstrap");
    %init;
    FUTLog(@"Logos hooks initialized");
}
