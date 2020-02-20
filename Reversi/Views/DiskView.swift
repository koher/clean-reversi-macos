import Cocoa
import CleanReversi

public class DiskView: NSView {
    public var disk: Disk = .dark {
        didSet { setNeedsDisplay(bounds) }
    }
    
    @IBInspectable public var name: String {
        get { disk.name }
        set { disk = .init(name: newValue) }
    }
    
    override public func draw(_ rect: CGRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setFillColor(disk.cgColor)
        context.fillEllipse(in: bounds)
    }
}

extension Disk {
    fileprivate var nsColor: NSColor {
        switch self {
        case .dark: return NSColor(named: "DarkColor")!
        case .light: return NSColor(named: "LightColor")!
        }
    }
    
    fileprivate var cgColor: CGColor {
        nsColor.cgColor
    }
    
    fileprivate var name: String {
        switch self {
        case .dark: return "dark"
        case .light: return "light"
        }
    }
    
    fileprivate init(name: String) {
        switch name {
        case Disk.dark.name:
            self = .dark
        case Disk.light.name:
            self = .light
        default:
            preconditionFailure("Illegal name: \(name)")
        }
    }
}
