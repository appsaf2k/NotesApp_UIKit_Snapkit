//
//  Extensions.swift
//  NotesApp
//
//  Created by @andreev2k on 10.01.2023.
//

import UIKit
import SnapKit


//MARK: Custom UILabel for highlighting text in notes when searching in Table(TextLabel, detailTextLabel)
extension UILabel {
    func highlight(text: String?, font: UIFont? = nil, color: UIColor? = nil, backColor: UIColor? = nil) {
        guard let fullText = self.text, let target = text else {
            return
        }
        
        let attribText = NSMutableAttributedString(string: fullText)
        let range: NSRange = attribText.mutableString.range(of: target, options: .caseInsensitive)
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let font = font {
            attributes[.font] = font
        }
        if let color = color {
            attributes[.foregroundColor] = color
        }
        if let backColor = backColor {
            attributes[.backgroundColor] = backColor
        }
        
        
        attribText.addAttributes(attributes, range: range)
        self.attributedText = attribText
    }
}

//MARK: Custom Navigation Bar
extension UIViewController {
    
    func customButton(imageName: String, selector: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor                  = .systemBlue
        button.imageView?.contentMode     = .scaleAspectFit
        button.contentVerticalAlignment   = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: button)
        return menuBarItem
    }
    
    func editableButton(isEditable: Bool, selector: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setTitle(isEditable ? "Done" : "Edit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: button)
        return menuBarItem
    }
}


extension ViewController: UISearchBarDelegate {
    func makeConstraints() {
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(140)
            make.left.right.equalToSuperview().inset(16)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(190)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(34)
        }
    }
    
    
    //MARK:- SEARCH BAR DELEGATE METHOD FUNCTION
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        notesList = savedNotes.items
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    
    //MARK: Method searching for titles and notes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        notesList = searchText.isEmpty ? savedNotes.items : savedNotes.items.filter { (item) -> Bool in
            
            let items = item.title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            
            return items
        }
        
        if notesList.isEmpty {
            
            notesList = searchText.isEmpty ? savedNotes.items : savedNotes.items.filter { (item) -> Bool in
                
                let items = item.note.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                
                return items
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: Adding cancel button
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}



extension AddNotesVC {
    func makeConstraints() {
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
        
        view.addSubview(labelNewNote)
        labelNewNote.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.left.equalToSuperview().inset(16)
        }
        
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(labelNewNote.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        view.addSubview(noteTextView)
        noteTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(34)
        }
    }
    
    //MARK: Custom placeholder for TextView
    func addPlaceholderForNoteTextView() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some text..."
        placeholderLabel.font = .italicSystemFont(ofSize: (noteTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (noteTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.isHidden = !noteTextView.text.isEmpty
        noteTextView.addSubview(placeholderLabel)
    }
}



extension ShowNoteVC {
    func makeConstraints() {
        view.addSubview(titleTextView)
        titleTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(100)
            make.left.right.equalToSuperview().inset(32)
        }
        
        view.addSubview(noteTextView)
        noteTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(34)
        }
    }
    
    //MARK: highlighting text in notes when searching
    func generateAttributedString(with searchTerm: String, targetString: String) -> NSAttributedString? {
        
        let font = UIFont.systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSMutableAttributedString(string: targetString, attributes: attributes)
        
        do {
            let regex = try NSRegularExpression(pattern: searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: .diacriticInsensitive, locale: .current), options: .caseInsensitive)
            let range = NSRange(location: 0, length: targetString.utf16.count)
            for match in regex.matches(in: targetString.folding(options: .diacriticInsensitive, locale: .current), options: .withTransparentBounds, range: range) {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: match.range)
            }
            return attributedString
        } catch {
            NSLog("Error creating regular expresion: \(error)")
            return nil
        }
    }
}
