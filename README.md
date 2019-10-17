# GTStorable

A protocol which provides standard file operations for types conforming to Codable protocol.

## Overview

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

Data can be encoded and saved to files in three formats currently: *JSON, Property List (plist) and Archived data*.

Read the [documentation](https://gtiapps.com/docs/gtstorable/index.html) for more information about the protocol's methods and the custom types used and supported. Alternatively see documentation on the code files under the Source directory.

## Integrating GTStorable

To integrate `GTStorable` into your projects follow the next steps:

1. Copy the repository URL to GitHub (it can by clicking on the *Clone or Download* button).
2. Open your project in Xcode.
3. Go to menu **File > Swift Packages > Add Package Dependency...**.
4. Paste the URL, select the package when it appears and click Next.
5. In the *Rules* leave the default option selected (*Up to Next Major*) and click Next.
6. Finally select the *GTStorable* package and select the *Target* to add to; click Finish.


## Usage Example

First, **import** `GTStorable` as a *module*:

```swift
import GTStorable
```

Consider the following struct which **adopts** the GTStorable protocol.

```swift
struct User: Codable, GTStorable {
    var username: String?
    var firstname: String?
    var age: Int?
    var isMale: Bool = true
}
```

Saving an instance of it to file as a JSON can be done like this:

```swift
do {
    _ = try user.save(as: .json, usingOptions: nil, customCoders: nil)
} catch { ... }

// The user.json file will be created.

```

Loading:

```swift
do {
    let loadedUser = try User.load(from: .json, forObjectOfType: User.self, usingOptions: nil, customCoders: nil)
} catch { ... }
```

You can even create a backup of the data file:

```swift
do {
    _ = try user.backupDataFile(ofType: .json, usingOptions: nil)
} catch { ... }

// user.json.bak is the backup file created.

```

Use the `storeOptions` parameter to specify subdirectories, custom file names and extensions, even to change the working folder. By default, all files are stored to Documents directory of the app.

Also, provide optionally customized JSON and Property List encoder and decoder instances in the `customCoders` parameter (wherever applicable) for overriding the default used settings. See the documentation for more information.

## License

GTStorable is provided under [MIT license](https://opensource.org/licenses/MIT).
