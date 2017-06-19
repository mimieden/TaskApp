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
    
//--------------------------------------------------
    var V_Task: Task!   // 追加する
    
//==================================================
//  関数(ライフサイクル)
//==================================================
//--View読み込み後------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let l_TapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(F_DismissKeyboard))
        self.view.addGestureRecognizer(l_TapGesture)
        
        O_TitleTextField.text = V_Task.title
        O_ContentsTextView.text = V_Task.contents
        O_DatePicker.date = V_Task.date as Date
    }
    
//--------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//==================================================
//  関数(その他)
//==================================================
//--------------------------------------------------
    func F_DismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
}
