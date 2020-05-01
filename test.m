#import "Base.h"

@interface Cantaloupe : Base
@end

@implementation Cantaloupe
@end

int main() {
    @try {
        Cantaloupe *cantaloupe = [Cantaloupe new];
        NSLog(@"count = %lu", (unsigned long) [cantaloupe count]);
        NSLog(@"options = %lu", (unsigned long) [cantaloupe options]);
        NSLog(@"length = %lu", (unsigned long) [cantaloupe length]);
        NSLog(@"isDirectory = %d", (BOOL) [cantaloupe isDirectory]);
        NSLog(@"UTF8String = \"%s\"", [cantaloupe UTF8String]);
    } @catch (id ex) {
        NSLog(@"Caught exception: %@", ex);
    }
}
