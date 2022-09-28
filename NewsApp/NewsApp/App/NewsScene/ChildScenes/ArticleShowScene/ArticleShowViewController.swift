//
//  ArticleShowViewController.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import UIKit
import Combine
import WebKit

class ArticleShowViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ArticleShowViewModelProvider
    private let input = PassthroughSubject<ArticleShowViewModelInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI Element(s)
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.allowsBackForwardNavigationGestures = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Initialization
    init(viewModel: ArticleShowViewModelProvider) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        setUpBarButtons()
        setUpAutoLayoutConstraints()
        bind(viewModel: viewModel)
        input.send(.onLoad)
    }
    
    private func setUpSubviews() {
        view.addSubview(webView)
    }
    
    private func setUpAutoLayoutConstraints() {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setUpBarButtons() {
        let reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadTapped(_:)))
        let backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped(_:)))
        
        navigationItem.setRightBarButton(reloadBarButtonItem, animated: false)
        navigationItem.setLeftBarButton(backBarButtonItem, animated: false)
    }
    
    // MARK: Binding
    private func bind(viewModel: ArticleShowViewModelProvider) {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .showAlert(title: let title, message: let message):
                    self?.showAlert(title: title, message: message)
                case .loadPage(let url):
                    self?.webView.load(URLRequest(url: url))
                case .reloadPage:
                    self?.webView.reload()
                case .navigateBack:
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func reloadTapped(_ sender: UIButton) {
        input.send(.reloadTapped)
    }
    
    @objc private func closeTapped(_ sender: UIButton) {
        input.send(.backTapped)
    }
}
