import Foundation
import IOKit.hid

/// Identifiants USB relevés dans Informations système sur le TF800 de l'utilisateur.
private enum TF800USB {
    static let vendorID: Int = 0xC0F4
    static let productID: Int = 0x0FF5
}

/// Détecte le TF800 par ses identifiants USB exacts.
/// La détection ne prétend pas connaître l'état RGB ni envoyer des commandes au clavier.
final class TF800HIDDetector {
    var onChange: ((String?) -> Void)?
    private var manager: IOHIDManager?
    private var timer: DispatchSourceTimer?
    private var lastName: String?

    func start() {
        guard manager == nil else { return }
        let m = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        manager = m
        let matching: [String: Any] = [
            kIOHIDVendorIDKey as String: TF800USB.vendorID,
            kIOHIDProductIDKey as String: TF800USB.productID
        ]
        IOHIDManagerSetDeviceMatching(m, matching as CFDictionary)

        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterDeviceMatchingCallback(m, { context, _, _, _ in
            guard let context else { return }
            Unmanaged<TF800HIDDetector>.fromOpaque(context).takeUnretainedValue().refresh()
        }, context)
        IOHIDManagerRegisterDeviceRemovalCallback(m, { context, _, _, _ in
            guard let context else { return }
            Unmanaged<TF800HIDDetector>.fromOpaque(context).takeUnretainedValue().refresh()
        }, context)

        IOHIDManagerScheduleWithRunLoop(m, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        let result = IOHIDManagerOpen(m, IOOptionBits(kIOHIDOptionsTypeNone))
        guard result == kIOReturnSuccess else {
            lastName = nil
            onChange?(nil)
            return
        }

        refresh()
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 2, repeating: 2)
        t.setEventHandler { [weak self] in self?.refresh() }
        t.resume()
        timer = t
    }

    private func refresh() {
        guard let manager else { return }
        let devices = (IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>) ?? []
        let match = devices.first { device in
            let vendor = (IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? NSNumber)?.intValue
            let product = (IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? NSNumber)?.intValue
            return vendor == TF800USB.vendorID && product == TF800USB.productID
        }
        let productName = match.flatMap {
            IOHIDDeviceGetProperty($0, kIOHIDProductKey as CFString) as? String
        } ?? (match == nil ? nil : "T-WOLF TF800 (USB C0F4:0FF5)")
        if productName != lastName {
            lastName = productName
            onChange?(productName)
        }
    }

    deinit {
        timer?.cancel()
        if let manager {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
            IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        }
    }
}
