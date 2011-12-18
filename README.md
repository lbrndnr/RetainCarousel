# RetainCarousel

## About
RetainCarousel is a small category that helps you finding retain cycles. It observes every accessor and checks whether this causes a retain cycle.

## Setup
Just add the RetainCarousel category and the JRSwizzle category to your project and you're ready to go. 

## Limitations
There's still a lot of work to do to improve RetainCarousel. Here are a few things that need enhancement.
### Performance
RetainCarousel obviously adds lots of work to every accessor which slows your app drastically down. So dont't use it in your release build!
### Retain Cycle Spotting
RetainCarousel only works with instance variables that have a property belonging to it.

## Credit
Thanks to rentzsch for his awesome [JRSwizzle](https://github.com/rentzsch/jrswizzle).

## License
RetainCarousel is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php). 
