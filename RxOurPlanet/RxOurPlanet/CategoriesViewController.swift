//
//  ViewController.swift
//  RxOurPlanet
//
//  Created by Jean-Marc Kampol Mieville on 4/14/2560 BE.
//  Copyright © 2560 Jean-Marc Kampol Mieville. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let categories = Variable<[EOCategory]>([])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDownload()
    }
    
    func startDownload() {
        let eoCategories = EONET.categories
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
        let category = categories.value[indexPath.row]
        cell.textLabel?.text = category.name
        cell.detailTextLabel?.text = category.description
        return cell
    }
    
}
