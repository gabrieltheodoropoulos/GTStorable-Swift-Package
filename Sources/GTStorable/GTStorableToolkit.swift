//
//  GTStorableToolkit.swift
//  GTFileStorable
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Gabriel Theodoropoulos. All rights reserved.
//

//    MIT License
//
//    Copyright (c) 2019 Gabriel Theodoropoulos
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation

/**
 This class defines custom types which are being used along with the
 `GTStorable` protocol.
 */
public class GTStorableToolkit {
    
    /**
     Supported file types for saving objects conforming to `GTStorable`.
     */
    public enum FileType {
        /// Encode and save data as JSON.
        case json
        
        /// Encode and save data as a Property List (plist).
        case plist
        
        /// Encode and save data using the `NSKeyedArchiver` class.
        case archive
        
        
        /**
         It returns the file extension based on the current file type value.
         */
        public func fileExtension() -> String {
            return "\(self)"
        }
    }
    
    
    /**
     A convenient enumeration to specify a target directory.
     
     Supported values are `documents` and `caches`. To define subdirectories
     use instances of the `StoreOptions` struct.
     */
    public enum Directory {
        /// The documents directory of the app.
        case documents
        
        /// The caches directory of the app. Usually used for temporary files.
        case caches
        
        /**
         The URL to directory.
         */
        public func url() -> URL {
            return self == .documents ? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] : FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        }
    }
    
    
    /**
     Create instances of this struct and use its properties for providing additional
     data regarding paths and files that are managed through the `GTStorable` protocol.
     
     Instances of this protocol are usually passed as arguments to `GTStorable` methods.
     
     */
    public struct StoreOptions {
        /// The target directory to use. Default value is `documents directory`.
        public var directory: Directory = .documents
        
        /// One or more subdirectories to be appended to `directory`. Leave it
        /// `nil` if you don't want to use any.
        public var subDirectory: String?
        
        /// Set a custom file name for files managed by the `GTStorable` methods.
        ///
        /// By leaving it `nil` the type of the object adopting the `GTStorable`
        /// protocol is used as the default file name.
        public var customFilename: String?
        
        /// Specify a custom extension to files managed by the `GTStorable` methods.
        ///
        /// Leave it `nil` to have the file type specify the file extension automatically.
        public var customExtension: String?
        
        /// When `true` the subdirectories specified by the `subDirectory` property are
        /// being created automatically if they don't exist. Default value is `true`.
        public var createSubDir = true
        
        
        
        /**
         An empty initializer. Assign values to properties manually.
        */
        public init() { }
        
        
        /**
         Custom initializer which accepts the working directory only as an argument.
         */
        public init(withDirectory directory: Directory) {
            self.directory = directory
        }
        
        
        /**
         Custom initializer which accepts initial values for all properties as arguments.
         */
        public init(withDirectory directory: Directory, subDirectory: String? = nil, createDirIfNecessary: Bool, customFilename: String? = nil, customExtension: String? = nil) {
            self.directory = directory
            self.subDirectory = subDirectory
            self.createSubDir = createDirIfNecessary
            self.customFilename = customFilename
            self.customExtension = customExtension
        }
    }
    
    
    /**
     Use instances of this struct to pass customized JSON and Property List
     encoders and decoders to the various methods of the `GTStorable`
     protocol.
     */
    public struct CustomCoders {
        /// Initialize and customize a `JSONEncoder` object to be used
        /// for encoding items conforming to `GTStorable` protocol.
        public var jsonEncoder: JSONEncoder?
        
        /// Initialize and customize a `JSONDecoder` object to be used
        /// for decoding items conforming to `GTStorable` protocol.
        public var jsonDecoder: JSONDecoder?
        
        /// Initialize and customize a `PropertyListEncoder` object to be used
        /// for encoding items conforming to `GTStorable` protocol.
        public var plistEncoder: PropertyListEncoder?
        
        /// Initialize and customize a `PropertyListDecoder` object to be used
        /// for encoding items conforming to `GTStorable` protocol.
        public var plistDecoder: PropertyListDecoder?
    }
    
}
