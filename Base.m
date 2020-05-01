#import "Base.h"
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSInvocation.h>
#import <stdlib.h>

@class NSObject;

@interface NSInvocation (UsingIMP)
- (void) invokeUsingIMP: (IMP) imp;
@end

@implementation Base

static struct MethodInfo {
    BOOL instance;
    Method method;
} *methods;
static unsigned int totalMethodCount;

+ (void) initialize {
    if (methods != NULL) {
        return;
    }

    unsigned int classesCount;
    Class *classes = objc_copyClassList(&classesCount);
    for (unsigned int i = 0; i < classesCount; i++) {
        Class class = classes[i];
        BOOL inheritsFromNSObject = NO;
        for (Class ancestor = class; ancestor != Nil; ancestor = class_getSuperclass(ancestor)) {
            if (ancestor == [NSObject class]) {
                inheritsFromNSObject = YES;
                break;
            }
        }
        if (!inheritsFromNSObject) {
            continue;
        }

        unsigned int instanceMethodCount;
        Method *instanceMethods = class_copyMethodList(class, &instanceMethodCount);
        methods = realloc(methods, sizeof(struct MethodInfo) * (totalMethodCount + instanceMethodCount));
        for (unsigned int j = 0; j < instanceMethodCount; j++) {
            methods[totalMethodCount + j] = (struct MethodInfo) {
                .instance = YES,
                .method = instanceMethods[j]
            };
        }
        totalMethodCount += instanceMethodCount;
        free(instanceMethods);

        unsigned int classMethodCount;
        Method *classMethods = class_copyMethodList(object_getClass(class), &classMethodCount);
        methods = realloc(methods, sizeof(struct MethodInfo) * (totalMethodCount + classMethodCount));
        for (unsigned int j = 0; j < classMethodCount; j++) {
            methods[totalMethodCount + j] = (struct MethodInfo) {
                .instance = NO,
                .method = classMethods[j]
            };
        }
        totalMethodCount += classMethodCount;
        free(classMethods);
    }
    free(classes);
}

static Method methodForSelector(SEL selector, BOOL instance) {
    for (unsigned int i = 0; i < totalMethodCount; i++) {
        if (methods[i].instance == instance && method_getName(methods[i].method) == selector) {
            return methods[i].method;
        }
    }
    return NULL;
}

+ (NSMethodSignature *) methodSignatureForSelector: (SEL) selector {
    Method method = methodForSelector(selector, NO);
    if (method == NULL) {
        return nil;
    }
    const char *types = method_getTypeEncoding(method);
    return [NSMethodSignature signatureWithObjCTypes: types];
}

+ (void) forwardInvocation: (NSInvocation *) invocation {
    Method method = methodForSelector([invocation selector], NO);
    if (method != NULL) {
        IMP imp = method_getImplementation(method);
        [invocation invokeUsingIMP: imp];
    }
}

- (NSMethodSignature *) methodSignatureForSelector: (SEL) selector {
    Method method = methodForSelector(selector, YES);
    if (method == NULL) {
        return nil;
    }
    const char *types = method_getTypeEncoding(method);
    return [NSMethodSignature signatureWithObjCTypes: types];
}

- (void) forwardInvocation: (NSInvocation *) invocation {
    Method method = methodForSelector([invocation selector], YES);
    if (method != NULL) {
        IMP imp = method_getImplementation(method);
        [invocation invokeUsingIMP: imp];
    }
}

@end
