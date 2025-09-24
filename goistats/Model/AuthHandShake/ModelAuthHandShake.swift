import Foundation
 

public class ModelAuthHandShake {
	public var token : String?
	public var statusCode : String?
	public var hamburger_Menu : Array<Hamburger_Menu>?
	public var app_Update : App_Update?


    public class func modelsFromDictionaryArray(array:NSArray) -> [ModelAuthHandShake]
    {
        var models:[ModelAuthHandShake] = []
        for item in array
        {
            models.append(ModelAuthHandShake(dictionary: item as! NSDictionary)!)
        }
        return models
    }

	required public init?(dictionary: NSDictionary) {

		token = dictionary["Token"] as? String
		statusCode = dictionary["statusCode"] as? String
        if (dictionary["Hamburger_Menu"] != nil) { hamburger_Menu = Hamburger_Menu.modelsFromDictionaryArray(array: dictionary["Hamburger_Menu"] as! NSArray) }
		if (dictionary["App_Update"] != nil) { app_Update = App_Update(dictionary: dictionary["App_Update"] as! NSDictionary) }
	}

		
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.token, forKey: "Token")
		dictionary.setValue(self.statusCode, forKey: "statusCode")
		dictionary.setValue(self.app_Update?.dictionaryRepresentation(), forKey: "App_Update")

		return dictionary
	}

}
