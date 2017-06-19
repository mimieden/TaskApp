//
//  InputViewController.swift
//  taskapp
//
//  Created by mimieden on 2017/06/19.
//  Copyright © 2017年 mimieden. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {

//==================================================
// グローバル変数/定数
//==================================================
//--Outlet(RestrationIDもセット!)---------------------
    //タイトル(テキストフィールド)のOutlet
    @IBOutlet weak var O_TitleTextField: UITextField!
    //内容(TextView)のOutlet
    @IBOutlet weak var O_ContentsTextView: UITextView!
    //Date PickerのOutlet
    @IBOutlet weak var O_DatePicker: UIDatePicker!
    
//==================================================
//  関数(ライフサイクル)
//==================================================
//--View読み込み後------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//--------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
