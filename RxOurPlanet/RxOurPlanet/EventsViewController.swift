//
//  EventsViewController.swift
//  RxOurPlanet
//
//  Created by Jean-Marc Kampol Mieville on 4/14/2560 BE.
//  Copyright © 2560 Jean-Marc Kampol Mieville. All rights reserved.
//

import UIKit
import RxSwift

class EventsViewController : UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var daysLabel: UILabel!
    
    let events = Variable<[EOEvent]>([])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        events.asObservable()
            .subscribe(onNext: { [weak self] _ in
                    self?.tableView.reloadData()
            })
        .addDisposableTo(disposeBag)
    }
    
    @IBAction func sliderAction(slider: UISlider) {
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
        let event = events.value[indexPath.row]
        cell.configure(event: event)
        return cell
    }
    
}
