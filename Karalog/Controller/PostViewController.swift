//
//  PostViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/25.
//

import UIKit

class PostViewController: UIViewController {
    
    var musicName: String = ""
    var artistName: String = ""
    var musicImage: Data!
    var musicID: Int!
    var category: [String] = []
    var alertCtl: UIAlertController!
    
    @IBOutlet var musicLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var addCategoryBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var contentTV: UITextView!
    @IBOutlet var postBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpMusic()
        setupTableView()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let location: CGPoint = touch.location(in: self.view)
        if location.x < tableView.frame.minX || location.y < tableView.frame.minY {
            tapOutTableView()
        }else if location.x > tableView.frame.maxX || location.y > tableView.frame.maxY {
            tapOutTableView()
        }
    }
    
    func setUpMusic() {
        musicLabel.text = musicName
        artistLabel.text = artistName
    }
    
    func setUpCategory() {
        categoryLabel.numberOfLines = 0
        if let indexPathList = self.tableView.indexPathsForSelectedRows {
            var text = ""
            var newLine = false
            for i in indexPathList {
                if newLine {
                    text += "\n#" + Material.shared.categoryList[i.row]
                    category.append(Material.shared.categoryList[i.row])
                }else {
                    text = "#" + Material.shared.categoryList[i.row]
                    newLine = true
                    category = [Material.shared.categoryList[i.row]]
                    
                }
            }
            categoryLabel.text = text
        } else {
            categoryLabel.text = ""
            category = []
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.isHidden = true
        tableView.allowsMultipleSelection = true
    }
    
    @IBAction func tapAddCategory() {
        tableView.isHidden.toggle()
    }

    @IBAction func tapPost() {
        
        FirebaseAPI.shared.post(musicName: musicName, artistName: artistName, musicImage: musicImage, musicID: musicID, content: contentTV.text, category: category)
        let screenIndex = navigationController!.viewControllers.count - 3
        self.navigationController?.popToViewController(navigationController!.viewControllers[screenIndex], animated: true)
    }
    
    func tapOutTableView () {
        if tableView.isHidden == false {
            tableView.isHidden = true
            setUpCategory()
        }
    }
}

extension PostViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if tableView.indexPathsForSelectedRows!.count <= 5 {
            cell?.accessoryType = .checkmark
            setUpCategory()
        }else{
            func alert(title: String, message: String) {
                alertCtl = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertCtl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertCtl, animated: true)
            }
            alert(title: "入力ミス", message: "選択できるのは5個までです")
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
        setUpCategory()
    }
}

extension PostViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Material.shared.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = Material.shared.categoryList[indexPath.row]
        cell.selectionStyle = .none
        // セルの状態を確認しチェック状態を反映する
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        if selectedIndexPaths != nil && (selectedIndexPaths?.contains(indexPath))! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
}
