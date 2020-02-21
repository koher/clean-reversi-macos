import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let boardView = BoardView(frame: CGRect(x: 0, y: 0, width: 480, height: 480))
        boardView.delegate = self
        view.addSubview(boardView)
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
