//
//  BaseTextNewsTableViewCell.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import UIKit
import Combine

protocol BaseTextNewsTableViewCellViewModelProvider {
    var title: String { get }
    var description: String { get }
    var author: String { get }
    var source: String { get }
    var imageUrl: URL { get }
}

class BaseTextNewsTableViewCell: UITableViewCell, TableViewCellConfigurable {
    private enum Constants {
        static let leftContainerStackViewSpacing = 6.0
        static let rightContainerStackViewSpacing = 2.0
        static let cornerRadius = 8.0
        static let bannerImageViewHeight = 120.0
        
        enum Layout {
            static let containerStackViewInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        }
    }
    
    // MARK: Properties
    @Published var model: BaseTextNewsTableViewCellViewModelProvider?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI Element(s)
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.font = UIFont.preferredFont(forTextStyle: .title3, compatibleWith: .current)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: .current)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var sourceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: .current)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var contentCreatorsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            authorNameLabel, sourceNameLabel
        ])
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            bannerImageView,
            titleLabel,
            contentCreatorsStackView,
            descriptionLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = Constants.rightContainerStackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSubviews()
        setUpAutoLayoutConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
        setUpAutoLayoutConstraints()
        bind()
    }
    
    // MARK: - Method(s)
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        authorNameLabel.text = nil
        sourceNameLabel.text = nil
        descriptionLabel.text = nil
        bannerImageView.image = nil
    }
    
    private func setUpSubviews() {
        contentView.addSubview(containerStackView)
    }
    
    private func setUpAutoLayoutConstraints() {
        NSLayoutConstraint.activate([
            bannerImageView.heightAnchor.constraint(equalToConstant: Constants.bannerImageViewHeight),
            
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.containerStackViewInsets.top),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.containerStackViewInsets.bottom),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.containerStackViewInsets.right),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.containerStackViewInsets.right)
        ])
    }
    
    // MARK: Binding
    private func bind() {
        $model
            .sink { [weak self] model in
                guard let model else { return }
                self?.titleLabel.text = model.title
                self?.descriptionLabel.text = model.description
                self?.authorNameLabel.text = model.author
                self?.sourceNameLabel.text = model.source
                self?.bannerImageView.load(url: model.imageUrl)
            }
            .store(in: &cancellables)
    }
}
