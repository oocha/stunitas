//
//  HomeViewController.swift
//  exam
//
//  Created by cha on 05/04/2019.
//  Copyright © 2019 chacha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class HomeViewController: UITableViewController {
    
    fileprivate let search = UISearchController(searchResultsController: nil)
    fileprivate let RESULT_CELL_IDENTIFIER: String = "result_cell"
    fileprivate let viewModel: ViewModel = ViewModel()
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = search
        } else {
            self.navigationItem.titleView = search.searchBar
        }
        
        self.tableView.prefetchDataSource = self
        bind()
    }
    
    func bind() {
        viewModel.data.subscribe {
            [weak self] data in
            _ = self
            self?.tableView.reloadData()
        }
        .disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.value.documents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RESULT_CELL_IDENTIFIER, for: indexPath) as! TableContentCell
        
        guard let item = viewModel.data.value.documents ^= indexPath.row,
            let imageUrl = item["image_url"] as? String,
            let url = URL(string: imageUrl)
        else {
            cell.imgView.image = nil
            return cell
        }
        
        cell.imgView.kf.setImage(with: url)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = viewModel.data.value.documents ^= indexPath.row,
            let width = item["width"] as? Int,
            let height = item["height"] as? Int
        else {
            return 0
        }
        
        return CGFloat(tableView.bounds.width * (CGFloat(height) / CGFloat(width)))
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard viewModel.data.value.documents.count < 1 else { return 0 }
        return tableView.bounds.height / 2
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.data.value.meta["msg"] as? String
    }
}

extension HomeViewController: UISearchResultsUpdating, UITableViewDataSourcePrefetching {
    func updateSearchResults(for searchController: UISearchController) {
        guard let current = searchController.searchBar.text, current.count > 0 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard current == self.search.searchBar.text else { return }
//            self.viewModel.data.accept(Model(documents: [], meta: [:]))
            self.viewModel.requestData(query: current)
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if viewModel.data.value.documents.count - 1 == (indexPaths.last?.row ?? -2),
            !(viewModel.data.value.meta["is_end"] as? Bool ?? true),
            let query = self.search.searchBar.text {
           viewModel.appendData(query: query, sort: nil)
        }

        let urls: [URL] = indexPaths.compactMap({ indexPath -> URL? in
            guard let url = (viewModel.data.value.documents ^= indexPath.row)?["image_url"] as? String else { return nil }
            return URL(string: url)
        })
        ImagePrefetcher(urls: urls).start()
    }
}
