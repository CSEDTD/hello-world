/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A table view controller for displaying the entire contents of the database as a feed of colors.
*/

import UIKit
import CoreData

class FeedTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var server: Server!
    var fetchRequest: NSFetchRequest<FeedEntry>!
    
    private var fetchedResultsController: NSFetchedResultsController<FeedEntry>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // CSEDTD
        UNUserNotificationCenter.current().delegate = self
        globalNotificationManager = UNUserNotificationCenter.current()

        
        tableView.separatorStyle = .none
        
        if fetchRequest == nil {
            fetchRequest = FeedEntry.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FeedEntry.timestamp), ascending: false)]
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistentContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: String(describing: self))
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching results: \(error)")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.sections?.count ?? 0 > 0 {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? FeedEntryTableViewCell {
                configure(cell: cell, at: indexPath!)
            }
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        default:
            return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell",
                                                       for: indexPath) as? FeedEntryTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        configure(cell: cell, at: indexPath)
        return cell
    }

    func configure(cell: FeedEntryTableViewCell, at indexPath: IndexPath) {
        let feedEntry = fetchedResultsController.object(at: indexPath)
        cell.feedEntry = feedEntry
    }
        
    @IBAction private func fetchLatestEntries(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = Operations.getOperationsToFetchLatestEntries(using: context, server: server)
        operations.last?.completionBlock = {
            DispatchQueue.main.async {
                sender.endRefreshing()
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    @IBAction private func showActions(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.barButtonItem = sender
        
        alertController.addAction(UIAlertAction(title: "Reset Feed Data", style: .destructive, handler: { _ in
            PersistentContainer.shared.loadInitialData(onlyIfNeeded: false)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

// for foreground notification
extension FeedTableViewController: UNUserNotificationCenterDelegate {

    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.

        completionHandler([.alert, .badge, .sound])
    }

    // For handling tap and user actions
    // TODO
    /*
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
        case "stopRouting":
            workingAlarm.finished()
        default:
            break
        }
        completionHandler()
    }
 */

}

// TODO MUST 0623
func scheduleNotifications() {

    let content = UNMutableNotificationContent()
    let requestIdentifier = UUID().uuidString

    // TODO
    content.badge = 0
    content.sound = UNNotificationSound.default
    
    content.title = "백그라운드에서 뜨나요?"
    content.subtitle = ""
    content.body = ""
    content.categoryIdentifier = "simpleCategory"

    // If you want to attach any image to show in local notification
    /*
    let url = Bundle.main.url(forResource: "notificationImage", withExtension: ".jpg")
    do {
        let attachment = try? UNNotificationAttachment(identifier: requestIdentifier, url: url!, options: nil)
        content.attachments = [attachment!]
    }
     */

    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)

    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { (error:Error?) in

        if error != nil {
            print(error?.localizedDescription ?? "some unknown error")
        }
        print("Notification Register Success")
    }
}

// TODO
func registerForRichNotifications() {

   UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
        if error != nil {
            print(error?.localizedDescription)
        }
        if granted {
            print("Permission granted")
        } else {
            print("Permission not granted")
        }
    }

    //actions defination
    let stopRouting = UNNotificationAction(identifier: "stopRouting", title: "이동 중지", options: [.foreground])

    let actionCategory = UNNotificationCategory(identifier: "actionCategory", actions: [stopRouting], intentIdentifiers: [], options: [])
    
    let simpleCategory = UNNotificationCategory(identifier: "simpleCategory", actions: [], intentIdentifiers: [], options: [])

    UNUserNotificationCenter.current().setNotificationCategories([actionCategory, simpleCategory])

}


var globalNotificationManager = UNUserNotificationCenter.current()
