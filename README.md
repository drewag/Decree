Declarative HTTP Requests
==============

Make HTTP requests in a clear and type safe way by declaratively defining web services and endpoints.

Table of Contents
--------------

- [Features](#features)
- [Installation](#installation)
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

**Two Input formats**
- JSON
- URL Query

**Configable**
- Customize URLRequest (e.g. custom headers)
- Customize JSON encoders and decoders
- Custom response validation
- Custom error response format
- Custom standard response format

**Virtually 100% Code Coverage**
    
Installation
---------

### iOS

As git submodule

- Run `git submodle add https://github.com/drewag/DeclarativeHTTPRequests.git external/DeclarativeHTTPRequests`
- Drag 'DeclarativeHTTPRequestsiOS.xcodeproj' into your project
- Add `import DeclarativeHTTPRequests` to the top of any file you would like to use this library in

Linux and macOS
----------------

### Using Swift Package Manager
```swift
import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .Package(url: "https://github.com/drewag/DeclarativeHTTPRequests.git", majorVersion: 0),
    ]
)
```

Examples
----------
Here are a few examples of how this framework is used.

### Simple Get

Here we define a `CheckStatus` endpoint that is a GET with no input or output that exists at the path “/status”.
Scroll down to see the defintion of ExampleService.

```swift
struct CheckStatus: EmptyEndpoint {
    typealias Service = ExampleService
    static let method = Method.get

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
    
We can also make synchronous requests that simply throw an error if an error occures.

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
    static let inputFormat = InputFormat.JSON

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

    // Use URLSession.shared
    var sessionOverride: URLSession? { return nil }

    // All requests will be sent to their endpoint at "https://example.com"
    var baseURL: URL { return URL(string: "https://example.com")! }

    // Don't do any configuration of request, encoders, or decoders
    func configure(_ request: inout URLRequest) throws {}
    func configure(_ encoder: inout JSONEncoder) throws {}
    func configure(_ decoder: inout JSONDecoder) throws {}

    // Validate that the response codes are in the 200 range
    func validate<E>(_ response: URLResponse, for endpoint: E) throws where E : Endpoint {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard statusCode >= 200 && statusCode < 300 else {
            throw RequestError.custom("Bad status code: \(statusCode)")
        }
    }

    // This will not be called because we've specified NoBasicResponse
    func validate<E>(_ response: NoBasicResponse, for endpoint: E) throws where E : Endpoint {}
}
```
    
Here we define a `WebService` called `ExampleService` with the a few properties and some extra validation.

That's all you need. You can then define as many endpoints as you like and use them in a clear and type safe way.

Hopeful Features
------------

It would be great to develop the following additional features

- Better handle authenticated requests by defining a web services authentication mechanism and allow an endpoint to require auth
- Form URL encoded input format
- Additional output formats
- File download and uploading

Contributing
---------

It is very much encouraged for you to report any issues and/or make pull requests for new functionality.
