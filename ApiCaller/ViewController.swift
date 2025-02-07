//
//  ViewController.swift
//  ApiCaller
//
//  Created by Sange Sherpa on 23/12/2024.
//

import UIKit
import Combine

struct User: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

enum ErrorType: Error {
    case defaultError
}

class ViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    let button: UIButton = {
        var button = UIButton()
        button.setTitle("button", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    @objc func tapped() {
        print("Tapped")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        button.addTarget(self, action: #selector(scheduleNotificationsWithActions), for: .touchUpInside)
        
//        self.fetchDataUsingDatatask()
//        self.workingFunction()
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .finished:
//                        print(completion)
//                    case .failure(let failure):
//                        print(failure)
//                    }
//                },
//                receiveValue: { users in
//                    for (index, user) in users.enumerated() {
//                        print("\(index): \(user.title)")
//                    }
//                    
//                })
//            .store(in: &cancellables)
        
//        notWorkingFunction()
    }

    fileprivate func fetchDataUsingDatatask() {
        guard let url = URL(string: "https://rss.applemarketingtools.com/api/v2/us/apps/top-free/50/apps.json") else {
            print("Could not create URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let responseData = data else {
                print("No data")
                return
            }
            
            do {
                let data = try JSONDecoder().decode([User].self, from: responseData)
                print(data)
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
    fileprivate func workingFunction() -> AnyPublisher<[User], Error> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap({ (data, response) in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else
                {
                    throw URLError(.badServerResponse)
                }
                
                return data
            })
            .decode(type: [User].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    
    fileprivate func notWorkingFunction() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: RunLoop.main)
            .tryMap({ (data, response) in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else
                {
                    throw URLError(.badServerResponse)
                }
                
                return data
            })
            .decode(type: [User].self, decoder: JSONDecoder())
            .retry(3)
            .catch({ error -> Just<[User]> in
                print(error.localizedDescription)
                return Just([])
            })
            .sink(
                receiveCompletion: {
                    print("Completion: \($0)")
                },
                receiveValue: {
                    print("Received Value: \($0)")
                    
                })
            .store(in: &cancellables)
    }
    
    @objc func scheduleNotificationsWithActions() {
        let content = UNMutableNotificationContent()
        content.title = "Notication Test"
        content.body = "This is test reminder as notification"
        content.sound = UNNotificationSound.defaultCritical
        
        let notificationActions: [UNNotificationAction] = [
            .init(identifier: "1", title: "1", options: [.authenticationRequired]),
            .init(identifier: "2", title: "2", options: [.destructive]),
            .init(identifier: "3", title: "3", options: [.foreground]),
            .init(identifier: "4", title: "4", options: []),
            .init(identifier: "5", title: "5", options: [])
        ]
        
        let category = UNNotificationCategory(identifier: "reminder", actions: notificationActions, intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "reminder"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "reminderNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            }
            
            print("Notification Scheduled Successfully")
        }
    }
    
}

