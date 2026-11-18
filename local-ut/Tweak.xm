#import <Foundation/Foundation.h>

typedef void (^NimbleLoginCompletion)(id result, id error);

// The first build touched the anonymous UPID authenticator, but the failed
// screen invokes NimbleAuthenticatorOrigin. Return an empty local result and
// no error to skip that retired Origin login exchange. The app may still need
// additional FUT service responses after this callback.
%hook NimbleAuthenticatorOrigin

- (void)login:(id)loginType callback:(NimbleLoginCompletion)completion {
    NSLog(@"[FIFA14LocalUT] Origin login bypass invoked; returning local completion");
    if (completion) {
        completion(nil, nil);
    }
}

- (int)getState {
    return 3;
}

%end
