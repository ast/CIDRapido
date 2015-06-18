//
//  Database.swift
//  CID-10
//
//  Created by Albin Stigo on 25/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import Foundation
import FMDB

// Private for file scope
private let _sharedInstance = Database()


// Search results indices
private let kCodeColumn = 0
private let kDescColumn = 1
private let kOffsetsColumn = 2

// Offset indices
private let kColumn = 0
private let kTermNumber = 1
private let kOffset = 2
private let kLength = 3

private let highlightColor = UIColor.hospitalGreen()

/* Holds a search results */
class Row : CustomStringConvertible {
    let code : String
    let desc : String

    private let _offsets : String
    private var _attributedCode : NSAttributedString?
    private var _attributedDesc : NSAttributedString?
    
    private func createAttributedStrings () {
        let attributedCode = NSMutableAttributedString(string: code)
        let attributedDesc = NSMutableAttributedString(string: desc)
        
        // Array of strings
        let stra : Array<String> = _offsets.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        for offset in stra.map({ str in Int(str)! }).partition(4) {
            let byteRange = NSMakeRange(offset[kOffset], offset[kLength])

            switch offset[Int(kColumn)] {
                
            case kCodeColumn:
                let charRange = code.charRangeForByteRange(byteRange)
                attributedCode.addAttribute(NSForegroundColorAttributeName, value: highlightColor, range: charRange)
            case kDescColumn:
                let charRange = desc.charRangeForByteRange(byteRange)
                attributedDesc.addAttribute(NSForegroundColorAttributeName, value: highlightColor, range: charRange)
            default: break;
            }
        }
        
        _attributedCode = NSAttributedString(attributedString: attributedCode)
        _attributedDesc = NSAttributedString(attributedString: attributedDesc)
    }
    
    // Lazy?
    var attributedCode : NSAttributedString {
        // This is cached.
        get {
            if let attributedCode = _attributedCode {
                return attributedCode
            } else {
                createAttributedStrings()
                return _attributedCode!
            }
        }
    }
    
    var attributedDesc : NSAttributedString {
        get {
            if let attributedDesc = _attributedDesc {
                return attributedDesc
            } else {
                createAttributedStrings()
                return _attributedDesc!
            }
        }
    }
    
    init(code: String, desc: String, offsets: String) {
        self.code = code
        self.desc = desc
        self._offsets = offsets
    }
    
    var description: String {
        return "\(code) - \(desc)"
    }
}

protocol BrowseRow : CustomStringConvertible {
    var first: String { get }
    var desc: String { get }
}

protocol BrowseContainer: BrowseRow {
    var childCount: Int { get }
}

class SubCategory : BrowseRow {
    let first: String
    let desc: String
    
    init(first: String, desc: String) {
        self.first = first
        self.desc = desc
    }
    
    var description: String {
        return "\(first) - \(desc)"
    }
}

class Category : SubCategory, BrowseContainer {
    let childCount : Int
    
    init(first: String, desc: String, childCount: Int) {
        self.childCount = childCount
        super.init(first: first, desc: desc)
    }
}

class Group : Category {
    let last : String
    
    init(first: String, last: String, desc: String, childCount: Int) {
        self.last = last
        super.init(first: first, desc: desc, childCount: childCount)
    }
    
    override var description: String {
        return "\(first)-\(last) - \(desc)"
    }
}

class Chapter : Group {
    let cap: Int
    
    init(first: String, last: String, desc: String, cap: Int, childCount: Int) {
        self.cap = cap
        super.init(first: first, last: last, desc: desc, childCount: childCount)
    }
    
    var roman : String {
        get {
            
            // TODO: Optimize
            
            let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
            let arabicValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
            
            var romanValue = ""
            var startingValue = cap
            
            for (index, romanChar) in romanValues.enumerate() {
                let arabicValue = arabicValues[index]
                
                let div = startingValue / arabicValue
                
                if (div > 0)
                {
                    for _ in 0..<div
                    {
                        romanValue += romanChar
                    }
                    
                    startingValue -= arabicValue * div
                }
            }
            
            return romanValue
        }
    }
}

class Database {
    // Shared Instance, nity swift singleton pattern
    static let sharedInstance = Database()
    
    private let url = NSBundle.mainBundle().URLForResource("cid10-2", withExtension: "db")!
    
    // Serial queue
    private let dbqueue = dispatch_queue_create("com.cidrapido.dbqueue", DISPATCH_QUEUE_SERIAL);
    
    private let db : FMDatabase
    
    init() {
        db = FMDatabase(path: url.path)
        db.setShouldCacheStatements(true)
        
        dispatch_async(dbqueue) { self.ensureDbOpen() }
    }
    
    deinit {
        dispatch_async(dbqueue) {
            self.db.close()
            return
        }
    }
    
    func ensureDbOpen() {
        let SQLITE_OPEN_READONLY : Int32 = 0x00000001
        let SQLITE_OPEN_NOMUTEX : Int32 = 0x00008000
        
        if !self.db.openWithFlags(SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX) {
            print("Error opening database")
        }
    }
    
    /* Browsing */
    func chapters(completion:(rows : [BrowseRow]) -> ()) {
        
        let query = "select first, last, cap, desc, c from capitulos order by cap asc"

        dispatch_async(dbqueue) {
            
            self.ensureDbOpen()
            
            var rows = [BrowseRow]()
            let res = self.db.executeQuery(query)
            
            while res!.next() {
                let chapter = Chapter(first: res!.stringForColumn("first"),
                                       last: res!.stringForColumn("last"),
                                       desc: res!.stringForColumn("desc"),
                                        cap: Int(res!.intForColumn("cap")),
                                 childCount: Int(res!.intForColumn("c")))
                
                rows.append(chapter)
            }
            
            dispatch_async(dispatch_get_main_queue()) { completion(rows: rows) }
        }
    }
    
    func groups(chapter: Chapter, completion:(rows : [BrowseRow]) -> ()) {
        let query = "select first, last, desc, c from grupos where first between ? and ? order by first asc"
        
        dispatch_async(dbqueue) {
            
            self.ensureDbOpen()
            
            var rows = [BrowseRow]()
            let res = self.db.executeQuery(query, chapter.first, chapter.last)
            
            while res!.next() {
                
                let row = Group(first: res!.stringForColumn("first"),
                    last: res!.stringForColumn("last"),
                    desc: res!.stringForColumn("desc"),
                    childCount: Int(res!.intForColumn("c")))

                rows.append(row)
            }
            
            dispatch_async(dispatch_get_main_queue()) { completion(rows: rows) }
        }
    }
    
    func categories(group: Group, completion:(rows : [BrowseRow]) -> ()) {
        let query = "select first, desc, c from categorias where first between ? and ? order by first asc"
        
        dispatch_async(dbqueue) {
            
            self.ensureDbOpen()
            
            var rows = [BrowseRow]()
            let res = self.db.executeQuery(query, group.first, group.last)
            
            while res!.next() {
                
                let row = Category(first: res!.stringForColumn("first"),
                                    desc: res!.stringForColumn("desc"),
                              childCount: Int(res!.intForColumn("c")))
                
                rows.append(row)
            }
            
            dispatch_async(dispatch_get_main_queue()) { completion(rows: rows) }
        }
    }
    
    func subcategories(category: Category, completion:(rows : [BrowseRow]) -> ()) {
        let query = "select first, desc from subcategorias where first like ? order by first asc"
        
        dispatch_async(dbqueue) {
            
            self.ensureDbOpen()
            
            var rows = [BrowseRow]()
            let res = self.db.executeQuery(query, "\(category.first)%") // optimize
            
            while res!.next() {
                let row = SubCategory(first: res!.stringForColumn("first"),
                                       desc: res!.stringForColumn("desc"))
                
                rows.append(row)
            }
            
            dispatch_async(dispatch_get_main_queue()) { completion(rows: rows) }
        }
        
    }
    
    /* Searching */
    private func parseQuery(query: String) -> String {
        // split at whitespace
        let tokens = query.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        return " ".join(tokens.map { (token : String) -> String in
            return "\(token)*" // make each token a wildcard for "search as you type"
            })
    }
    
    func find(query: String, completion:(rows : [Row]) -> ()) {
        
        let QueryLimit = 100
        
        dispatch_async(dbqueue) {
            
            self.ensureDbOpen()
            
            let res = self.db.executeQuery("select code, desc, offsets(search) as offsets from search where search match ? limit ?", self.parseQuery(query), QueryLimit)
            
            var rows = [Row]()
            
            while res!.next() {
                let row = Row(code: res!.stringForColumnIndex(Int32(kCodeColumn)),
                              desc: res!.stringForColumnIndex(Int32(kDescColumn)),
                              offsets: res!.stringForColumnIndex(Int32(kOffsetsColumn)))
                
                rows.append(row)
            }
            
            dispatch_async(dispatch_get_main_queue()) { completion(rows: rows) }
        }
    }
}