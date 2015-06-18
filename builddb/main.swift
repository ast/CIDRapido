//
//  main.swift
//  builddb
//
//  Created by Albin Stigo on 05/01/15.
//  Copyright (c) 2015 Albin Stigo. All rights reserved.
//

import Foundation

//let path = "/Users/albin/Documents/projects/CID-10/db"
let dbDir = [String](Process.arguments).last!

let allEn = dbDir.pathForFile("all_en-us", ofType: "csv")!
let allPt = dbDir.pathForFile("all_pt-br", ofType: "csv")!
let createSQLpath = dbDir.pathForFile("create", ofType: "sql")!
let dbPath = dbDir.pathForFile("test", ofType: "db")!

// Remove old file
do {
    try NSFileManager.defaultManager().removeItemAtPath(dbPath)
} catch let error as NSError {
    print(error.description)
}

// Open db
let db = FMDatabase(path: dbPath)
guard db.open() != false else {
    abort()
}

// Create tables
let createSQL = try String(contentsOfFile: createSQLpath)
db.executeStatements(createSQL)

print("begin.")

/*
// en-us
do {
    db.beginTransaction()
    let lr = LineReader(inputStream: NSInputStream(fileAtPath: allEn)!)
    while let line = lr.readLine() {
        let fields = line.componentsSeparatedBySemicolon()
        assert(fields.count == 2, "Missing field in CSV.")
        db.executeUpdate("insert into search_en_us(code, desc) values(?, ?)", withArgumentsInArray: fields)
    }
    db.commit()
}*/

// pt-br
do {
    db.beginTransaction()
    let lr = LineReader(inputStream: NSInputStream(fileAtPath: allPt)!)
    while let line = lr.readLine() {
        let fields = line.componentsSeparatedBySemicolon()
        assert(fields.count == 5, "Missing field in CSV.")
        db.executeUpdate("insert into cid_temp(type, first, last, sort, desc) values(?, ?, ?, ?, ?)", withArgumentsInArray: fields)
    }
    db.commit()
}

print("done.")

//String(contentsOfFile: dbdir!.pathForFile("all_en-us", ofType: "csv")!)

/*
// Filename in Product->Schemef
let args = [String](Process.arguments)
let path = args[1]

let csvurl = NSURL(fileURLWithPath: path)?.URLByAppendingPathComponent("all.csv")
let dburl = NSURL(fileURLWithPath: path)?.URLByAppendingPathComponent("all.db")

print(csvurl)
*/

/* Load lines

let db = FMDatabase(path: dburl!.path)
if !db.open() {
    abort()
}

if(!db.executeStatements("create table cid(type TEXT, first TEXT, last TEXT, sort, INTEGER, desc TEXT)")) {
    abort()
}

db.beginTransaction()

for line in lines {
    let parts = line.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ";"))
    
    let type = parts[0] as! String
    
    switch type {
    case "cap", "grp":
        db.executeUpdate("insert into cid(type, first, last, desc) values(?, ?, ?, ?)", withArgumentsInArray: parts)
    case "cat", "sub":
        db.executeUpdate("insert into cid(type, first, desc) values(?, ?, ?)", withArgumentsInArray: parts)
    default: break
    }
    
    println(line)
}

db.commit()*/
