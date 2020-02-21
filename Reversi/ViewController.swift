import Cocoa
import CleanReversi
import CleanReversiAsync
import CleanReversiAI
import CleanReversiApp
import CleanReversiGateway

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

    private var gameController: GameController!
    private var gameSaver: GameSaver!
    var board: Board = Board(width: 8, height: 8) // required by `GameControllerBoardAnimationDelegate`
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageDiskSize = messageDiskSizeConstraint.constant
        playerControls.append(contentsOf: [darkPlayerControl, lightPlayerControl])
        countLabels.append(contentsOf: [darkCountLabel, lightCountLabel])
        playerActivityIndicators.append(contentsOf: [darkPlayerActivityIndicator, lightPlayerActivityIndicator])
        
        gameSaver = GameSaver(delegate: self)
        gameController = GameController(delegate: self, saveDelegate: gameSaver, strategyDelegate: self)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        try? gameController.start()
    }
}

// MARK: Inputs

extension ViewController {
    @IBAction func pressResetButton(_ sender: NSButton) {
        gameController.reset()
    }
    
    @IBAction func changePlayerControlSegment(_ sender: NSSegmentedControl) {
        let side: Disk = Disk(index: playerControls.firstIndex(of: sender)!)
        gameController.setPlayer(.init(index: sender.selectedSegment), of: side)
    }
}

extension ViewController: BoardViewDelegate {
    func boardView(_ boardView: BoardView, didSelectCellAtX x: Int, y: Int) {
        try? gameController.placeDiskAt(x: x, y: y)
    }
}

// MARK: Delegates

extension ViewController: GameControllerDelegate, GameControllerBoardAnimationDelegate {
    func updateMessage(_ message: GameController.Message, animated: Bool) {
        switch message {
        case .turn(let side):
            messageDiskSizeConstraint.constant = messageDiskSize
            messageDiskView.disk = side
            messageLabel.stringValue = "'s turn"
        case .result(winner: .some(let winner)):
            messageDiskSizeConstraint.constant = messageDiskSize
            messageDiskView.disk = winner
            messageLabel.stringValue = " won"
        case .result(winner: .none):
            messageDiskSizeConstraint.constant = 0
            messageLabel.stringValue = "Tied"
        }
    }
    
    func updateDiskCountsOf(dark darkDiskCount: Int, light lightDiskCount: Int, animated: Bool) {
        countLabels[Disk.dark.index].stringValue = darkDiskCount.description
        countLabels[Disk.light.index].stringValue = lightDiskCount.description
    }
    
    func updatePlayer(_ player: GameController.Player, of side: Disk, animated: Bool) {
        playerControls[side.index].selectedSegment = player.index
    }
    
    func updatePlayerActivityInidicatorVisibility(_ isVisible: Bool, of side: Disk, animated: Bool) {
        if isVisible {
            playerActivityIndicators[side.index].startAnimation(nil)
        } else {
            playerActivityIndicators[side.index].stopAnimation(nil)
        }
    }
    
    func confirmToResetGame(completion: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "Confirmation"
        alert.informativeText = "Do you really want to reset the game?"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn: completion(false)
        case .alertSecondButtonReturn: completion(true)
        default: preconditionFailure("Never reaches here.")
        }
    }
    
    func alertPass(of side: Disk, completion: @escaping () -> Void) {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Pass"
        alert.informativeText = "Cannot place a disk."
        alert.addButton(withTitle: "Dismiss")
        _ = alert.runModal()
        completion()
    }
    
    func updateDisk(_ disk: Disk?, atX x: Int, y: Int, animated isAnimated: Bool, completion: @escaping () -> Void) -> Canceller {
        boardView.setDisk(disk, atX: x, y: y, animated: isAnimated) { _ in completion() }
        return Canceller {}
    }
}

extension ViewController: GameControllerStrategyDelegate {
    func move(for board: Board, of side: Disk, handler: @escaping (Int, Int) -> Void) -> Canceller {
        CleanReversiAI.move(for: board, of: side) { x, y in handler(x, y) }
    }
}

extension ViewController: GameSaverDelegate {
    private var url: URL {
        URL(fileURLWithPath: (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game"))
    }
    
    func writeData(_ data: Data) throws {
        try data.write(to: url, options: .atomic)
    }
    
    func readData() throws -> Data {
        try Data(contentsOf: url)
    }
}

// MARK: File-private extensions

extension Disk {
    fileprivate init(index: Int) {
        self = Disk.sides.first(where: { $0.index == index })!
    }

    fileprivate var index: Int {
        switch self {
        case .dark: return 0
        case .light: return 1
        }
    }
}

extension GameController.Player {
    fileprivate init(index: Int) {
        self = GameController.Player.values.first(where: { $0.index == index })!
    }
    
    fileprivate var index: Int {
        switch self {
        case .manual: return 0
        case .computer: return 1
        }
    }
    
    fileprivate static var values: [Self] { [.manual, .computer] }
}
