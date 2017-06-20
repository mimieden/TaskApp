//
//  InputViewController.swift
//  taskapp
//
//  Created by mimieden on 2017/06/19.
//  Copyright © 2017年 mimieden. All rights reserved.
//

import UIKit
import RealmSwift        // 追加する
import UserNotifications //追加

class InputViewController: UIViewController {

//==================================================
// グローバル変数/定数
//==================================================
//--Outlet(RestrationIDもセット!)---------------------
    //カテゴリ(テキストフィールド)のOutlet *課題
    @IBOutlet weak var O_CategoryTextField: UITextField!
    //タイトル(テキストフィールド)のOutlet
    @IBOutlet weak var O_TitleTextField: UITextField!
    //内容(TextView)のOutlet
    @IBOutlet weak var O_ContentsTextView: UITextView!
    //Date PickerのOutlet
    @IBOutlet weak var O_DatePicker: UIDatePicker!
    
//--------------------------------------------------
    var V_Task: Task!   // 追加する
    let L_Realm = try! Realm()
    
//==================================================
//  関数(ライフサイクル)
//==================================================
//--View読み込み後------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let l_TapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(F_DismissKeyboard))
        self.view.addGestureRecognizer(l_TapGesture)
        
            O_CategoryTextField.text = V_Task.category  // *課題
            O_TitleTextField.text = V_Task.title
            O_ContentsTextView.text = V_Task.contents
            O_DatePicker.date = V_Task.date as Date
    }

//--Viewが消える前------------------------------------
    // 追加する
    override func viewWillDisappear(_ animated: Bool) {
        try! L_Realm.write {
            self.V_Task.category = self.O_CategoryTextField.text!  // *課題
            self.V_Task.title = self.O_TitleTextField.text!
            self.V_Task.contents = self.O_ContentsTextView.text
            self.V_Task.date = self.O_DatePicker.date as NSDate
            self.L_Realm.add(self.V_Task, update: true)
        }
        
        F_SetNotification(A_Task: V_Task)   //引数A_TaskにV_Taskを渡す
        
        super.viewWillDisappear(animated)
    }
    
//--------------------------------------------------
    override func didReceiveMemoryWarning() {            //テキストでは削除されているが残しておく？
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//==================================================
//  関数(その他)
//==================================================
//--キーボードを閉じる---------------------------------
    func F_DismissKeyboard() {
        view.endEditing(true)
    }
    
//--タスクのローカル通知を登録する-------------------------
    func F_SetNotification(A_Task: Task) {          //A:引数
        let l_Content = UNMutableNotificationContent()
        // カテゴリは通知には表示しない *課題
        l_Content.title = A_Task.title
        l_Content.body  = A_Task.contents
        l_Content.sound = UNNotificationSound.default()  //空だと音しかしない
        
        //ローカル通知が発動するtrigger(日付マッチ)を作成
        let l_Calendar = NSCalendar.current
        let l_DateComponents = l_Calendar.dateComponents([.year, .month, .day, .hour, .minute], from: A_Task.date as Date)
        let l_Trigger = UNCalendarNotificationTrigger.init(dateMatching: l_DateComponents, repeats: false)
        
        //identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let l_Request = UNNotificationRequest.init(identifier: String(A_Task.id), content: l_Content, trigger: l_Trigger)
        
        //ローカル通知を登録
        let l_Center = UNUserNotificationCenter.current()
        l_Center.add(l_Request) { (error) in
            print (error ?? "ローカル通知登録 OK")     // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        //未通知のローカル通知一覧をログ出力
        l_Center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for l_Request in requests {
                print("/---------------")
                print(l_Request)
                print("---------------/")
            }
        }
    }
}
