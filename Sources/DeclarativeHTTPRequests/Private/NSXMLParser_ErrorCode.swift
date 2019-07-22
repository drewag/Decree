//
//  NSXMLParser_ErrorCode.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/21/19.
//

import Foundation

extension XMLParser.ErrorCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .internalError:
            return "The parser object encountered an internal error."
        case .outOfMemoryError:
            return "The parser object ran out of memory."
        case .documentStartError:
            return "The parser object is unable to start parsing."
        case .emptyDocumentError:
            return "The document is empty."
        case .prematureDocumentEndError:
            return "The document ended unexpectedly."
        case .invalidHexCharacterRefError:
            return "Invalid hexadecimal character reference encountered."
        case .invalidDecimalCharacterRefError:
            return "Invalid decimal character reference encountered."
        case .invalidCharacterRefError:
            return "Invalid character reference encountered."
        case .invalidCharacterError:
            return "Invalid character encountered."
        case .characterRefAtEOFError:
            return "Target of character reference cannot be found."
        case .characterRefInPrologError:
            return "Invalid character found in the prolog."
        case .characterRefInEpilogError:
            return "Invalid character found in the epilog."
        case .characterRefInDTDError:
            return "Invalid character encountered in the DTD."
        case .entityRefAtEOFError:
            return "Target of entity reference is not found."
        case .entityRefInPrologError:
            return "Invalid entity reference found in the prolog."
        case .entityRefInEpilogError:
            return "Invalid entity reference found in the epilog."
        case .entityRefInDTDError:
            return "Invalid entity reference found in the DTD."
        case .parsedEntityRefAtEOFError:
            return "Target of parsed entity reference is not found."
        case .parsedEntityRefInPrologError:
            return "Target of parsed entity reference is not found in prolog."
        case .parsedEntityRefInEpilogError:
            return "Target of parsed entity reference is not found in epilog."
        case .parsedEntityRefInInternalSubsetError:
            return "Target of parsed entity reference is not found in internal subset."
        case .entityReferenceWithoutNameError:
            return "Entity reference is without name."
        case .entityReferenceMissingSemiError:
            return "Entity reference is missing semicolon."
        case .parsedEntityRefNoNameError:
            return "Parsed entity reference is without an entity name."
        case .parsedEntityRefMissingSemiError:
            return "Parsed entity reference is missing semicolon."
        case .undeclaredEntityError:
            return "Entity is not declared."
        case .unparsedEntityError:
            return "Cannot parse entity."
        case .entityIsExternalError:
            return "Cannot parse external entity."
        case .entityIsParameterError:
            return "Entity is a parameter."
        case .unknownEncodingError:
            return "Document encoding is unknown."
        case .encodingNotSupportedError:
            return "Document encoding is not supported."
        case .stringNotStartedError:
            return "String is not started."
        case .stringNotClosedError:
            return "String is not closed."
        case .namespaceDeclarationError:
            return "Invalid namespace declaration encountered."
        case .entityNotStartedError:
            return "Entity is not started."
        case .entityNotFinishedError:
            return "Entity is not finished."
        case .lessThanSymbolInAttributeError:
            return "Angle bracket is used in attribute."
        case .attributeNotStartedError:
            return "Attribute is not started."
        case .attributeNotFinishedError:
            return "Attribute is not finished."
        case .attributeHasNoValueError:
            return "Attribute doesn’t contain a value."
        case .attributeRedefinedError:
            return "Attribute is redefined."
        case .literalNotStartedError:
            return "Literal is not started."
        case .literalNotFinishedError:
            return "Literal is not finished."
        case .commentNotFinishedError:
            return "Comment is not finished."
        case .processingInstructionNotStartedError:
            return "Processing instruction is not started."
        case .processingInstructionNotFinishedError:
            return "Processing instruction is not finished."
        case .notationNotStartedError:
            return "Notation is not started."
        case .notationNotFinishedError:
            return "Notation is not finished."
        case .attributeListNotStartedError:
            return "Attribute list is not started."
        case .attributeListNotFinishedError:
            return "Attribute list is not finished."
        case .mixedContentDeclNotStartedError:
            return "Mixed content declaration is not started."
        case .mixedContentDeclNotFinishedError:
            return "Mixed content declaration is not finished."
        case .elementContentDeclNotStartedError:
            return "Element content declaration is not started."
        case .elementContentDeclNotFinishedError:
            return "Element content declaration is not finished."
        case .xmlDeclNotStartedError:
            return "XML declaration is not started."
        case .xmlDeclNotFinishedError:
            return "XML declaration is not finished."
        case .conditionalSectionNotStartedError:
            return "Conditional section is not started."
        case .conditionalSectionNotFinishedError:
            return "Conditional section is not finished."
        case .externalSubsetNotFinishedError:
            return "External subset is not finished."
        case .doctypeDeclNotFinishedError:
            return "Document type declaration is not finished."
        case .misplacedCDATAEndStringError:
            return "Misplaced CDATA end string."
        case .cdataNotFinishedError:
            return "CDATA block is not finished."
        case .misplacedXMLDeclarationError:
            return "Misplaced XML declaration."
        case .spaceRequiredError:
            return "Space is required."
        case .separatorRequiredError:
            return "Separator is required."
        case .nmtokenRequiredError:
            return "Name token is required."
        case .nameRequiredError:
            return "Name is required."
        case .pcdataRequiredError:
            return "CDATA is required."
        case .uriRequiredError:
            return "URI is required."
        case .publicIdentifierRequiredError:
            return "Public identifier is required."
        case .ltRequiredError:
            return "Left angle bracket is required."
        case .gtRequiredError:
            return "Right angle bracket is required."
        case .ltSlashRequiredError:
            return "Left angle bracket slash is required."
        case .equalExpectedError:
            return "Equal sign expected."
        case .tagNameMismatchError:
            return "Tag name mismatch."
        case .unfinishedTagError:
            return "Unfinished tag found."
        case .standaloneValueError:
            return "Standalone value found."
        case .invalidEncodingNameError:
            return "Invalid encoding name found."
        case .commentContainsDoubleHyphenError:
            return "Comment contains double hyphen."
        case .invalidEncodingError:
            return "Invalid encoding."
        case .externalStandaloneEntityError:
            return "External standalone entity."
        case .invalidConditionalSectionError:
            return "Invalid conditional section."
        case .entityValueRequiredError:
            return "Entity value is required."
        case .notWellBalancedError:
            return "Document is not well balanced."
        case .extraContentError:
            return "Error in content found."
        case .invalidCharacterInEntityError:
            return "Invalid character in entity found."
        case .parsedEntityRefInInternalError:
            return "Internal error in parsed entity reference found."
        case .entityRefLoopError:
            return "Entity reference loop encountered."
        case .entityBoundaryError:
            return "Entity boundary error."
        case .invalidURIError:
            return "Invalid URI specified."
        case .uriFragmentError:
            return "URI fragment."
        case .noDTDError:
            return "Missing DTD."
        case .delegateAbortedParseError:
            return "Delegate aborted parse."
        @unknown default:
            return "Unkown Error"
        }
    }
}
