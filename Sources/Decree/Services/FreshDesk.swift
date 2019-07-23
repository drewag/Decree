//
//  FreshDesk.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/22/19.
//

import Foundation

/// Fresh Desk API V2
///
/// https://developers.freshdesk.com/api/
public struct FreshDesk: WebService {
    public typealias BasicResponse = NoBasicResponse

    public struct ErrorResponse: AnyErrorResponse {
        let description: String

        public var message: String { return self.description }
    }

    public static var shared = FreshDesk()
    public private(set) var authorization: Authorization = .none

    public mutating func configure(domain: String, apiKey: String) {
        self.domain = domain
        self.authorization = .basic(username: apiKey, password: "")
    }

    public var sessionOverride: Session?

    var domain = "invalid"

    public var baseURL: URL {
        guard let url = URL(string: "https://\(self.domain).freshdesk.com/api/v2") else {
            return URL(string: "http://invalid")!
        }
        return url
    }
}

extension FreshDesk {
    /// Create a new FreshDesk ticket
    public struct CreateTicket: InEndpoint {
        public typealias Service = FreshDesk

        public typealias Input = Ticket
        public static let inputFormat = InputFormat.formData

        public static let method = Method.post

        public let path = "tickets"

        public init() {}
    }

    /// A FreshDesk Ticket
    public struct Ticket: Encodable {
        /// The type of ticket
        public enum Kind: String, Encodable {
            case featureRequest = "Feature Request"
            case bug = "Bug"
            case feedback = "Feedback"
            case question = "Question"
        }

        /// Where the ticket was created
        public enum Source: Int, Encodable {
            case email = 1
            case portal
            case phone
            case chat
            case mobihelp
            case feedbackWidget
            case outboundEmail
        }

        /// Status of the ticket
        public enum Status: Int, Encodable {
            case open = 2
            case pending
            case resolved
            case closed
        }

        /// Priority of the ticket
        public enum Priority: Int, Encodable {
            case low = 1
            case medium
            case high
            case urgent
        }

        let type: Kind?
        let source: Source
        let status: Status
        let priority: Priority
        let name: String?
        let email: String
        let subject: String
        let description: String
        let attachments: [File]?

        /// Initialize a new tickekt
        ///
        /// - Parameters:
        ///     - kind: the kind of ticket
        ///     - source: where the ticket comes from
        ///     - status: the status of the ticket
        ///     - priority: the priority of the ticket
        ///     - name: the name of the person creating the ticket
        ///     - email: the email of the person creating the ticket
        ///     - subject: the subject of the ticket
        ///     - description: the body of the ticket
        ///     - attachments: files to attach to the ticket
        public init(
            kind: Kind?,
            source: Source,
            status: Status,
            priority: Priority,
            name: String?,
            email: String,
            subject: String,
            description: String,
            attachments: [File]?
            )
        {
            self.type = kind
            self.source = source
            self.status = status
            self.priority = priority
            self.name = name
            self.email = email
            self.subject = subject
            self.description = description
            self.attachments = attachments
        }
    }

}
