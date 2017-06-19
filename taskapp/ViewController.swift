//
//  ViewController.swift
//  taskapp
//
//  Created by mimieden on 2017/06/19.
//  Copyright © 2017年 mimieden. All rights reserved.
//

// 変数/定数
// グローバル変数 V_ (ただしアウトレットの場合はO_)
// グローバル定数 L_
// ローカル変数   v_
// ローカル定数   l_
// 関数
// 自由定義関数   F_ (ただし規定の関数はそのまま)
// 規定関数 viewDidLoad() didReceiveMemoryWarning() tableView() performSegue()
// Identifier   I_


import UIKit
import RealmSwift // (6.6)

//テーブルビューのデリゲート設定
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//==================================================
// グローバル変数/定数
//==================================================
//--Outlet(RestrationIDもセット!)---------------------
    //テーブルビューのOutlet
    @IBOutlet weak var O_TableView: UITableView!

//--Realmインスタンス----------------------------------
    let L_Realm = try! Realm()
    
//--DB内のタスク格納リスト/日付近い順で降順、内容自動更新-----
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
        // Do any additional setup after loading the view, typically from a nib.
        
        //テーブルビューのデリゲート設定
        O_TableView.delegate = self                    //ユーザー操作
        O_TableView.dataSource = self                  //データ表示
    }

//--------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//==================================================
//  関数(プロトコル指定メソッド)
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
            //データベースから削除する
            try! L_Realm.write {
                self.L_Realm.delete(self.V_TaskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
        }
    }

//==================================================
//  関数(画面遷移)
//==================================================
//==segueで画面遷移するときに呼び出されるメソッド==========
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        let l_InputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "I_CellSegue" {
            let l_IndexPath = self.O_TableView.indexPathForSelectedRow
            if l_IndexPath != nil {                                          //nilでエラーになるので仮に追加
              l_InputViewController.V_Task = V_TaskArray[l_IndexPath!.row]
            }                                                                //nilでエラーになるので仮に追加
        } else {
            let l_Task = Task()
            l_Task.date = NSDate()
            
            if V_TaskArray.count != 0 {
                l_Task.id = V_TaskArray.max(ofProperty: "id")! + 1
            }
            l_InputViewController.V_Task = l_Task
        }
    }

}
