//
//  ViewController.swift
//  Project5_Word_Scramble
//
//  Created by Petro Strynada on 05.06.2023.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))

        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }

        if allWords.isEmpty {
            allWords = ["silkworm"]
        }

        startGame()
    }

        @objc func startGame() {
        usedWords = []
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

        let errorTitle: String
        let errorMessage: String

        guard isPossible(word: lowerAnswer) else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title!.lowercased())."
            return showErrorMessage(title: errorTitle, message: errorMessage)
        }

        guard isOriginal(word: lowerAnswer) else {
            errorTitle = "Word already used"
            errorMessage = "Be more original!"
            return showErrorMessage(title: errorTitle, message: errorMessage)
        }

        guard isReal(word: lowerAnswer) else {
            errorTitle = "Word is not recognized"
            errorMessage = "You can't just make them up, you know!"
            return showErrorMessage(title: errorTitle, message: errorMessage)
        }

        guard !isEmpty(word: lowerAnswer) else {
            errorTitle = "Word should have some laters"
            errorMessage = "Please type the word"
            return showErrorMessage(title: errorTitle, message: errorMessage)
        }

        guard !isStartWord(word: lowerAnswer) else {
            errorTitle = "Start word not allowed"
            errorMessage = "Try another word"
            return showErrorMessage(title: errorTitle, message: errorMessage)
        }

//        guard !isUppercased(word: lowerAnswer) else {
//            errorTitle = "Word should not have uppercased laters"
//            errorMessage = "Try again with lowercased laters"
//            return showErrorMessage(title: errorTitle, message: errorMessage)
//        }

        //TODO: all words should be accepted and sing in row as lover cased

        usedWords.insert(answer, at: 0)

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        func showErrorMessage(title errorTitle: String, message errorMessage: String) {
            let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }


    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }

        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }

        return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

    func isEmpty(word: String) -> Bool {
        guard word.isEmpty else { return false }
        return true
    }

    func isStartWord(word: String) -> Bool {
        guard word == title else { return false }
        return true
    }

//    func isUppercased(word: String) -> Bool {
//        guard word.contains(word.uppercased()) else { return false }
//        return true
//    }
}

