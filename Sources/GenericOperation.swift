//
//  GenericOperation.swift
//  ImageDownloader
//
//  Created by Alcala, Jose Luis on 7/19/17.
//  Copyright © 2017 alcaljos. All rights reserved.
//

import Cocoa

final class GenericOperation: Operation {

    override var isAsynchronous: Bool {
        return true
    }
    
    private var _executing = false {
        willSet{
            willChangeValue(forKey:"isExecuting")
        }
        didSet{
            didChangeValue(forKey:"isExecuting")
        }
    }
    
    override var isExecuting:Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey:"isFinished")
        }
        
        didSet {
            didChangeValue(forKey:"isFinished")
        }
    }
    override var isFinished: Bool {
        return _finished
    }
    
    let operation:( @escaping()->() ) -> ()
    
    init(operation:@escaping ( @escaping ()->() ) -> ()) {
        self.operation = operation
    }
    
    override func start() {
        
        guard !self.isCancelled else {
            return
        }
        _executing = true
        
        let finalCallback = {
            self._executing = false
            self._finished = true
        }
        self.operation( finalCallback )
    }
    
    
}
