Declarative HTTP Requests
==============

*Make HTTP requests in a clear and type safe way by declaratively defining web services and endpoints on **iOS**, **macOS**, and **Linux***

When it comes to making URL requests with Swift, you largely have two options: use the URLSession APIs in Foundation or use some heavy handed framework.

This framework is designed to be light-weight while remaining customizable and focusing on declaring the interface to an API in a declarative manner. Once declared, making requests to the various endpoints is very straight-forward and type safe. It works on iOS, macOS, and Linux.

I developed this strategy through the implementation of many different apps and backend services written in Swift. I've used this paradigm for communicating between my own front and back-ends (both implemented in Swift) as well as to services such as Spotify, Freshdesk, Stripe, and more.

Table of Contents
--------------

- [Features](#features)
- [Getting Started](https://github.com/drewag/DeclarativeHTTPRequests/wiki)
- [Examples](#examples)
- [Hopeful Features](#hopeful-features)
- [Contributing](#contributing)

Features
--------

**Four types of Endpoints**
- `EmptyEndpoint` (no input or output)
- `InEndpoint` (only input)
- `OutEndpoint` (only output)
- `InOutEndpoint` (input and output)

**Three Input formats**
- JSON
- URL Query
- Form URL Encoded

**Configable**
- Customize URLRequest (e.g. custom headers)
- Customize JSON encoders and decoders
- Custom response validation
- Custom error response format
- Custom standard response format

**Virtually 100% Code Coverage**

Examples
----------
Here are a few examples of how this framework is used.

### Simple Get

Here we define a `CheckStatus` endpoint that is a GET (the default) with no input or output that exists at the path “/status”.
Scroll down to see the definition of ExampleService.

```swift
struct CheckStatus: EmptyEndpoint {
    typealias Service = ExampleService

    let path = "status"
}
```

We can then use that definition to make asynchronous requests.

```swift
CheckStatus().makeRequest() { result in
    switch result {
    case .success:
        print("Success :)")
    case .failure(let error):
        print("Error :( \(error)")
    }
}
```
    
We can also make synchronous requests that simply throw an error if an error occurs.

```swift
try CheckStatus().makeSynchronousRequest()
```
    
### Input and Output

We can also define endpoints that have input and/or output. Here, we define a Login endpoint that is a
POST to “/login” with username and password parameters encoded as JSON. If successful, the endpoint is
expected to return a token.

```swift
struct Login: InOutEndpoint {
    typealias Service = ExampleService
    static let method = Method.post

    let path = "login"

    struct Input: Encodable {
        let username: String
        let password: String
    }

    struct Output: Decodable {
        let token: String
    }
}
```
    
Then we can make an asynchronous request.

```swift
Login().makeRequest(with: .init(username: "username", password: "secret")) { result in
    switch result {
    case .success(let output):
        print("Token: \(output.token)")
    case .failure(let error):
        print("Error :( \(error)")
    }
}
```

Or we can make a synchronous requests that returns the output if successful and throws otherwise.

```swift
let token = try Login().makeSynchronousRequest(with: .init(username: "username", password: "secret")).token
```

### The Service Definition

The only extra code necessary to make the above examples work, is to define the ExampleService:

```swift
struct ExampleService: WebService {
    // There is no service wide standard response format
    typealias BasicResponse = NoBasicResponse

    // Errors will be in the format {"message": "<reason>"}
    struct ErrorResponse: AnyErrorResponse {
        let message: String
    }

    // Requests should use this service instance by default
    static var shared = ExampleService()

    // All requests will be sent to their endpoint at "https://example.com"
    let baseURL = URL(string: "https://example.com")!
}
```
    
Here we define a `WebService` called `ExampleService` with the a few properties.

That's all you need. You can then define as many endpoints as you like and use them in a clear and type safe way.

Hopeful Features
------------

It would be great to develop the following additional features

- Better handle authenticated requests by defining a web services authentication mechanism and allow an endpoint to require auth
- Additional output formats
- File download and uploading

Contributing
---------

It is very much encouraged for you to report any issues and/or make pull requests for new functionality.
