//
//  ViewController.swift
//  KiClockExample
//
//  Created by Ivailo Kanev on 30/01/21.
//

import UIKit
import KiClock
class ViewController: UIViewController, KiClockDelegate {
    func kiClock(view: KiClock, didChangeDate: Date) {
        
    }
    

    @IBOutlet weak var kiClock: KiClock! {
        didSet {
            kiClock.delegate = self
            kiClock.face = KiDefaultFace()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

