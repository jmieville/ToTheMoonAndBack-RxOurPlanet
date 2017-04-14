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
    let days = Variable<Int>(360)
    let filteredEvents = Variable<[EOEvent]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        events.asObservable()
            .subscribe(onNext: { [weak self] _ in
                    self?.tableView.reloadData()
            })
        .addDisposableTo(disposeBag)
        Observable.combineLatest(days.asObservable(), events.asObservable()) { (days, events) -> [EOEvent] in
            let maxInterval = TimeInterval(days * 24 * 3600)
            return events.filter { event in
                if let date = event.closeDate {
                    return abs(date.timeIntervalSinceNow) < maxInterval
                }
                return true
            } }
        .bindTo(filteredEvents)
        .addDisposableTo(disposeBag)
        filteredEvents.asObservable()
            .subscribe(onNext: { [weak self] _ in
             self?.tableView.reloadData()
            })
        .addDisposableTo(disposeBag)
        days.asObservable()
            .subscribe(onNext: { [weak self] days in
                self?.daysLabel.text = "Last \(days) days"
            })
        .addDisposableTo(disposeBag)
    }
    
    @IBAction func sliderAction(slider: UISlider) {
        days.value = Int(slider.value)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
        let event = filteredEvents.value[indexPath.row]
        cell.configure(event: event)
        return cell
    }
    
}
