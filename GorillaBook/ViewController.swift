//
//  ViewController.swift
//  GorillaBook
//
//  Created by Alejandro Camacho on 16/11/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createEntryButton: UIButton!
    
    var viewModel: FeedViewModel!
    
    let getFeedEntries = GetFeedEntriesAdapter()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FeedViewModel(callback: {
            self.tableView.reloadData()
        })
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 800
        viewModel.viewDidLoad()
        let logo = UIImage(named: "GLLogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    @IBAction func createPostTapped(_ sender: Any) {
        
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.state.displayedEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as? FeedTableViewCell else {
            return UITableViewCell()
        }
        let recipe = viewModel.state.displayedEntries[indexPath.row]
        cell.bind(with: recipe)
        
        return cell
        
    }
}

struct FeedEntryViewModel {
    var name: String
    var date: String
    var body: String
    var image:String?
    var photo: UIImage?
}

extension FeedEntryViewModel {
    init(from feedEntry: FeedEntry) {
        self.name = feedEntry.firstName + feedEntry.lastName
        self.date = feedEntry.timestamp
        self.body = feedEntry.body
        self.image = feedEntry.image
    }
}


struct FeedState {
    var displayedEntries: [FeedEntryViewModel] = []
}

final class FeedViewModel {
    var state: FeedState = FeedState() {
        didSet {
            callback()
        }
    }
    
    var callback: () -> Void
    
    private var getFeedEntries: GetFeedEntries = GetFeedEntriesAdapter()
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    func viewDidLoad() {
        loadEntries()
    }
    
    private func loadEntries() {
        getFeedEntries.execute { (result) in
            if case let .success(entries) =  result {
                self.feedEntries = entries
            }
        }
    }
    
    private var feedEntries: [FeedEntry] = [] {
        didSet {
            let viewModels = feedEntries.map(FeedEntryViewModel.init(from: ))
            self.state.displayedEntries = viewModels
        }
    }
}




protocol GetFeedEntries {
    func execute(completion: @escaping (Result<[FeedEntry],Error>) -> Void)
}

final class GetFeedEntriesAdapter: GetFeedEntries {
    func execute(completion: @escaping (Result<[FeedEntry],Error>) -> Void) {
        
        guard let url =  URL(string: "https://gl-endpoint.herokuapp.com/feed") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let feedEntries = try? JSONDecoder().decode([FeedEntry].self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(feedEntries))
                }
            }
            else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            }
            
        }.resume()
    }
}


