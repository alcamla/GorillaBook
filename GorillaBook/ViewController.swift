//
//  ViewController.swift
//  GorillaBook
//
//  Created by Alejandro Camacho on 16/11/20.
//

import UIKit

protocol CreateEntryDelegate: class {
    func didCreate(_ feedEntry: FeedEntry?)
}

class ViewController: UIViewController, CreateEntryDelegate{

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createEntryButton: UIButton!
    
    var viewModel: FeedViewModel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FeedViewModel(callback: { [self] in
            self.tableView.reloadData()
            self.dateLabel.text = viewModel.state.todaysLabel
        })
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 800
        viewModel.viewDidLoad()
        let logo = UIImage(named: "GLLogo_small")
        let imageView = UIImageView(image:logo)
        imageView.contentMode =  .scaleToFill
        self.navigationItem.titleView = imageView
    }
    
    @IBAction func createPostTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "CreatePostViewController") as! CreatePostViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func didCreate(_ feedEntry: FeedEntry?) {
        print("Did Create entry!")
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
    var id: Int
    var name: String
    var date: String
    var body: String
    var image:String?
    var photo: UIImage?
}

extension FeedEntryViewModel {
    init(from feedEntry: FeedEntry) {
        self.id = feedEntry.id
        self.name = feedEntry.firstName + " " + feedEntry.lastName
        self.date = FeedEntryViewModel.dateFrom(unixTimeInterval: feedEntry.timestamp)
        self.body = feedEntry.body
        self.image = feedEntry.image
    }
    
    static func dateFrom(unixTimeInterval: String) -> String{
        guard let timeInterval = Double(unixTimeInterval) else {
            return unixTimeInterval
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}


struct FeedState {
    var displayedEntries: [FeedEntryViewModel] = []
    var todaysLabel: String = "Tuesday, June 6"
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
        state.todaysLabel = FeedViewModel.getToday()
    }
    
    private static func getToday() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    private func loadEntries() {
        getFeedEntries.execute { (result) in
            if case let .success(entries) =  result {
                self.feedEntries = entries
                entries.forEach { (feedEntry) in
                    self.newFeedEntries[feedEntry.id] = feedEntry
                }
                
            }
        }
    }
    
    private var newFeedEntries: [Int: FeedEntry] = [:] {
        didSet {
            print("did set!")
        }
    }
    
    private var feedEntries: [FeedEntry] = [] {
        didSet {
            let viewModels = feedEntries.map(FeedEntryViewModel.init(from: ))
            feedEntries.forEach(loadImage(for:))
            self.state.displayedEntries = viewModels
        }
    }
    
    
    private func loadImage(for feedEntry: FeedEntry) {
        
        guard let urlString = feedEntry.image, let url = URL(string: urlString) else {
            return
        }
        
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            DispatchQueue.main.async { [self] in
                let image = UIImage(data: data)
                guard let index = state.displayedEntries.firstIndex(where: { $0.id == feedEntry.id }) else {
                    return
                }
                var feedViewModel = state.displayedEntries[index]
                feedViewModel.photo = image
                state.displayedEntries[index] = feedViewModel
            }
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


