//
//  NAVURLParser.m
//  Created by Ty Cobb on 7/18/14.
//

#import "NAVURLParser.h"

@implementation NAVURLParser

- (NSDictionary *)router:(NAVRouter *)router componentsForTransitionFromURL:(NAVURL *)sourceURL toURL:(NAVURL *)destinationURL
{
    NAVURLComponent *divergentComponent = [self divergentComponentFromURL:sourceURL toURL:destinationURL];
    NSInteger sourceDelta      = [self deltaForComponents:sourceURL.nav_components fromDivergentComponent:divergentComponent];
    NSInteger destinationDelta = [self deltaForComponents:destinationURL.nav_components fromDivergentComponent:divergentComponent];
    
    NAVURLComponent *hostToReplace = [divergentComponent isEqual:destinationURL.nav_host] ? destinationURL.nav_host : nil;
    NSArray *componentsToPop  = hostToReplace ? @[ ] : sourceURL.nav_components.last(sourceDelta);
    NSArray *componentsToPush = destinationURL.nav_components.last(destinationDelta);
    
    // we'll always have lists for parameters and push/pop components, even if they're empty
    NSMutableDictionary *components = [@{
        NAVURLKeyParametersToEnable  : [self paramatersToEnableFromURL:sourceURL toURL:destinationURL],
        NAVURLKeyParametersToDisable : [self paramatersToDisableFromURL:sourceURL toURL:destinationURL],
        NAVURLKeyComponentsToPop     : componentsToPop,
        NAVURLKeyComponentsToPush    : componentsToPush,
    } mutableCopy];
    
    // we might have a host, if it needs replacing
    [components setValue:hostToReplace forKey:NAVURLKeyComponentToReplace];
    
    return components;
}

//
// Helpers
//

- (NAVURLComponent *)divergentComponentFromURL:(NAVURL *)sourceURL toURL:(NAVURL *)destinationURL
{
    // if the host if different, then we diverge immediately
    if(![sourceURL.nav_host isEqual:destinationURL.nav_host])
        return destinationURL.nav_host;
    
    // otherwise we need to compare components, and we should always use the URL with the larger
    // component set as the source, in case the divergence point occurs after the last element of
    // the smaller set (like, when the smaller set has 0 items).
    BOOL destinationHasMoreComponents = destinationURL.nav_components.count > sourceURL.nav_components.count;
    NAVURL *comparing = destinationHasMoreComponents ? destinationURL : sourceURL;
    NAVURL *compared  = destinationHasMoreComponents ? sourceURL      : destinationURL;
    
    // so find the fisrt component between the two that doesnt match
    return comparing.nav_components.find(^BOOL(NAVURLComponent *component) {
        if(component.index >= compared.nav_components.count)
            return YES;
        return ![compared.nav_components[component.index] isEqual:component];
    });
}

- (NSInteger)deltaForComponents:(NSArray *)components fromDivergentComponent:(NAVURLComponent *)component
{
    if(component)
        return components.count - component.index;
    return 0;
}

- (NSArray *)paramatersToEnableFromURL:(NAVURL *)sourceURL toURL:(NAVURL *)destinationURL
{
    return destinationURL.nav_parameters.allKeys.map(^(NSString *key) {
        NAVURLParameter *sourceParameter = sourceURL.nav_parameters[key];
        NAVURLParameter *destinationParamater = destinationURL.nav_parameters[key];
        return !sourceParameter.isVisible && destinationParamater.isVisible;
    });
}

- (NSArray *)paramatersToDisableFromURL:(NAVURL *)sourceURL toURL:(NAVURL *)destinationURL
{
    NSArray *keySet = sourceURL.nav_parameters.allKeys.concat(destinationURL.nav_parameters.allKeys).uniq;
    return keySet.map(^(NSString *key) {
        NAVURLParameter *sourceParameter = sourceURL.nav_parameters[key];
        NAVURLParameter *destinationParameter = destinationURL.nav_parameters[key];
        return sourceParameter.isVisible && !destinationParameter.isVisible;
    });
}

@end