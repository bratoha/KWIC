//
//  KWIC
//
//  Made by
//      Dmitry Goncharov
//      Anton Kalinin
//      Alexey Danilov
//      Hank-debain Djambong Tenkeu
//      Rasul Babaev
//


import Foundation

struct KwicText {
    var words: [[String]]
    var exceptions: [String] = []
}

struct Line {
    var words: [String]
    var offset: Int
    var textIndex: Int
}

enum InputMode {
    case file(name: String)
    case text(content: String)
}

func input(_ text: String, withSeparator separator: Character = ";") -> KwicText {
    let subcontent = text.split(separator: separator)
    
    if subcontent.isEmpty {
        fatalError("File is empty")
    } else if subcontent.count > 2 {
        fatalError("Incorrect file content")
    }
    
    let (text, exceptions) = subcontent.count == 1 ? (subcontent[0], nil) : (subcontent[1], subcontent[0])
    let lines = text.split(separator: "\n").filter { !$0.isEmpty }.map { String($0).lowercased() }
    let splitedExceptions = exceptions != nil
        ? exceptions!.split(separator: "\n").map {String($0).lowercased()}
        : []
    
    return KwicText(
        words: lines.map {$0.split(separator: " ").map { String($0) }},
        exceptions: splitedExceptions)
}

func input(fromFile fileName: String, withSeparator separator: Character = ";") -> KwicText {
    guard let path = Bundle.main.url(forResource: fileName, withExtension: ""), let content = try? String(contentsOf: path) else {
        fatalError("Can't read file")
    }
    
    return input(content, withSeparator: separator)
}


func shiftRight<T>(_ array: [T], on amount: Int = 1) -> [T] {
    assert(-array.count...array.count ~= amount, "Shift amount out of bounds")
    var amount = amount
    if amount < 0 { amount += array.count }
    return Array(array[amount ..< array.count] + array[0 ..< amount])
}

func shift(_ kwic: KwicText) -> [Line] {
    var result: [Line] = []

    let words = kwic.words
    let excpetions = kwic.exceptions
    
    for i in 0..<words.count {
        var localLines: [Line] = []
        
        for j in 0..<words[i].count {
            let shiftedLine = shiftRight(words[i], on: j)
            
            if !shiftedLine.isEmpty, excpetions.contains(shiftedLine.first!) {
                continue
            }
            
            localLines.append(Line(words: shiftRight(words[i], on: j), offset: j, textIndex: i))
        }
        
        result += localLines
    }
    
    return result
}

func compare(_ lhv: [String], _ rhv: [String]) -> Bool {
    for i in 0..<rhv.count {
        switch lhv[i].compare(rhv[i], options: .caseInsensitive)  {
        case .orderedAscending:
            return false
        case .orderedDescending:
            return true
        case .orderedSame:
            break
        }
    }
    
    return false
}

func sort(_ lines: [Line]) -> [Line] {
    return lines.sorted(by: { lhv, rhv in
        if lhv.words.count > rhv.words.count {
            return !compare(lhv.words, rhv.words)
        } else {
            return compare(rhv.words, lhv.words)
        }
    })
}

func output(_ lines: [Line], from text: KwicText) {
    for l in lines {
        let printLine = text.words[l.textIndex].enumerated().map { i, w in
            if i == l.offset {
                return w.uppercased()
            }
            
            return w
        }.joined(separator: " ")
        
        print(printLine)
    }
}

func kwic(mode: InputMode, separateWith separartor: Character = ";") {
    var kwicText: KwicText
    
    switch mode {
    case .file(let name):
        kwicText = input(fromFile: name, withSeparator: separartor)
    case .text(let content):
        kwicText = input(content, withSeparator: separartor)
    }
    
    var lines = shift(kwicText)
    lines = sort(lines)
    output(lines, from: kwicText)
}

var text = """
a
is
;
Descent of Man
The Ascent of Man
The Old Man and The Sea
A Portrait of The Artist As a Young Man
A Man is a Man but Bubblesort IS A DOG
"""

kwic(mode: .text(content: text))
kwic(mode: .file(name: "input"))
