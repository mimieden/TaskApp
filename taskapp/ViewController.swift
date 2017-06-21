//
//  ViewController.swift
//  taskapp
//
//  Created by mimieden on 2017/06/19.
//  Copyright © 2017年 mimieden. All rights reserved.

//==================================================
// Naming Rules (Constant&Variable)
//==================================================
//--Global------------------------------------------
// Constant         L_                //CNS *Instans =>INS
// Variable         V_                //WRK
// Variable(Outlet) O_                //OUT
//--Local-------------------------------------------
// Constant         l_                //cns
// Variable         v_                //wrk
//==================================================
// Naming Rules (Others)
//==================================================
//--Function----------------------------------------
// Original         F_
// Definined        viewDidLoad() didReceiveMemoryWarning() tableView() performSegue()
//--From StoryBoard---------------------------------
// Identifier       I_                //ID
//--------------------------------------------------

//=Import===========================================
import UIKit
import RealmSwift
import UserNotifications

//=Class============================================
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

//==================================================
// グローバル変数/定数
//==================================================
//--Outlet(RestrationIDもセット!)---------------------
    //テーブルビューのOutlet
    @IBOutlet weak var O_TableView: UITableView!
    //サーチバーのOutlet *課題
    @IBOutlet weak var O_SearchBar: UISearchBar!

//--インスタンス----------------------------------
    //Realmのインスタンス
    let L_Realm = try! Realm()

//--------------------------------------------------
    //DB内のタスク格納リスト/日付近い順で降順、内容自動更新-----
    var V_TaskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
//==================================================
//  関数(ライフサイクル)
//==================================================
//--View読み込み前------------------------------------
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        O_TableView.reloadData()
    }
    
//--View読み込み後------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルビューのデリゲート設定
        O_TableView.delegate = self                    //ユーザー操作
        O_TableView.dataSource = self                  //データ表示
        
        //サーチバーのデリゲート設定 *課題
        O_SearchBar.delegate = self

        //サーチバーのプレースホルダー設定 *課題
        O_SearchBar.placeholder = "カテゴリを指定して絞り込み"
        
        //何も入力されていなくてもReturnキーを押せるようにする。
        O_SearchBar.enablesReturnKeyAutomatically = false
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する→セルのタップが効かない
        let l_TapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(F_DismissKeyboard))
        view.addGestureRecognizer(l_TapGesture)
        //l_TapGesture.cancelsTouchesInView = false
        //セルのタップが効くようにする 少し動きが変
    }
    
//    func viewWillAppear() {

//==================================================
//  関数 (プロトコル指定メソッド)
//==================================================
//==UITableViewDataSourceプロトコルのメソッド===========
//--データの数 (=セルの数)を返すメソッド------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return V_TaskArray.count //データの配列であるV_TaskArrayの要素数を返すようにします。
    }

//--各セルの内容を返すメソッド---------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let l_Cell = tableView.dequeueReusableCell(withIdentifier: "I_Cell", for: indexPath)
        // 値を設定する
        let l_Task = V_TaskArray[indexPath.row]
        l_Cell.textLabel?.text = l_Task.title
        
        let l_Formatter = DateFormatter()
        l_Formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let l_dateString:String = l_Formatter.string(from: l_Task.date as Date)
        l_Cell.detailTextLabel?.text = l_dateString
        
        return l_Cell
    }

//==UITableViewDelegateプロトコルのメソッド=============
//--各セルを選択した時に実行されるメソッド-----------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "I_CellSegue",sender: nil)
    }
    
//--セルが削除可能なことを伝えるメソッド-------------------
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
//--Deleteボタンがおされたときに呼び出されるメソッド--------
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt
        indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {

            //削除されたタスクを取得する
            let l_Task = self.V_TaskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let l_Center = UNUserNotificationCenter.current()
            l_Center.removePendingNotificationRequests(withIdentifiers: [String(l_Task.id)])
            
            //データベースから削除する
            try! L_Realm.write {
                self.L_Realm.delete(self.V_TaskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            l_Center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
//==================================================
//  関数(検索機能)
//==================================================
//--検索実施時の呼び出しメソッド-------------------------
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //表示用のタスク一覧を作成
        if O_SearchBar.text == "" {           //未入力の場合はfilter指定をせず全てを表示する
            V_TaskArray = try! Realm().objects(Task.self)
                                      .sorted(byKeyPath: "date",
                                       ascending: false)
        } else {                              //入力がある場合はfilter指定で指定カテゴリのタスクのみ表示
            V_TaskArray = try! Realm().objects(Task.self)
                                      .sorted(byKeyPath: "date",
                                       ascending: false)
                                      .filter("category == '\(O_SearchBar.text!)'")
            
//--デバッグ用----------------------------------------
            //for Task in V_TaskArray {
            //    let l_Task = V_TaskArray[indexPath.row]
            //    print(Task.title)
            //}
//--------------------------------------------------
        }
        
        //キャンセルボタンを有効化してリロード/キーボードを閉じる
        searchBar.showsCancelButton = true
        searchBar.endEditing(true)
        O_TableView.reloadData()

    }
    
//--キャンセル時の呼び出しメソッド------------------------
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //表示用のタスク一覧を作成
        V_TaskArray = try! Realm().objects(Task.self)
            .sorted(byKeyPath: "date", ascending: false)
        //キャンセルボタンを無効化してリロード/キーボードを閉じる
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        O_SearchBar.text = ""
        O_TableView.reloadData()

    }
//==================================================
//  関数(画面遷移)
//==================================================
//==segueで画面遷移するときに呼び出されるメソッド==========
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        
        let l_InputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "I_CellSegue" {                          //セルをタップしたとき
            let l_IndexPath = self.O_TableView.indexPathForSelectedRow
              l_InputViewController.V_Task = V_TaskArray[l_IndexPath!.row]
            //endif
        } else {                                                        //+ボタンをタップしたとき
            let l_Task = Task()
            l_Task.date = NSDate()
            
            if V_TaskArray.count != 0 {
                l_Task.id = V_TaskArray.max(ofProperty: "id")! + 1
            }
            l_InputViewController.V_Task = l_Task
        }
    }
//==================================================
//  関数(その他)
//==================================================
//--キーボードを閉じる---------------------------------
// 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
//let l_TapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(F_DismissKeyboard))
//self.view.addGestureRecognizer(l_TapGesture)

func F_DismissKeyboard() {
    view.endEditing(true)
}
}
