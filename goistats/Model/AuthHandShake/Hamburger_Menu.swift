
import Foundation
 

public class Hamburger_Menu {
	public var name : String?
	public var action : String?
	public var name_key : String?

    public class func modelsFromDictionaryArray(array:NSArray) -> [Hamburger_Menu]
    {
        var models:[Hamburger_Menu] = []
        for item in array
        {
            models.append(Hamburger_Menu(dictionary: item as! NSDictionary)!)
        }
        return models
    }

	required public init?(dictionary: NSDictionary) {

		name = dictionary["name"] as? String
		action = dictionary["action"] as? String
		name_key = dictionary["name_key"] as? String
	}


	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.name, forKey: "name")
		dictionary.setValue(self.action, forKey: "action")
		dictionary.setValue(self.name_key, forKey: "name_key")

		return dictionary
	}

}
