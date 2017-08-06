//
//  main.swift
//  ImageDownloader
//
//  Created by Alcala, Jose Luis on 7/19/17.
//  Copyright © 2017 alcaljos. All rights reserved.
//

import Foundation
import Cocoa

let queue = OperationQueue()
queue.maxConcurrentOperationCount = 1


let textSearch = "adidas t-shirt"
let fileHandle = FileManager.default
let folder = "/Users/alcaljos/adidas_images/\(textSearch)"
var bool = ObjCBool(true)
if !fileHandle.fileExists(atPath: folder, isDirectory: &bool){
    try! fileHandle.createDirectory(at: URL(fileURLWithPath: folder, isDirectory: true), withIntermediateDirectories: true, attributes: nil)
}
let textFile = "\(folder)/\(textSearch).txt"
if !fileHandle.fileExists(atPath:textFile ){
     fileHandle.createFile(atPath: textFile, contents: nil, attributes: nil)
}
let fileWriter = FileHandle(forWritingAtPath: textFile)!

let proccessPhoto:(FlickrPhoto) -> () = { photo in
    if let image = NSImage(contentsOf: photo.photoUrl) {
        let finalImg = image.resizeMaintainingAspectRatio(withSize: NSSize(width: 232, height: 232))!
        let data = finalImg.tiffRepresentation!
        let uuid = UUID().uuidString
        try! data.write(to: URL(fileURLWithPath: "\(folder)/\(uuid).jpg"))
        
        
        fileWriter.seekToEndOfFile()
        fileWriter.write("\(uuid): \(photo.title) \n".data(using: .utf8)!)
        
    }
}

func createOperation(_ page:Int) -> Operation {
    return GenericOperation {  completion in
        FlickrProvider.fetchPhotosForSearchText(searchText: textSearch,page: page, onCompletion: { (error, photos) in
            guard error == nil,let fullPhotos = photos else{
                print(error.debugDescription)
                return
            }
            fullPhotos.forEach({ proccessPhoto($0) })
            completion()
        })
    }
}



for var i in 1..<3 {
    queue.addOperation(createOperation(i))
}

let obs = queue.observe(\OperationQueue.operationCount) { (queue, value) in
    print(" Opeartion number changed -> \(queue.operationCount)")
}



queue.waitUntilAllOperationsAreFinished()
obs.invalidate()
fileWriter.closeFile()

