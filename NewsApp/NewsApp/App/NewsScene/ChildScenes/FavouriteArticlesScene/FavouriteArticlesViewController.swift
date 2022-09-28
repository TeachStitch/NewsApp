//
//  FavouriteArticlesViewController.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import UIKit
import Combine

class FavouriteArticlesViewController: UIViewController {
    
    private enum Constants {
        
        enum Layout {
            static let tableViewInsets = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
        }
    }
    
    // MARK: - Properties
    private let viewModel: FavouriteArticlesViewModelProvider
    private let input = PassthroughSubject<FavouriteArticlesViewModelInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UITableViewDiffableDataSource<Int, ArticleDTO>?
    
    // MARK: UI Element(s)
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(BaseTextNewsTableViewCell.self)
        tableView.backgroundColor = .lightGray
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    // MARK: - Initialization
    init(viewModel: FavouriteArticlesViewModelProvider) {
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
        setUpAutoLayoutConstraints()
        configureDataSource()
        bind(viewModel: viewModel)
        input.send(.onLoad)
    }
    
    private func setUpSubviews() {
        title = viewModel.title
        view.backgroundColor = .lightGray
        view.addSubview(tableView)
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, model in
            guard let cell: BaseTextNewsTableViewCell = tableView.dequeueReusableCell(for: indexPath) else { return UITableViewCell() }
            cell.set(model: model)
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
    private func bind(viewModel: FavouriteArticlesViewModelProvider) {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .showAlert(title, message):
                    self?.showAlert(title: title, message: message)
                case .showArticle(let url):
                    self?.navigateToArticle(url: url)
                case .deleteArticle(let article):
                    self?.deleteArticle(article)
                case .updateArticles(let articles):
                    self?.applySnapshot(articles: articles)
                }
            }
            .store(in: &cancellables)
    }
    
    private func applySnapshot(articles: [ArticleDTO]) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        
        snapshot.appendSections([.zero])
        snapshot.appendItems(articles, toSection: .zero)
        dataSource.apply(snapshot)
    }
    
    private func deleteArticle(_ article: ArticleDTO) {
        guard let dataSource else { return }
        let defaultAnimation = dataSource.defaultRowAnimation
        dataSource.defaultRowAnimation = .left
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([article])
        dataSource.apply(snapshot)
        dataSource.defaultRowAnimation = defaultAnimation
    }
    
    private func navigateToArticle(url: URL) {
        let viewController = ViewControllerAssembler.getArticleShowViewController(url: url)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension FavouriteArticlesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let dataSource, let article = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            self?.input.send(.swipedToDeleteArticle(article))
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        input.send(.newsTapped(item))
    }
}
