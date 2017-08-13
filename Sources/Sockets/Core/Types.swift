import libc

public enum ProtocolFamily {
    case inet
    case inet6
}

public enum SocketType {
    case stream
    case datagram
}

public enum Protocol {
    case TCP
    case UDP
}

// Defining the space to which the address belongs
public enum AddressFamily {
    case inet           // IPv4
    case inet6          // IPv6
    case unspecified    // If you do not care if IPv4 or IPv6 - the name
                        // resolution will dynamically decide if IPv4 or 
                        // IPv6 is applicable
    
    func isConcrete() -> Bool {
        switch self {
        case .inet, .inet6: return true
        case .unspecified: return false
        }
    }
}

public enum UDPSocketRecvSendFlags {
	/// process out-of-band data
	case msg_oob
	/// peek at incoming message
	case msg_peek
	/// wait for full request or error
	case msg_waitall
	/// bypass routing, use direct interface
	case msg_dontroute
}

public typealias Port = UInt16

//Extensions

protocol StringConvertable {
    func toString() -> String
}

protocol CTypeInt32Convertible {
    func toCType() -> Int32
}

protocol CTypeUnsafePointerOfInt8TypeConvertible {
    func toCTypeUnsafePointerOfInt8() -> UnsafePointer<Int8>
}

extension Port: StringConvertable {
    func toString() -> String {
        return String(self)
    }
}

extension ProtocolFamily: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .inet: return PF_INET
        case .inet6: return PF_INET6
        }
    }
}

extension SocketType: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .stream:
        #if os(Linux) 
            return Int32(SOCK_STREAM.rawValue)
        #else
            return SOCK_STREAM
        #endif
        
        case .datagram:
        #if os(Linux)
            return Int32(SOCK_DGRAM.rawValue)
        #else
            return SOCK_DGRAM
        #endif
        }
    }
}

extension Protocol: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .TCP: return Int32(IPPROTO_TCP) //needs manual casting bc Linux
        case .UDP: return Int32(IPPROTO_UDP)
        }
    }
}

extension AddressFamily: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .inet: return Int32(AF_INET)
        case .inet6: return Int32(AF_INET6)
        case .unspecified : return Int32(AF_UNSPEC)
        }
    }
}

extension AddressFamily {
	init(fromCType cType: Int32) throws {
		switch cType {
		case Int32(AF_INET): self = .inet
		case Int32(AF_INET6): self = .inet6
		case Int32(AF_UNSPEC): self = .unspecified
		default: throw SocketsError(.unsupportedSocketAddressFamily(cType))
		}
	}
}

extension UDPSocketRecvSendFlags: CTypeInt32Convertible {
	func toCType() -> Int32 {
		switch self {
		case .msg_oob: return Int32(MSG_OOB)
		case .msg_peek: return Int32(MSG_PEEK)
		case .msg_waitall: return Int32(MSG_WAITALL)
		case .msg_dontroute: return Int32(MSG_DONTROUTE)
		}
	}
}

extension UDPSocketRecvSendFlags {
	init(fromCType cType: Int32) throws {
		switch cType {
		case Int32(MSG_OOB): self = .msg_oob
		case Int32(MSG_PEEK): self = .msg_peek
		case Int32(MSG_WAITALL): self = .msg_waitall
		case Int32(MSG_DONTROUTE): self = .msg_dontroute
		default: throw SocketsError(.unsupportedSocketFlag(cType))
		}
	}
}
