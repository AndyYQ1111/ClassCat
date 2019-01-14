//
//  SearchVC.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/27.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit

class SearchVC: BaseViewController {
    @IBOutlet weak var sb_search: UISearchBar!
    @IBOutlet weak var tv_search: UITableView!
    
    let classCellID = "ClassRoomCell"
    
    var userId:String? = UserDefaults.standard.value(forKey: "userId") as? String
    
    var viewModles:[ViewModel]? = [ViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
}

extension SearchVC{
    override func setupUI() {
         tv_search.register(UINib.init(nibName: classCellID, bundle: nil), forCellReuseIdentifier: classCellID)
    }
}

extension SearchVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModles?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: classCellID, for: indexPath) as! ClassRoomCell
        cell.viewModel = viewModles![indexPath.row]
        cell.btn_more.tag = indexPath.row
        cell.btn_more.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let viewModle = viewModles![indexPath.row]
        return CGFloat(viewModle.contentHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @objc func moreAction(sender:UIButton) {
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "编辑", style: .default) { (UIAlertAction) in
            let nextVC = EidtPackageVC()
            nextVC.viewModel = self.viewModles![sender.tag]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        let delAction = UIAlertAction(title: "删除", style: .default) { (UIAlertAction) in
            let paraDic = ["userId":self.userId ?? "","knowledgeId": self.viewModles![sender.tag].knowledge!.knowledgeId!]
            let urlString = "knowledge.php?act=deleteKnowledge"
            
            NetWorkTools.requestData(method: .POST, urlString: urlString, paraDic: paraDic) { (json) in
                print(json)
                let jsonDecoder = JSONDecoder()
                let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
                let result:Result = try! jsonDecoder.decode(Result.self, from: jsonData!)
                if(result.result == "ok"){
                    self.view.makeToast("删除成功", duration: 1.0, position: .center)
                    self.viewModles?.remove(at: sender.tag)
                    self.tv_search.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (UIAlertAction) in}
        
        alertC.addAction(editAction)
        alertC.addAction(delAction)
        alertC.addAction(cancelAction)
        
        self.present(alertC, animated: true) {
            
        }
    }
}

extension SearchVC:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let paraDic = ["userId":userId ?? "","text":searchBar.text ?? "","pageIndex":"1","countPerPage":"20"]
        let urlString = "mediaInfos.php?act=search"
        
        NetWorkTools.requestData(method: .POST, urlString: urlString, paraDic: paraDic) { (json) in
            print(json)
            let jsonDecoder = JSONDecoder()
            let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
            let knowledges:Knowledges = try! jsonDecoder.decode(Knowledges.self, from: jsonData!)
            if(knowledges.result == "ok"){
                self.viewModles?.removeAll()
                for knowledge in knowledges.data! {
                    let viewModel = ViewModel()
                    viewModel.knowledge = knowledge
                    self.viewModles?.append(viewModel)
                }
                self.tv_search.reloadData()
            }
        }
    }
}
