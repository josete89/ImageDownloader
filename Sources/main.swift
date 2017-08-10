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


let textSearch = "text_to_search"
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


struct UrlImages:Codable{
    let url:String?
}

let fileUrl = URL(fileURLWithPath: "")
let data = try! Data(contentsOf: fileUrl)
let json = try! JSONDecoder().decode([UrlImages].self, from: data)

let ops:[GenericOperation] = json.flatMap({ urlImage in
    
    guard let imageUrl = urlImage.url,let url = URL(string: imageUrl) else {
        return nil;
    }
    
    return GenericOperation {  completion in
        if let image = NSImage(contentsOf: url) {
            let finalImg = image.resizeMaintainingAspectRatio(withSize: NSSize(width: 232, height: 232))!
            let data = finalImg.tiffRepresentation!
            let uuid = UUID().uuidString
            let title = url.deletingPathExtension().lastPathComponent
            let disallowedChars = CharacterSet.urlPathAllowed.inverted
            let fileName = title.components(separatedBy: disallowedChars).joined(separator: " ")
            
            try! data.write(to: URL(fileURLWithPath: "\(folder)/\(uuid).jpg"))
            
            
            fileWriter.seekToEndOfFile()
            fileWriter.write("\(uuid): \(fileName) \n".data(using: .utf8)!)
            
        }
        completion()
    }
})

queue.addOperations(ops, waitUntilFinished: true)

// ########################### FLICKR ########################
if (false){
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
}
// ########################### FLICKR ########################


let obs = queue.observe(\OperationQueue.operationCount) { (queue, value) in
    print(" Opeartion number changed -> \(queue.operationCount)")
}



queue.waitUntilAllOperationsAreFinished()
obs.invalidate()
fileWriter.closeFile()

