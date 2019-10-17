//
//  GTStorable.swift
//  GTStorable
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

// MARK: - GTStorable

/**
 It provides standard file operations for types conforming to Codable protocol.
 
 `GTStorable` protocol provides the following operations:
 
 * Saving to file.
 * Loading from file.
 * Removing data file.
 * Checking for data file existence.
 * Creating data file backup.
 * Removing data file backup.
 
 ### Available API
 
 * `save(as:usingOptions:customCoders:)`
 * `load(from:forObjectOfType:usingOptions:customCoders:)`
 * `remove(fileOfType:usingOptions:)`
 * `dataFileExists(ofType:withOptions:)`
 * `backupDataFile(ofType:usingOptions:)`
 * `removeBackupFile(ofType:usingOptions:)`
 
 See the `GTStorableToolkit.FileType` enum for supported file types.
 
 Whenever options parameter is required a `GTStorableToolkit.StoreOptions`
 can be optionally provided as an argument.
 
 `customCoders` is an optional `GTStorableToolkit.CustomCoders` object. Use
 it to specify customized JSON and Property List encoders and decoders when necessary.
 
 Read more at the documentation of the previously mentioned custom types.
 */
public protocol GTStorable {
    func save(as fileType: GTStorableToolkit.FileType, usingOptions storeOptions: GTStorableToolkit.StoreOptions?, customCoders: GTStorableToolkit.CustomCoders?) throws -> Bool
    static func load<T>(from fileType: GTStorableToolkit.FileType, forObjectOfType objectType: T.Type, usingOptions storeOptions: GTStorableToolkit.StoreOptions?, customCoders: GTStorableToolkit.CustomCoders?) throws -> T? where T: Decodable
    func remove(fileOfType fileType: GTStorableToolkit.FileType, usingOptions storeOptions: GTStorableToolkit.StoreOptions?) throws -> Bool
    func dataFileExists(ofType fileType: GTStorableToolkit.FileType, withOptions storeOptions: GTStorableToolkit.StoreOptions?) throws -> Bool
    func backupDataFile(ofType fileType: GTStorableToolkit.FileType, usingOptions storeOptions: GTStorableToolkit.StoreOptions?) throws -> Bool
    func removeBackupFile(ofType fileType: GTStorableToolkit.FileType, usingOptions storeOptions: GTStorableToolkit.StoreOptions?) throws -> Bool
}



extension GTStorable where Self: Codable {
    /**
     It saves current instance (`self`) to file using the specified file type, using
     optionally additional provided data regarding the path and the file, as well as
     the encoder to be used.
     
     Use the `fileType` parameter to specify the type of file that should be created.
     See `GTStorableToolkit.FileType` enum for available values.
     
     Use the `storeOptions` parameter to provide additional data regarding the path
     and the file that will be created. If `nil` is passed as an argument, the
     target directory is the `documents directory`, while the type of the current
     instance (`self` type) will be used as the file name. Default extension depends
     on the specified file type. Override any of those by passing an initialized
     `GTStorableToolkit.StoreOptions` argument where you assign values to properties
     that should be overriden.
     
     - Parameter fileType: The file type to use for saving the file. See
     `GTStorableToolkit.FileType` for more details. This value specifies the default
     extension of the file.
     - Parameter storeOptions: A `GTStorableToolkit.StoreOptions` object which can be
     used to specify directories, subdirectories, custom file names and extension, and more.
     - Parameter customCoders: Use it in case you want to override the default encoder objects
     that will be used to encode `self`. Pass an initialized `GTStorableToolkit.CustomCoders`
     object with the proper customized encoder.
     - Returns: `true` on success.
     - Throws: It propagates any errors thrown by the system regarding the operations taking place
     in the entire process.
    */
    public func save(as fileType: GTStorableToolkit.FileType,
                     usingOptions storeOptions: GTStorableToolkit.StoreOptions?,
                     customCoders: GTStorableToolkit.CustomCoders?) throws -> Bool {
        
        let helper = GTStorableHelper()
        var data: Data?
        switch fileType {
        case .json: data = try helper.jsonEncode(object: self, customCoders: customCoders)
        case .plist: data = try helper.plistEncode(object: self, customCoders: customCoders)
        case .archive: data = try helper.archive(object: self)
        }
        
        let url = try helper.getURL(usingOptions: storeOptions, for: fileType, objectType: Self.self)
        return try helper.write(data: data, to: url)
    }
    
    
    /**
     It loads, decodes and returns an object of the given type previously encoded
     and saved to a file.
     
     The provided `fileType` value must match to the file type that was used to
     save the file. For example, if "json" file type was used to encode and save,
     then "json" should be used again for loading and decoding data from the file. If
     no custom extension is specified, the file type defines the extension of the file.
     
     `self` type is used as the file name to use by default, and the *documents directory*
     as the target directory. Provide custom directories, subdirectories, file name and
     extension by initializing and passing a `GTStorableToolkit.StoreOptions` object.
     
     To override default JSON and Property List decoders, initialize a
     `GTStorableToolkit.CustomCoders` object with a customized decoder as needed, and
     pass it as the `customCoders` argument.
     
     On success this method initializes an object of the `objectType` type. It's a static
     method so there's no need to use an instance of the custom type for using it.
     
     - Parameter fileType: The file type to use. See
     `GTStorableToolkit.FileType` for more details.
     - Parameter objectType: The custom type to decode the loaded data to.
     - Parameter storeOptions: A `GTStorableToolkit.StoreOptions` object which can be
     used to specify directories, subdirectories, custom file names and extension, and more.
     - Parameter customCoders: Use it to provide customized decoder objects. See
     `GTStorableToolkit.CustomCoders`.
     - Returns: An initialized object of the given custom type.
     - Throws: It propagates any errors thrown by the system regarding the operations taking place
     in the entire process.
    */
    public static func load<T>(from fileType: GTStorableToolkit.FileType, forObjectOfType objectType: T.Type, usingOptions storeOptions: GTStorableToolkit.StoreOptions?, customCoders: GTStorableToolkit.CustomCoders?) throws -> T? where T: Decodable {
        let helper = GTStorableHelper()
        let url = try helper.getURL(usingOptions: storeOptions, for: fileType, objectType: Self.self)
        if let data = try helper.loadData(from: url) {
            switch fileType {
            case .json: return try helper.jsonDecode(using: data, objectType: Self.self, customCoders: customCoders) as? T
            case .plist: return try helper.plistDecode(using: data, objectType: Self.self, customCoders: customCoders) as? T
            case .archive: return try helper.unarchive(using: data, objectType: Self.self) as? T
            }
        }
        
        return nil
    }
    
    
    /**
     It removes a previously stored data file of `self` using the given file type
     and optionally custom store options.
     
     - Parameter fileType: The file type originally used to save `self` to file.
     - Parameter storeOptions: A `GTStorableToolkit.StoreOptions` object which can be
     used to customize the path, file name and extension, and more.
     - Returns: `true` on successful removal of the file.
     - Throws: Any errors thrown by the system while trying to remove the file.
    */
    public func remove(fileOfType fileType: GTStorableToolkit.FileType, usingOptions storeOptions: GTStorableToolkit.StoreOptions?) throws -> Bool {
        let helper = GTStorableHelper()
        return try helper.removeFile(at: helper.getURL(usingOptions: storeOptions, for: fileType, objectType: Self.self))
    }
    
    
    /**
     It checks if a data file of `self` for the given file type and optionally
     custom store options exists or not.
     
     - Parameter fileType: The file type originally used to save `self` to file.
     - Parameter storeOptions: A `GTStorableToolkit.StoreOptions` object which can be
     used to customize the path, file name and extension, and more.
     - Returns: `true` if the file exists.
     - Throws: Any errors thrown by the system while trying to check for file existence.
    */
    public func dataFileExists(ofType fileType: GTStorableToolkit.FileType, withOptions storeOptions: GTStorableToolkit.StoreOptions?) throws -> Bool {
        let helper = GTStorableHelper()
        return try helper.fileExists(at: helper.getURL(usingOptions: storeOptions, for: fileType, objectType: Self.self))
    }
    
    
    /**
     It creates a backup of a data file of `self` for the given file type and
     optionally using the given store options.
     
     The method creates a copy of the data file specified by the file type and
     appends the *"bak"* extension to it. For example, a file named "data.json"
     becomes "data.json.bak".
     
     Data files created for different file types can have their own backups. So,
     "data.json.bak" can co-exist with "data.plist.bak" or other supported file
     types.
     
     Keep in mind that a backup file overwrites a previous one.
     
     - Warning: Do not provide a "bak" extension on your own, it will be appended
     automatically. Provide only all data necessary to specify the original data file.
     
     - Parameter fileType: The file type originally used to save `self` to file.
     - Parameter storeOptions: A `GTStorableToolkit.StoreOptions` object which can be
     used to customize the path, file name and extension, and more.
     - Returns: `true` if creating the backup file succeeds.
     - Throws: Any errors thrown by the system while trying to create the backup file.
    */
    public func backupDataFile(ofType fileType: GTStorableToolkit.FileType, usingOptions storeOptions: GTStorableToolkit.StoreOptions?) throws -> Bool {
        let helper = GTStorableHelper()
        return try helper.backupFile(at: helper.getURL(usingOptions: storeOptions, for: fileType, objectType: Self.self))
    }
    
    
    /**
     It deletes a backup file previously created for a data file of `self` using the
     given file type, and optionally any given store options.
     
     Make sure to provide all data necessary to specify the full path to the data
     file of the specified file type. The method automatically appends the *"bak"*
     extension to the composed path.
     
     - Parameter fileType: The file type originally used to save `self` to file.
     - Parameter storeOptions: A `GTStorableToolkit.StoreOptions` object which can be
     used to customize the path, file name and extension, and more.
     - Returns: `true` if removing the backup file succeeds.
     - Throws: Any errors thrown by the system while trying to create the backup file.
    */
    public func removeBackupFile(ofType fileType: GTStorableToolkit.FileType, usingOptions storeOptions: GTStorableToolkit.StoreOptions?) throws -> Bool {
        let helper = GTStorableHelper()
        guard let url = try helper.getURL(usingOptions: storeOptions, for: fileType, objectType: Self.self) else { return false }
        return try helper.removeFile(at: url.appendingPathExtension("bak"))
    }
}
