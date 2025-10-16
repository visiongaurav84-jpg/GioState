import UIKit
import CoreData
import IQKeyboardManagerSwift
import SVProgressHUD
import SDWebImage
import FAPanels
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var pendingNotification: (title: String, message: String)?
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupRootForCustomSplashVC()
        setupIQKeyboard()
        setupNavbarAppearance()
        setupSVProgressHUD()

        //Now GioStateDev Update the code 15 Oct 25....
        //Now GioStateDev Update the code 15 Oct 25....
        
        //Now GioStateDev Update the code 15 Oct 25....
        //Now GioStateDev Update the code 15 Oct 25....
        
        
        //Now GioStateDev Update the code 16 Oct 25....
        //Now GioStateDev Update the code 16 Oct 25....
        
        //Now GioStateDev Update the code 16 Oct 25....
        //Now GioStateDev Update the code 16 Oct 25....
        
        //Now GioStateDev Update the code 17 Oct 25....
        //Now GioStateDev Update the code 17 Oct 25....
        
        //Now GioStateDev Update the code 17 Oct 25....
        //Now GioStateDev Update the code 17 Oct 25....
        
        
//        setupRootForCustomSplashVC()
//        setupIQKeyboard()
//        setupNavbarAppearance()
//        setupSVProgressHUD()
        
        // Firebase config
        FirebaseApp.configure()
        
        // Notification delegates
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }
    
    // APNs token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token after APNs: \(error.localizedDescription)")
            } else if let token = token {
                print("FCM Token received:")
                
            }
        }
    }
    
    // FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        // print("FCM Registration Token: \(token)")
        
        // Subscribe to topic
        Messaging.messaging().subscribe(toTopic: "goistatsios") { error in
            if let error = error {
                print("Error subscribing to topic: \(error)")
            } else {
                // print("Successfully subscribed to topic: goistatsios")
            }
        }
    }
    
    // Background fetch / silent push
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //print("Push Notification Received (silent/background): \(userInfo)")
        handleNotificationPayload(userInfo: userInfo)
        completionHandler(.newData)
    }
    
    // Foreground notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        //print("Push Notification Received (foreground): \(userInfo)")
        handleNotificationPayload(userInfo: userInfo)
        completionHandler([.alert, .sound])
    }
    
    // User tapped notification (background / terminated)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("Push Notification Opened: \(userInfo)")
        handleNotificationPayload(userInfo: userInfo)
        completionHandler()
    }
    
    // MARK: - Common Push Handler
    private func handleNotificationPayload(userInfo: [AnyHashable : Any]) {
        var title = ""
        var message = ""
        
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any] {
            title = alert["title"] as? String ?? ""
            message = alert["body"] as? String ?? ""
        }
        
        // Fallback: Use UNNotificationContent values if available
        if title.isEmpty, let notifTitle = userInfo["title"] as? String {
            title = notifTitle
        }
        if message.isEmpty, let notifBody = userInfo["body"] as? String {
            message = notifBody
        }
        
        if let homeVC = getVisibleViewController() as? HomeVC {
            DispatchQueue.main.async {
                homeVC.showDialog(title: title, message: message)
            }
        } else {
            // HomeVC not visible yet → store it for later
            pendingNotification = (title, message)
            NotificationCenter.default.post(name: .pendingNotificationUpdated, object: nil)
        }
    }
    
    // MARK: - Get Current Controller
    private func getVisibleViewController(from vc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController)
        }
        if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController)
        }
        if let presented = vc?.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        return vc
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "goistats")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Custom Methods...
extension AppDelegate {
    
    fileprivate func setupIQKeyboard() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistance = 10
        IQKeyboardManager.shared.toolbarConfiguration.previousNextDisplayMode = .alwaysHide
    }
    
    fileprivate func setupSVProgressHUD() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
    }
    
    func setupRootVC() {
        let rootController = FAPanelController()
        rootController.leftPanelPosition = .front
        rootController.configs.resizeLeftPanel = true
        rootController.configs.leftPanelWidth = SideMenuWidth
        rootController.configs.canLeftSwipe = false
        rootController.center(TabBarVC.getInstance()).left(SideMenuVC.getInstance())
        let navController = UINavigationController(rootViewController: rootController)
        navController.navigationBar.isHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func setupRootForCustomSplashVC() {
        let rootController = FAPanelController()
        rootController.leftPanelPosition = .front
        rootController.configs.resizeLeftPanel = true
        rootController.configs.canLeftSwipe = false
        rootController.center(CustomSplashVC.getInstance())
        let navController = UINavigationController(rootViewController: rootController)
        navController.navigationBar.isHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func setupNavbarAppearance() {
        UINavigationBar.appearance().tintColor = .darkGray
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .highlighted)
    }
}
