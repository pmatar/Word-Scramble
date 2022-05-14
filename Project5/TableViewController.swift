//
//  TableViewController.swift
//  Project5
//
//  Created by Paul Matar on 14/05/2022.
//

import UIKit

class TableViewController: UITableViewController {
    private var allWords: [String] = []
    private var usedWords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWords()
        startGame()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = usedWords[indexPath.row]
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - Private Methods

extension TableViewController {
    
    @objc private func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc private func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] _ in
            guard let answer = ac.textFields?.first?.text else { return }
            self.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    private func setupWords() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    private func showErrorAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: - Submit Method
    
    private func submit(_ answer: String) {
        
        let errorTitle: String
        let errorMessage:String
        
        guard !answer.isEmpty else {
            showErrorAlert(title: "Empty", message: "Wright something!")
            return
        }
        guard isPossible(word: answer.lowercased()) else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title ?? "")!"
            showErrorAlert(title: errorTitle, message: errorMessage)
            return
        }
        guard isOriginal(word: answer.lowercased()) else {
            errorTitle = "Word already used"
            errorMessage = "Be more original!"
            showErrorAlert(title: errorTitle, message: errorMessage)
            return
        }
        guard isReal(word: answer.lowercased()) else {
            errorTitle = "Word not recognized"
            errorMessage = "You can't just make them up, you know!"
            showErrorAlert(title: errorTitle, message: errorMessage)
            return
        }
        guard isShortOrSame(word: answer.lowercased()) else {
            errorTitle = "Word too short or identical"
            errorMessage = "You can't use short words or use the initial word!"
            showErrorAlert(title: errorTitle, message: errorMessage)
            return
        }
        
        usedWords.insert(answer, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Validation methods
    
    private func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            guard let position = tempWord.range(of: String(letter)) else { return false }
            tempWord.remove(at: position.lowerBound)
        }
        return true
    }
    
    private func isOriginal(word: String) -> Bool {
        let duplicateWord = usedWords.first { $0.lowercased() == word }
        return duplicateWord == nil
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    private func isShortOrSame(word: String) -> Bool {
        guard let title = title else { return false }
        return ( word.count < 3 || word == title.lowercased() ) ? false : true
    }
    
    // MARK: - UI Setup method
    
    private func setupUI() {
        let gradient = CAGradientLayer()
        let topColor = UIColor(red: 200/255, green: 155/255, blue: 99/255, alpha: 1).cgColor
        let bottomCollor = UIColor(red: 12/255, green: 12/255, blue: 23/255, alpha: 1).cgColor
        
        gradient.colors = [topColor, bottomCollor]
        gradient.frame = tableView.bounds
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        
        let backgroundView = UIView(frame: tableView.bounds)
        backgroundView.layer.insertSublayer(gradient, at: 0)
        tableView.backgroundView = backgroundView
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = .clear
        
        navigationItem.scrollEdgeAppearance = navAppearance
        navigationItem.standardAppearance = navAppearance
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
    }
}
