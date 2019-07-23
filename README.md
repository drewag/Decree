![Decree - Declarative HTTP Requests](https://github.com/drewag/Decree/raw/master/Assets/Header.jpg)

[![Swift](https://img.shields.io/badge/Swift-5.0-lightgrey.svg?colorA=28a745&colorB=4E4E4E)](https://swift.org)
![platforms](https://img.shields.io/badge/Platforms-iOS%208%20%7C%20macOS%2010.10%20%7C%20Linux-lightgrey.svg?colorA=28a745&colorB=4E4E4E)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CryptoSwift.svg?style=flat&label=CocoaPods&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/CryptoSwift)
[![MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](/LICENSE)

[![Twitter @drewag](https://img.shields.io/badge/Twitter-@drewag-blue.svg?style=flat)](http://twitter.com/drewag)
[![Blog drewag.me](https://img.shields.io/badge/Blog-drewag.me-blue.svg?style=flat)](http://drewag.me)

*Make HTTP requests in a clear and type safe way by declaratively defining web services and endpoints on **iOS**, **macOS**, and **Linux***

When it comes to making URL requests with Swift, you largely have two options: use the URLSession APIs in Foundation or use some heavy handed framework.

This framework is designed to be light-weight while remaining customizable and focusing on declaring the interface to an API in a declarative manner. Once declared, making requests to the various endpoints is very straight-forward and type safe. It works on iOS, macOS, and Linux.

I developed this strategy through the implementation of many different apps and backend services written in Swift. I've used this paradigm for communicating between my own front and back-ends (both implemented in Swift) as well as to services such as Spotify, Freshdesk, Stripe, and more.

**We offer a separate repository [DecreeServices](https://github.com/drewag/DecreeServices) with service declarations for popular services** 

Table of Contents
--------------

- [Features](#features)
- [Getting Started](https://github.com/drewag/Decree/wiki)
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

**Five Input formats**
- JSON
- URL Query
- Form URL Encoded
- Form Data Encoded
- XML

**Two Output formats**
- JSON
- XML

**Three types of Authorization**
- Basic
- Bearer
- Custom

**Configurable**
- Customize URLRequest (e.g. custom headers)
- Customize JSON encoders and decoders
- Custom response validation
- Custom error response format
- Custom standard response format

**Virtually 100% Code Coverage**

**Third-Party Services**

We created a separate framework that defines services and endpoints for several third-party services. Check it out at [DecreeServices](https://github.com/drewag/DecreeServices).

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

### Real World Examples

To see real world examples, check out how we declared services in [DecreeServices](https://github.com/drewag/DecreeServices/tree/master/Sources/DecreeServices).

Hopeful Features
------------

It would be great to develop the following additional features

- File download and uploading

Contributing
---------

It is very much encouraged for you to report any issues and/or make pull requests for new functionality.
