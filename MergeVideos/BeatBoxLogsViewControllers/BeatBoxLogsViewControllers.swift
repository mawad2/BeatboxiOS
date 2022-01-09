//
//  BeatBoxLogsViewControllers.swift
//  BeatBox
//
//  Created by M Abubaker Majeed on 13/10/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit

class BeatBoxLogsViewControllers: UIViewController {

    @IBOutlet weak var txtViewLogs: UITextView!
    var textToShow : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

      



    }
    override func viewDidAppear(_ animated: Bool) {
        self.txtViewLogs.text = textToShow;
    }
    @IBAction func backAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
    }

}
