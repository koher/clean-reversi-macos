import Cocoa

class ViewController: NSViewController {
    
    var cellView: CellView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cellView = CellView()
        cellView.setDisk(.dark, animated: false)
        cellView.target = self
        cellView.action = #selector(pressCellView)
        cellView.frame = CGRect(x: 0, y: 100, width: 100, height: 100)
        view.addSubview(cellView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

extension ViewController {
    @objc func pressCellView() {
        if let disk = cellView.disk {
            cellView.disk = Double.random(in: 0...1) < 0.4 ? nil : disk.flipped
        } else {
            cellView.disk = Bool.random() ? .dark : .light
        }
    }
}
