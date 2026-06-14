//
//  ListViewController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 02.03.26.
//

import UIKit
import HackerNewsFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    private(set) public var errorView = ErrorView()
    
    private var loadingControllers = [IndexPath: CellController]()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView, cellProvider: { (tableView, index, controller) -> UITableViewCell? in
            return controller.datasource.tableView(tableView, cellForRowAt: index)
        })
    }()
    
    private var onViewDidAppear: ((ListViewController) -> Void)?
    
    public var onRefresh: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 170
        configureErrorView()
        
        onViewDidAppear = { vc in
            vc.onViewDidAppear = nil
            vc.refresh()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        onViewDidAppear?(self)
    }
    
    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
        ])
        
        tableView.tableHeaderView = container
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                var snapshot = self.dataSource.snapshot()
                snapshot.reconfigureItems(snapshot.itemIdentifiers)
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public func display(_ sections: [CellController]...) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        sections.enumerated().forEach { section, cellControllers in
            snapshot.appendSections([section])
            snapshot.appendItems(cellControllers, toSection: section)
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    public func update(id: AnyHashable) {
        var snapshot = dataSource.snapshot()
        guard let item = snapshot.itemIdentifiers.first(where: { $0.id == id }) else { return }
        snapshot.reconfigureItems([item])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.datasourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.datasourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        return dataSource.itemIdentifier(for: indexPath)
    }
}
