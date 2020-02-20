import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let diskView = DiskView()
        diskView.disk = .light
        diskView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.addSubview(diskView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

