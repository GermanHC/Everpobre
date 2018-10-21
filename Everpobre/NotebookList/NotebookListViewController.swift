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
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalLabel: UILabel!
    var managedContext: NSManagedObjectContext! // Beware to have a value before presenting the VC
    
    
//    var model: [deprecated_Notebook] = [] {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
//    var dataSource: [NSManagedObject] = []{
//        didSet {
//            tableView.reloadData()
//        }
//    }
//
    private var fetchedResultsController: NSFetchedResultsController<Notebook>!
    
    
//   {
//        do {
//            return try managedContext.fetch(Notebook.fetchRequest())
//        } catch let error as NSError {
//            print(error.localizedDescription)
//            return []
//        }
//    }
    
    private func getFetchedResultsController(with predicate: NSPredicate = NSPredicate(value: true)) -> NSFetchedResultsController<Notebook> {
        
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.predicate = predicate
        
        let sort = NSSortDescriptor( key: #keyPath(Notebook.creationDate), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        fetchRequest.fetchBatchSize = 20
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    private func setNewFetchedResultsController(_ newfrc: NSFetchedResultsController<Notebook>) {
        let oldfrc = fetchedResultsController
        if(newfrc != oldfrc) {
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
    
    override func viewDidLoad() {
//        model = deprecated_Notebook.dummyNotebookModel
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        super.viewDidLoad()
        
        configureSearchController()
        //reloadView()
        showAll()
    }
    
    private func configureSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Notebook"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
    
//    private func reloadView() {
//
//        do {
//            dataSource = try managedContext.fetch(Notebook.fetchRequest())
//        } catch let error as NSError {
//            print(error.localizedDescription)
//            dataSource = []
//        }
//
//        populateTotalLabel ()
//        tableView.reloadData()
//    }
    
    private func populateTotalLabel(with predicate: NSPredicate = NSPredicate(value: true)) {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Notebook")
        fetchRequest.resultType = .countResultType
        
        let predicate = NSPredicate(value: true)
        fetchRequest.predicate = predicate
        
        do  {
            let countResult = try managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            totalLabel.text = "\(count)"
        }catch let error as NSError{
            print("Count not fetch: \(error)")
        }
    }
    
    @IBAction func addNotebook(_ sender: UIBarButtonItem) {
        let alert = UIAlertController( title: "Nueo Notebook", message: "Añade un nuevo Notebook", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Grabar", style: .default) {[unowned self] action in
            guard
                let textField = alert.textFields?.first,
                let nameToSave = textField.text
            else {return}
        
            let notebook = Notebook(context: self.managedContext)
            notebook.name = nameToSave
            notebook.creationDate = NSDate()
        
            do {
                try self.managedContext.save()
            } catch let error as NSError {
                print("TODO Error handling: \(error.debugDescription)")
            }
        
            //self.tableView.reloadData()
            //self.reloadView()
            self.showAll()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource implementation
extension NotebookListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return dataSource.count //model.count
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0}
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotebookListCell", for: indexPath) as! NotebookListCell
        //let notebook = dataSource[indexPath.row] as! Notebook
        let notebook = fetchedResultsController.object(at: indexPath)
        
        //cell.configure(with: model[indexPath.row])
        cell.configure(with: notebook)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//                guard
//                    let notebookToRemove = dataSource[indexPath.row] as? Notebook,
//                    editingStyle == .delete
//                else { return }
        guard editingStyle == .delete else { return }
        
        let notebookToRemove = fetchedResultsController.object(at: indexPath)
        
        managedContext.delete(notebookToRemove)
        
        do {
            try managedContext.save()
            //tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        
        //tableView.reloadData()
        //reloadView()
        showAll()
    }
}

// MARK: - UITableViewDelegate implementation
extension NotebookListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let notebook = model[indexPath.row]
//        let notesListVC = NotesListViewController(notebook: notebook)
//        self.show(notesListVC, sender: nil)
        
       // let notebook = dataSource[indexPath.row] as! Notebook
        let notebook = fetchedResultsController.object(at: indexPath)
        
        let notesListVC = NotesListViewController(notebook: notebook, managedContext: managedContext)
        self.show(notesListVC, sender: nil)
        
    }
}

extension NotebookListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            // Mostramos resultados filtrados
            showFilteredResult(with: text)
        } else {
            // Mostramos todos los resultados
            showAll()
        }
    }
    
    private func showFilteredResult(with query: String) {
//        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
//        fetchRequest.resultType = .managedObjectResultType
//
//        let predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
//        fetchRequest.predicate = predicate
//
//        do {
//            dataSource = try managedContext.fetch(Notebook.fetchRequest())
//        } catch let error as NSError {
//            print("Could not fetch \(error)")
//            dataSource = []
//        }
//        populateTotalLabel(with: predicate)
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
        let frc = getFetchedResultsController(with: predicate)
        setNewFetchedResultsController(frc)
        
        populateTotalLabel(with: predicate)
    }
    
    private func showAll() {
//        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: Notebook.fetchRequest()) { [weak self] (result) in
//
//            guard let notebooks = result.finalResult else {
//                self?.dataSource = []
//                return
//
//            }
//            self?.dataSource = notebooks
//        }
//
//        do {
//            //dataSource = try managedContext.fetch(Notebook.fetchRequest())
//            try managedContext.execute(asyncFetchRequest)
//        } catch let error as NSError {
//            print("Could not fetch \(error)")
//            dataSource = []
//        }
        
        let frc = getFetchedResultsController()
        setNewFetchedResultsController(frc)
        //fetchedResultsController.delegate = self
       
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        populateTotalLabel()
    }
}

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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
