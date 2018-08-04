//
//  Database.swift
//  CID-10
//
//  Created by Albin Stigo on 25/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import Foundation
import FMDB

private enum Either<T1, T2> {
    case String(T1)
    case AttributedString(T2)
}

enum SearchScope : Int, CustomStringConvertible {
    case Portuguse  = 0
    case English    = 1
    
    var tableName: String {
        get {
            switch self {
            case .Portuguse: return "search_pt_br"
            case .English: return "search_en_us"
            }
        }
    }
    
    var description : String {
        get {
            switch self {
            case .Portuguse: return "Português"
            case .English: return "Inglês"
            }
        }
    }
}

/* Holds a search results */
class Row : CustomStringConvertible {
    
    private var code : Either<String, NSAttributedString>
    private var desc : Either<String, NSAttributedString>

    // Search results indices
    static private let kCodeColumn = 0
    static private let kDescColumn = 1
    static private let kOffsetsColumn = 2
    
    // Offset indices
    static private let kColumn = 0
    static private let kTermNumber = 1
    static private let kOffset = 2
    static private let kLength = 3
    
    private let highlightColor = UIColor.hospitalGreen()
    
    private let offsets : String
    
    private func attributedStrings() -> (code: NSAttributedString?, desc: NSAttributedString?) {
        
        switch (code, desc) {
        case let (.String(code), .String(desc)):
            do {
                let attributedCode = NSMutableAttributedString(string: code)
                let attributedDesc = NSMutableAttributedString(string: desc)
                
                // Array of strings
                let stra : Array<String> = offsets.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                for offset in stra.map({ str in Int(str)! }).partition(4) {
                    let byteRange = NSMakeRange(offset[Row.kOffset], offset[Row.kLength])
                    
                    switch offset[Int(Row.kColumn)] {
                        
                    case Row.kCodeColumn:
                        let charRange = code.charRangeForByteRange(byteRange)
                        attributedCode.addAttribute(NSForegroundColorAttributeName, value: highlightColor, range: charRange)
                    case Row.kDescColumn:
                        let charRange = desc.charRangeForByteRange(byteRange)
                        attributedDesc.addAttribute(NSForegroundColorAttributeName, value: highlightColor, range: charRange)
                    default: break;
                    }
                }
                
                // immutable
                let _attributedCode = NSAttributedString(attributedString: attributedCode)
                let _attributedDesc = NSAttributedString(attributedString: attributedDesc)
                
                // Cache
                self.code = .AttributedString(_attributedCode)
                self.desc = .AttributedString(_attributedDesc)
                
                return (_attributedCode, _attributedDesc)
            }
        
        case let (.AttributedString(code), .AttributedString(desc)):
            return (code, desc)
        
        default:
            return (nil, nil)
        }
    }
    
    // Lazy?
    var attributedCode : NSAttributedString {
        get {
            let (code, _) = attributedStrings()
            return code!
        }
    }
    
    var attributedDesc : NSAttributedString {
        get {
            let (_, desc) = attributedStrings()
            return desc!
        }
    }
    
    init(code: String, desc: String, offsets: String) {
        self.code = Either.String(code)
        self.desc = Either.String(desc)
        self.offsets = offsets
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
    
    lazy var roman : String = {
        self.cap.toRoman()
    }()
}

class Database {
    // Shared Instance, nity swift singleton pattern
    static let sharedInstance = Database()
    
    let queryLimit = 100
    
    private let url = NSBundle.mainBundle().URLForResource("cid10-2", withExtension: "db")!
    
    // Serial queue
    private let dbqueue : dispatch_queue_t
    
    private let db : FMDatabase
    
    init() {
        
        let queue_attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
            QOS_CLASS_USER_INITIATED, -1)
        dbqueue = dispatch_queue_create("com.cidrapido.dbqueue", queue_attr);
        
        db = FMDatabase(path: url.path)
        db.setShouldCacheStatements(true)
        
        dispatch_async(dbqueue) { self.ensureDbOpen() }
    }
    
    deinit {
        dispatch_async(dbqueue) { self.db.close() }
    }
    
    func ensureDbOpen() {
        guard self.db.openWithFlags(SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX) else {
            assertionFailure("Error opening database")
            abort()
        }
    }
    
    /* Browsing */
    func chapters(completion:(rows : [BrowseRow]) -> ()) {
        
        let query = "select first, last, desc, c, sort from capitulos order by sort asc"

        dispatch_async(dbqueue) {
            
            var rows = [BrowseRow]()
            let res = self.db.executeQuery(query)
            
            while res!.next() {
                let chapter = Chapter(first: res!.stringForColumn("first"),
                                       last: res!.stringForColumn("last"),
                                       desc: res!.stringForColumn("desc"),
                                        cap: Int(res!.intForColumn("sort")),
                                 childCount: Int(res!.intForColumn("c")))
                
                rows.append(chapter)
            }
            
            dispatch_async(dispatch_get_main_queue()) { completion(rows: rows) }
        }
    }
    
    func groups(chapter: Chapter, completion:(rows : [BrowseRow]) -> ()) {
        let query = "select first, last, desc, c, sort from grupos where first between ? and ? order by sort asc"
        
        dispatch_async(dbqueue) {
            
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
        let query = "select first, desc, c, sort from categorias where first between ? and ? order by sort asc"
        
        dispatch_async(dbqueue) {
            
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
        let query = "select first, desc, sort from subcategorias where first like ? order by sort asc"
        
        dispatch_async(dbqueue) {
            
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
        
        return tokens.map( { (token : String) -> String in
            return "\(token)*" // make each token a wildcard for "search as you type"
        }).joinWithSeparator(" ")
        
        /*return " ".join(tokens.map { (token : String) -> String in
            return "\(token)*" // make each token a wildcard for "search as you type"
            })
        */
    }
    
    func find(query: String, scope: SearchScope, completion:(rows : [Row]) -> ()) {
        
        dispatch_async(dbqueue) {

            let res = self.db.executeQuery("select code, desc, offsets(\(scope.tableName)) as offsets from \(scope.tableName) where \(scope.tableName) match ? limit ?", self.parseQuery(query), self.queryLimit)
            
            var rows = [Row]()
            
            while res!.next() {
                let row = Row(code: res!.stringForColumn("code"),
                              desc: res!.stringForColumn("desc"),
                              offsets: res!.stringForColumn("offsets"))
                
                rows.append(row)
            }
            
            dispatch_async(dispatch_get_main_queue()) { completion(rows: rows) }
        }
    }
}