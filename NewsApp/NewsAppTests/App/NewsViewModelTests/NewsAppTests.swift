//
//  NewsAppTests.swift
//  NewsAppTests
//
//  Created by Arsenii Kovalenko on 29.09.2022.
//

import XCTest
import Combine
@testable import NewsApp

final class NewsAppTests: XCTestCase {

    var sut: NewsViewModelProvider!
    var model: NewsModelMock!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        model = NewsModelMock()
        sut = NewsViewModel(model: model)
    }

    override func tearDown() {
        super.tearDown()
        model = nil
        sut = nil
        cancellables.removeAll()
    }

    func testSearchTapped_NetworkAvailable() {
        // Prepare
        model.networkState = .available
        let input = PassthroughSubject<NewsViewModelInput, Never>()
        let output = sut.transform(input.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "State is set to updateNews")
        let query = "Fires"
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak model] event in
                switch event {
                case .showAlert, .showArticle, .showFavouriteArticles:
                    XCTFail("Even't shouldn't be triggered")
                case let .updateNews(news, appending):
                    guard let model else { return }
                    XCTAssertFalse(appending)
                    XCTAssertEqual(news, TextNews.mock)
                    XCTAssertNotNil(model.query)
                    XCTAssertEqual(query, model.query!)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Assert
        input.send(.searchTapped(query))
        
        // Check
        wait(for: [expectation], timeout: 2)
    }
    
    func testSearchTapped_NetworkUnavailable() {
        // Prepare
        let errorMessage = "Something went wrong..."
        model.networkState = .unavailable(.general(errorMessage))
        let input = PassthroughSubject<NewsViewModelInput, Never>()
        let output = sut.transform(input.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "State is set to updateNews")
        let query = "Fires"
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak model] event in
                switch event {
                case .updateNews, .showArticle, .showFavouriteArticles:
                    XCTFail("Even't shouldn't be triggered")
                case .showAlert(_, let message):
                    guard let model else { return }
                    XCTAssertNotNil(model.query)
                    XCTAssertEqual(query, model.query!)
                    XCTAssertEqual(message, errorMessage)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Assert
        input.send(.searchTapped(query))
        
        // Check
        wait(for: [expectation], timeout: 2)
    }
    
    func testFavouritesTapped() {
        // Prepare
        let input = PassthroughSubject<NewsViewModelInput, Never>()
        let output = sut.transform(input.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "State is set to updateNews")
        
        output
            .receive(on: DispatchQueue.main)
            .sink { event in
                switch event {
                case .updateNews, .showArticle, .showAlert:
                    XCTFail("Even't shouldn't be triggered")
                case .showFavouriteArticles:
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Assert
        input.send(.favouritesTapped)
        
        // Check
        wait(for: [expectation], timeout: 2)
    }
    
    func testShouldPaginate_NetworkAvailable() {
        // Prepare
        model.networkState = .available
        let input = PassthroughSubject<NewsViewModelInput, Never>()
        let output = sut.transform(input.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "State is set to updateNews")
        let query = "Fires"
        input.send(.searchTapped(query))
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak model] event in
                switch event {
                case .showAlert, .showArticle, .showFavouriteArticles:
                    XCTFail("Even't shouldn't be triggered")
                case let .updateNews(news, appending):
                    guard let model else { return }
                    XCTAssertTrue(appending)
                    XCTAssertEqual(news, TextNews.mock)
                    XCTAssertNotNil(model.query)
                    XCTAssertEqual(query, model.query!)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Assert
        input.send(.shouldPaginate)
        
        // Check
        wait(for: [expectation], timeout: 2)
    }
    
    func testShouldPaginate_NetworkUnvailable() {
        // Prepare
        let errorMessage = "Something went wrong..."
        model.networkState = .unavailable(.general(errorMessage))
        let input = PassthroughSubject<NewsViewModelInput, Never>()
        let output = sut.transform(input.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "State is set to updateNews")
        let query = "Fires"
        input.send(.searchTapped(query))
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak model] event in
                switch event {
                case .updateNews, .showArticle, .showFavouriteArticles:
                    XCTFail("Even't shouldn't be triggered")
                case .showAlert(_, let message):
                    guard let model else { return }
                    XCTAssertNotNil(model.query)
                    XCTAssertEqual(query, model.query!)
                    XCTAssertEqual(message, errorMessage)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Assert
        input.send(.shouldPaginate)
        
        // Check
        wait(for: [expectation], timeout: 2)
    }
}
