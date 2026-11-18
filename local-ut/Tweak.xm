#import <Foundation/Foundation.h>

// Static inspection of FIFA14.app shows NimbleIdentityImpl's
// getLoggedInAuthenticators accepts an authenticator whose state is 3.
// This experiment marks only the anonymous authenticator as locally
// authenticated, preventing the retired UPID/Origin login from gating it.
// It does not emulate FUT REST/Blaze responses or create a club yet.

%hook NimbleAuthenticatorAnonymous

- (int)getState {
    static BOOL logged;
    if (!logged) {
        logged = YES;
        NSLog(@"[FIFA14LocalUT] treating anonymous identity as authenticated (local test)");
    }
    return 3;
}

%end
