# GitParser

This is a swift package currently in development. It is meant as a parser for git outputs for swift, returning an OO result. Do not consider this as done. 

It is used by the project [GitBuddy](https://github.com/klein-artur/GitBuddy) in combination with [GitParser](https://github.com/klein-artur/GitCaller). 

## How it works.

The idea is to have different parsers for different git outputs to change the output in a better to handle result. 

For example a `git log` output can be parsed by `LogResultParser().parse(result: theGitOutputString)`.

The project performs the best in combination with [GitParser](https://github.com/klein-artur/GitCaller).

Extend a command of `GitCaller` to conform the protocol `Parsable` like for example this:

```swift

extension CommandLog: Parsable {
    
    public typealias Success = LogResult
    
    public var parser: LogResultParser {
        return LogResultParser()
    }
}

```

Then you can use:
 - `Git().log.results()` to get a `Combine` `Publisher`.
 - `Git().log.finalResult()` to get the `async` function with the final result of the call.
 
