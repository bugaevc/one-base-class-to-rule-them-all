# One Base Class to Rule Them All

This is an Objective-C port of the universal `Base` class as described in
https://www.destroyallsoftware.com/blog/2011/one-base-class-to-rule-them-all.
Instances of the `Base` class (or its subclasses) respond to any selector any
other class responds to.

Let's make a subclass of `Base`:

```objc
#import "Base.h"

@interface Cantaloupe : Base
@end

@implementation Cantaloupe
@end
```

(This is not required, but the original post does it, and we'll do it as well.)
Now we can create an instance of this class:

```objc
Cantaloupe *cantaloupe = [Cantaloupe new];
```

If you're lucky, you'll get the `new` method from `NSObject`, and the call will
succeed, giving you a fresh cantaloupe. What can we do with it? Let's try
`count`:

```objc
NSLog(@"count = %lu", (unsigned long) [cantaloupe count]);
```

which gives us 0! Why is it zero? What class was that method from, and where
did it get that value from? Who cares! Let's call more methods:

```objc
NSLog(@"options = %lu", (unsigned long) [cantaloupe options]);
NSLog(@"length = %lu", (unsigned long) [cantaloupe length]);
NSLog(@"isDirectory = %d", (BOOL) [cantaloupe isDirectory]);
NSLog(@"UTF8String = \"%s\"", [cantaloupe UTF8String]);
```

Apparently, it also has a length of zero and is not a directory. On the system
I'm testing this on, the options returned are 64. What options are there? Where
does that value come from? Who cares!

Its UTF-8 representation is an empty C string. That is, an actual `char`
pointer which points to a zero byte. This is even consistent with its `length`
being 0. Cool!
