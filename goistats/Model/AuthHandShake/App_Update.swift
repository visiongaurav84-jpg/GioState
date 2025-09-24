
import Foundation
 

public class App_Update {
	public var last_update : String?
	public var app_version_ios : String?
    public var download_url : String?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let app_Update_list = App_Update.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of App_Update Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [App_Update]
    {
        var models:[App_Update] = []
        for item in array
        {
            models.append(App_Update(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let app_Update = App_Update(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: App_Update Instance.
*/
	required public init?(dictionary: NSDictionary) {

		last_update = dictionary["last_update"] as? String
		app_version_ios = dictionary["app_version_ios"] as? String
        download_url = dictionary["download_url"] as? String
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.last_update, forKey: "last_update")
		dictionary.setValue(self.app_version_ios, forKey: "app_version_ios")
        dictionary.setValue(self.download_url, forKey: "download_url")

		return dictionary
	}

}
