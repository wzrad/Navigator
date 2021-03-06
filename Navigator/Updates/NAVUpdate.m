//
//  NAVUpdate.m
//  Navigator
//

#import "NAVUpdate.h"
#import "NAVUpdateStack.h"
#import "NAVUpdateAnimation.h"
#import "NAVRouterUtilities.h"

@implementation NAVUpdate

+ (instancetype)updateWithType:(NAVUpdateType)type element:(NAVURLElement *)element attributes:(NAVAttributes *)attributes
{
    NSParameterAssert(type);
    NSParameterAssert(element);
    NSParameterAssert(attributes);
    
    Class klass = type == NAVUpdateTypeAnimation ? [NAVUpdateAnimation class] : [NAVUpdateStack class];
    return [[klass alloc] initWithType:type element:element attributes:attributes];
}

- (instancetype)initWithType:(NAVUpdateType)type element:(NAVURLElement *)element attributes:(NAVAttributes *)attributes
{
    if(self = [super init]) {
        _type = type;
        _element = element;
        _attributes = attributes;
    }
    
    return self;
}

# pragma mark - Lifecycle

- (void)prepareWithRoute:(NAVRoute *)route factory:(id<NAVRouterFactory>)factory
{
    
}

- (void)performWithUpdater:(id<NAVRouterUpdater>)updater completion:(void (^)(BOOL))completion
{
    
}

# pragma mark - Accessors

- (BOOL)isAnimated
{
    NAVAssert(self.delegate != nil, NSInternalInconsistencyException, @"Must have a delegate.");
    return [self.delegate shouldAnimateUpdate:self];
}

- (BOOL)isAsynchronous
{
    return NO;
}

- (BOOL)completesAsynchrnously
{
    return NO;
}

@end
