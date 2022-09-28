//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import UIKit
import Combine

class NewsViewController: UIViewController {

    private enum Constants {
        static let filterMenuTitle = "Filter"
        static let categoryMenuButtonTitle = "by Category"
        static let countryMenuButtonTitle = "by Country"
        static let sourcesMenuButtonTitle = "by Sources"
        
        enum Layout {
            static let tableViewInsets = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
        }
    }
    
    // MARK: - Properties
    private let viewModel: NewsViewModelProvider
    private let input = PassthroughSubject<NewsViewModelInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UITableViewDiffableDataSource<Int, TextNews.Article>?
    
    // MARK: UI Element(s)
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        
        return searchController
    }()
    
    private lazy var favouritesBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "star.circle.fill"), style: .plain, target: self, action: #selector(favouritesButtonTapped(_:)))
        
        return button
    }()
    
    private lazy var filterBarButtonItem: UIBarButtonItem = {
        let categoryAction = UIAction(title: Constants.categoryMenuButtonTitle) { [weak self] _ in
            self?.input.send(.filterTapped(.byCategory))
        }
        let countryAction = UIAction(title: Constants.countryMenuButtonTitle) { [weak self] _ in
            self?.input.send(.filterTapped(.byCountry))
        }
        let sourcesAction = UIAction(title: Constants.sourcesMenuButtonTitle) { [weak self] _ in
            self?.input.send(.filterTapped(.bySources))
        }
        
        let menu = UIMenu(title: Constants.filterMenuTitle,
                          image: UIImage(systemName: "line.3.horizontal.decrease.circle.fill"),
                          children: [categoryAction, countryAction, sourcesAction])
        let button = UIBarButtonItem(systemItem: .add, menu: menu)
        
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(TextNewsTableViewCell.self)
        tableView.delegate = self
        tableView.backgroundColor = .lightGray
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    // MARK: - Initialization
    init(viewModel: NewsViewModelProvider) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method(s)
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        setUpBarButtons()
        setUpAutoLayoutConstraints()
        configureDataSource()
        bind(viewModel: viewModel)
        input.send(.onLoad)
    }
    
    private func setUpSubviews() {
        title = viewModel.title
        navigationController?.navigationBar.tintColor = .systemYellow
        view.backgroundColor = .lightGray
        
        navigationItem.searchController = searchController
        view.addSubview(tableView)
    }
    
    private func setUpBarButtons() {
        navigationItem.setLeftBarButton(filterBarButtonItem, animated: false)
        navigationItem.setRightBarButton(favouritesBarButtonItem, animated: false)
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, model in
            guard let cell: TextNewsTableViewCell = tableView.dequeueReusableCell(for: indexPath) else { return UITableViewCell() }
            cell.set(model: model)
            cell.delegate = self
            return cell
        }
        
        dataSource?.defaultRowAnimation = .top
    }
    
    private func setUpAutoLayoutConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.tableViewInsets.left),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.tableViewInsets.right),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: Binding
    private func bind(viewModel: NewsViewModelProvider) {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .showAlert(title, message):
                    self?.showAlert(title: title, message: message)
                case let .updateNews(news, appending):
                    self?.applySnapshot(news: news, appending: appending)
                case .showArticle(let url):
                    self?.navigateToArticle(url: url)
                case .showFavouriteArticles:
                    self?.navigateToFavouriteArticles()
                }
            }
            .store(in: &cancellables)
    }
    
    private func applySnapshot(news: TextNews, appending flag: Bool) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        
        if flag {
            snapshot.appendItems(news.articles, toSection: .zero)
        } else {
            snapshot.deleteAllItems()
            snapshot.appendSections([.zero])
            snapshot.appendItems(news.articles, toSection: .zero)
        }
        
        dataSource.apply(snapshot)
    }
    
    private func navigateToArticle(url: URL) {
        let viewController = ViewControllerAssembler.getArticleShowViewController(url: url)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToFavouriteArticles() {
        let viewController = ViewControllerAssembler.getFavouriteArticlesViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func favouritesButtonTapped(_ sender: UIButton) {
        input.send(.favouritesTapped)
    }
}

// MARK: - UISearchBarDelegate
extension NewsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        input.send(.searchTapped(text))
    }
}

// MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let dataSource else { return }
        guard indexPath.row == dataSource.snapshot().numberOfItems(inSection: .zero) - 1 else { return }
        input.send(.shouldPaginate)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        input.send(.newsTapped(item))
    }
}

// MARK: - TextNewsTableViewCellDelegate
extension NewsViewController: TextNewsTableViewCellDelegate {
    func didTapChooseButton(cell: TextNewsTableViewCell, model: TextNewsTableViewCellViewModelProvider) {
        input.send(.addToFavouritesTapped(model))
    }
}
