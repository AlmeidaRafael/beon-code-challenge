//
//  ViewController.swift
//  Interview
//
//  Created by Rafael Almeida Oliveira on 27/04/22.
//

import UIKit

final class ViewController: UIViewController {
    private lazy var sendButton: UIButton = {
       let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var userNumberTextField: UITextField = {
       let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.placeholder = "Input your number here"
        textField.backgroundColor = .red
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sendButton)
        view.addSubview(userNumberTextField)
        view.addSubview(resultLabel)
        view.backgroundColor = .white
        
        setupConstraints()
        setupAdditionalConfiguration()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            
            userNumberTextField.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -40),
            userNumberTextField.leadingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            userNumberTextField.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor),
            userNumberTextField.heightAnchor.constraint(equalToConstant: 40),
            
            resultLabel.bottomAnchor.constraint(equalTo: userNumberTextField.topAnchor, constant: -40),
            resultLabel.trailingAnchor.constraint(equalTo: userNumberTextField.trailingAnchor),
            resultLabel.leadingAnchor.constraint(equalTo: userNumberTextField.leadingAnchor),
        ])
    }
    
    private func setupAdditionalConfiguration() {
        sendButton.addTarget(self, action: #selector(sendNumber), for: .touchUpInside)
    }
    
    @objc func sendNumber() {
        guard let textInputed = userNumberTextField.text else {
            return
        }
        requestNumber(number: textInputed) { [weak self] result in
            DispatchQueue.main.async {
                self?.resultLabel.text = result.text
            }
        }
    }
    
    private func requestNumber(number: String, completion: @escaping (Response) -> Void) {
        guard let url = URL(string: "http://numbersapi.com/\(number)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            
            do {
                let jsonDecode = JSONDecoder()
                let decoded = try jsonDecode.decode(Response.self, from: data)
                
                completion(decoded)
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

struct Response: Decodable {
    let text: String
}
