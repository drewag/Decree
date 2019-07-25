//
//  InputFormat.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

/// Format for uploading data to endpoint
public enum InputFormat {
    /// [JSON](https://www.json.org)
    case JSON

    /// [XML](https://www.w3schools.com/xml/xml_whatis.asp)
    case XML(rootNode: String)

    /// [URL Query](https://en.wikipedia.org/wiki/Query_string)
    case urlQuery

    /// [Form URL Encoded](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST)
    case formURLEncoded

    /// [Form Data](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST)
    case formData
}
