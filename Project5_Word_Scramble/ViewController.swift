//
//  ViewController.swift
//  Project5_Word_Scramble
//
//  Created by Petro Strynada on 05.06.2023.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var currentWord = [CurrentWord]()


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reStartGame))

        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }

        if allWords.isEmpty {
            allWords = ["silkworm"]
        }

//        if currentWord.isEmpty {
//            startGame()
//        } else {
//            loadCurrentWord()
//        }

        loadCurrentWord()
    }
    

//    func startGame() {
//        let newWord = CurrentWord(word: "", usedWords: [])
//        title = allWords.randomElement()
//        newWord.word = title ?? "silkworm"
//        currentWord.append(newWord)
//        saveCurrentWord()
//        tableView.reloadData()
//    }


    @objc func reStartGame() {
        clearCurrentWord()

        let newWord = CurrentWord(word: allWords.randomElement() ?? "silkworm", usedWords: [])
        title = newWord.word
        currentWord.append(newWord)
        saveCurrentWord()
        tableView.reloadData()
    }


    func clearCurrentWord() {
        currentWord.removeAll(keepingCapacity: true)
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < currentWord.count {
            return currentWord[section].usedWords.count
        } else {
            return 0
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)

        // Check if the section index is within the bounds of the currentWord array
        if indexPath.section < currentWord.count {
            let currentWordObject = currentWord[indexPath.section]

            // Check if the row index is within the bounds of the usedWords array of the currentWordObject
            if indexPath.row < currentWordObject.usedWords.count {
                cell.textLabel?.text = currentWordObject.usedWords[indexPath.row]
            }
        }
        return cell
    }


    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.autocapitalizationType = .none // Disable autocapitalization
            textField.delegate = self // Set the delegate to handle text input
        }

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

        guard spellingCheckEnglish(word: lowerAnswer) else {
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

        if let currentWordObject = currentWord.first {
            currentWordObject.usedWords.insert(answer, at: 0)
            currentWord[0] = currentWordObject // Update the currentWord array with the modified currentWordObject
        }
        saveCurrentWord()

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
        if let currentWordObject = currentWord.first {
            return !currentWordObject.usedWords.contains(word)
        }
        return true
    }


    func spellingCheckEnglish(word: String) -> Bool {
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


}


extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Convert any uppercase letters to lowercase and update the text field's text
        textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.lowercased())

        // Always return false to prevent the original text from being replaced
        return false
    }


    func loadCurrentWord() {
        let defaults = UserDefaults.standard

        if let savedCurrentWord = defaults.object(forKey: "currentWord") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                currentWord = try jsonDecoder.decode([CurrentWord].self, from: savedCurrentWord)
                if let firstWord = currentWord.first {
                    title = firstWord.word
                }
            } catch {
                print("Failed to load current word")
            }
        }
    }


    func saveCurrentWord() {
        let jsonEncoder = JSONEncoder()

        if let saveData = try? jsonEncoder.encode(currentWord) {
            let defaults = UserDefaults.standard
            defaults.set(saveData, forKey: "currentWord")
            if let firstWord = currentWord.first {
                title = firstWord.word
            }
        } else {
            print("Failed to save current word.")
        }
    }
}

