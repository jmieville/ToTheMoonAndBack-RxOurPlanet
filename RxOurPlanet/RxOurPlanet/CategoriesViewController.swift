//
//  ViewController.swift
//  RxOurPlanet
//
//  Created by Jean-Marc Kampol Mieville on 4/14/2560 BE.
//  Copyright © 2560 Jean-Marc Kampol Mieville. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let categories = Variable<[EOCategory]>([])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories
        .asObservable()
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
        .addDisposableTo(disposeBag)
        startDownload()
    }
    
    func startDownload() {
        let eoCategories = EONET.categories
        let downloadedEvents = eoCategories.flatMap { categories in
            return Observable.from(categories.map { category in
                EONET.events(forLast: 360, category: category)
            })
            }
            .merge(maxConcurrent: 2)
        
        let updatedCategories = eoCategories.flatMap { categories in
            downloadedEvents.scan(categories) { updated, events in
                return updated.map { category in
                    let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category)
                    if !eventsForCategory.isEmpty {
                        var cat = category
                        cat.events = cat.events + eventsForCategory
                        return cat
                    }
                    return category
                }
            }
        }
        
        eoCategories
            .concat(updatedCategories)
            .bindTo(categories)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
        let category = categories.value[indexPath.row]
        cell.textLabel?.text = "\(category.name) (\(category.events.count))"
        cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories.value[indexPath.row]
        if !category.events.isEmpty {
            let eventsController = storyboard!.instantiateViewController(withIdentifier: "events") as! EventsViewController
            eventsController.title = category.name
            eventsController.events.value = category.events
            navigationController!.pushViewController(eventsController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
