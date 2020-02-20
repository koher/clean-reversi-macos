import Cocoa
import CleanReversi

private let animationDuration: TimeInterval = 0.25

public class CellView: NSView {
    private let button: NSButton = .init()
    private var diskView: DiskView = .init()
    
    private var animationCounter: AnimationCounter = .init()
    
    private var _disk: Disk?
    public var disk: Disk? {
        get { _disk }
        set { setDisk(newValue, animated: true) }
    }
    
    required public init() {
        super.init(frame: .zero)
        setUp()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        do { // button
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setButtonType(.momentaryChange)
            button.isBordered = false
            button.imageScaling = .scaleAxesIndependently
            do { // image
                let image = NSImage(size: NSSize(width: 1, height: 1))
                image.lockFocus()
                let color: NSColor = NSColor(named: "CellColor")!
                color.drawSwatch(in: NSRect(x: 0, y: 0, width: 1, height: 1))
                image.unlockFocus()
                button.image = image
            }
            self.addSubview(button)
        }

        do { // diskView
            diskView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(diskView)
        }

        needsLayout = true
    }

    public override func layout() {
        super.layout()
        
        button.frame = bounds
        if !animationCounter.isAnimating() {
            layoutDiskView(diskView)
        }
    }
    
    private func layoutDiskView(_ diskView: DiskView) {
        let cellSize = bounds.size
        let diskDiameter = Swift.min(cellSize.width, cellSize.height) * 0.8
        let diskSize: CGSize
        if _disk == nil || self.diskView.disk == _disk { // Must be `self.` because `diskView` may be an animator
            diskSize = CGSize(width: diskDiameter, height: diskDiameter)
        } else {
            diskSize = CGSize(width: 0, height: diskDiameter)
        }
        diskView.frame = CGRect(
            origin: CGPoint(x: (cellSize.width - diskSize.width) / 2, y: (cellSize.height - diskSize.height) / 2),
            size: diskSize
        )
        diskView.alphaValue = _disk == nil ? 0.0 : 1.0
    }
    
    public func setDisk(_ disk: Disk?, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let diskBefore: Disk? = _disk
        _disk = disk
        let diskAfter: Disk? = _disk
        if animated {
            switch (diskBefore, diskAfter) {
            case (.none, .none):
                completion?(true)
            case (.none, .some(let animationDisk)):
                diskView.disk = animationDisk
                fallthrough
            case (.some, .none):
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = animationDuration
                    context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    animationCounter.countUp()
                    layoutDiskView(diskView.animator())
                }, completionHandler: { [weak self] in
                    guard let self = self else { return }
                    self.animationCounter.countDown()
                    completion?(true)
                })
            case (.some, .some):
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = animationDuration / 2
                    context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    animationCounter.countUp()
                    layoutDiskView(diskView.animator())
                }, completionHandler: { [weak self] in
                    guard let self = self else { return }
                    self.animationCounter.countDown()
                    if self.diskView.disk == self._disk {
                        completion?(true)
                    }
                    guard let diskAfter = self._disk else {
                        completion?(true)
                        return
                    }
                    self.diskView.disk = diskAfter
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = animationDuration / 2
                        context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                        self.animationCounter.countUp()
                        self.layoutDiskView(self.diskView.animator())
                    }, completionHandler: { [weak self] in
                        guard let self = self else { return }
                        self.animationCounter.countDown()
                        completion?(true)
                    })
                })
            }
        } else {
            if let diskAfter = diskAfter {
                diskView.disk = diskAfter
            }
            completion?(true)
            needsLayout = true
        }
    }
    
    public var target: AnyObject? {
        didSet { button.target = target }
    }
    
    public var action: Selector? {
        didSet { button.action = action }
    }
    
    func animate1() {
        NSAnimationContext.beginGrouping()
        let context = NSAnimationContext.current
        context.duration = 1.0
        context.timingFunction = CAMediaTimingFunction(name: .easeIn)
        diskView.animator().frame = CGRect(x: 50, y: 10, width: 0, height: 80)
        context.completionHandler = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.animate2()
            }
        }
        NSAnimationContext.endGrouping()
    }
    
    func animate2() {
        NSAnimationContext.beginGrouping()
        let context = NSAnimationContext.current
        context.duration = 1.0
        context.timingFunction = CAMediaTimingFunction(name: .easeOut)
        diskView.animator().frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        context.completionHandler = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.animate1()
            }
        }
        NSAnimationContext.endGrouping()
    }
}

private struct AnimationCounter {
    private var count: Int = 0
    mutating func countUp() { count += 1 }
    mutating func countDown() { count -= 1 }
    func isAnimating() -> Bool { count > 0 }
}

