import Cocoa

class ViewController: NSViewController {
    @IBOutlet private var boardView: BoardView!
    
    @IBOutlet private var messageDiskView: DiskView!
    @IBOutlet private var messageLabel: NSTextField!
    @IBOutlet private var messageDiskSizeConstraint: NSLayoutConstraint!
    private var messageDiskSize: CGFloat! // to store the size designated in the storyboard
    
    @IBOutlet private var darkPlayerControl: NSSegmentedControl!
    @IBOutlet private var lightPlayerControl: NSSegmentedControl!
    private var playerControls: [NSSegmentedControl] = []
    
    @IBOutlet private var darkCountLabel: NSTextField!
    @IBOutlet private var lightCountLabel: NSTextField!
    private var countLabels: [NSTextField] = []
    
    @IBOutlet private var darkPlayerActivityIndicator: NSProgressIndicator!
    @IBOutlet private var lightPlayerActivityIndicator: NSProgressIndicator!
    private var playerActivityIndicators: [NSProgressIndicator] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        messageDiskSize = messageDiskSizeConstraint.constant
        playerControls.append(contentsOf: [darkPlayerControl, lightPlayerControl])
        countLabels.append(contentsOf: [darkCountLabel, lightCountLabel])
        playerActivityIndicators.append(contentsOf: [darkPlayerActivityIndicator, lightPlayerActivityIndicator])
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

extension ViewController: BoardViewDelegate {
    func boardView(_ boardView: BoardView, didSelectCellAtX x: Int, y: Int) {
        print("(\(x), \(y))")
    }
}
