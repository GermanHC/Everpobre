//
//  NotebookListViewController.swift
//  Everpobre
//
//  Created by German Hernandez on 8/10/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//

import UIKit
import CoreData

class NotebookListViewController: UIViewController {
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!

    // MARK: Parameters
    
    var coreDataStack: CoreDataStack!
    
    private var fetchedResultsController: NSFetchedResultsController<Notebook>!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        //model = deprecated_Notebook.dummyNotebookModel
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        super.viewDidLoad()
        
        configureSearchController()
        showAll()
    }
    
    // MARK: NSFetchedResultsController helper methods
    
    private func getFetchedResultsController(with predicate: NSPredicate = NSPredicate(value: true)) -> NSFetchedResultsController<Notebook> {
        
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.predicate = predicate
        
        let sort = NSSortDescriptor(key: #keyPath(Notebook.creationDate), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        fetchRequest.fetchBatchSize = 20
        
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Notebook.creationDate),
            cacheName: nil)
    }
    
    private func setNewFetchedResultsController(_ newfrc: NSFetchedResultsController<Notebook>) {
        
        let oldfrc = fetchedResultsController
        if (newfrc != oldfrc) {
            fetchedResultsController = newfrc
            newfrc.delegate = self
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Could not fetch \(error)")
            }
            tableView.reloadData()
        }
    }
    
    // MARK: Helper methods
    
    private func configureSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Notebook"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
        
    private func populateTotalLabel(with predicate: NSPredicate = NSPredicate(value: true)) {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Notebook")
        fetchRequest.resultType = .countResultType
        
        fetchRequest.predicate = predicate
        
        do {
            let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            totalLabel.text = "\(count)"
        } catch let error as NSError {
            print("Count not fetch: \(error.description)")
        }
        
    }
    
    @IBAction func addNotebook(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Nuevo Notebook", message: "Añade un nuevo Notebbok", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Grabar", style: .default) { [unowned self] action in
            guard
                let textField = alert.textFields?.first,
                let nameToSave = textField.text
                else { return }
            
            let notebook = Notebook(context: self.coreDataStack.managedContext)
            notebook.name = nameToSave
            notebook.creationDate = NSDate()
            
            do {
                try self.coreDataStack.managedContext.save()
            } catch let error as NSError {
                print("TODO Error handling: \(error.debugDescription)")
            }
            
            self.showAll()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    private func noteBooksFetchRequest(from notebook: Notebook) -> NSFetchRequest<Notebook> {
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return fetchRequest
    }
    
    @IBAction func exportNoteBooks(_ sender: UIBarButtonItem) {
        exportCSV()
    }
    
    @objc private func exportCSV() {
        
        coreDataStack.storeContainer.performBackgroundTask { [unowned self] context in
            
            let fileName = "export.csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            
            var notebooks: [Notebook]? = []
            var csvString: String = ""
            
            notebooks = self.fetchedResultsController.fetchedObjects
            
            if (notebooks?.count)! > 0{
                for notebook in notebooks!
                {
                    var newLine = notebook.csv() + "\n"
                    csvString.append(contentsOf: newLine)
                    if notebook.notes?.count ?? 0 > 0{
                        for note in notebook.notes!
                        {
                            newLine = (note as! Note).csv() + "\n"
                            csvString.append(contentsOf: newLine)
                        }
                    }
                }
            }
            
            do {
                try csvString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.openInIBooks
                ]
                self.present(vc, animated: true, completion: nil)
            } catch {
                print("no hemos podido exportar el fichero csv")
                print("\(error)")
            }
        }
    }
}

// MARK:- UITableViewDataSource implementation

extension NotebookListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let section = fetchedResultsController.sections else { return 1 }
        return section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotebookListCell", for: indexPath) as! NotebookListCell
        let notebook = fetchedResultsController.object(at: indexPath)
        
        cell.configure(with: notebook)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let notebookToRemove = fetchedResultsController.object(at: indexPath)
        
        coreDataStack.managedContext.delete(notebookToRemove)
        
        do {
            try coreDataStack.managedContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        showAll()
    }
    
}

// MARK:- UITableViewDelegate implementation

extension NotebookListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notebook = fetchedResultsController.object(at: indexPath)
        
        let notesListVC = NewNotesListViewController(notebook: notebook, coreDataStack: coreDataStack)
        show(notesListVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
}

// MARK:- UISearchResultsUpdating implmentation

extension NotebookListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            //mostramos resultados filtrados
            showFilteredResults(with: text)
        } else {
            // Mostramos todos los resultadosas
            showAll()
        }
    }
    
    private func showFilteredResults(with query: String) {
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
        let frc = getFetchedResultsController(with: predicate)
        setNewFetchedResultsController(frc)
        
        populateTotalLabel(with: predicate)
        
    }
    
    private func showAll() {
       
        let frc = getFetchedResultsController()
        setNewFetchedResultsController(frc)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        
        populateTotalLabel()
    }
}

// MARK:- NSFetchedResultsControllerDelegate implementation

extension NotebookListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
