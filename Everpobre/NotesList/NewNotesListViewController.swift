//
//  NewNotesListViewController.swift
//  Everpobre
//
//  Created by German Hernandez on 21/10/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class NewNotesListViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    let notebook: Notebook
    let coreDataStack: CoreDataStack!
    var notesLocation: [NoteLocation] = []
    let locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    
    var notes: [Note] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    let transition = Animator()
    
    // MARK: Init
    
    init(notebook: Notebook, coreDataStack: CoreDataStack) {
        self.notebook = notebook
        self.notes = (notebook.notes?.array as? [Note]) ?? []
        self.coreDataStack = coreDataStack
        super.init(nibName: "NewNotesListViewController", bundle: nil)
      
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocation()
        
        title = "Notas"
        self.view.backgroundColor = .white
        
        let nib = UINib(nibName: "NotesListCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "NotesListCollectionViewCell")
        
        collectionView.backgroundColor = .lightGray
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        let exportButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportCSV))
        
        self.navigationItem.rightBarButtonItems = [addButtonItem, exportButtonItem]
        loadNotesLocations()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.collectionView.isHidden = false
        case 1:
            self.collectionView.isHidden = true
        default:
            return
        }
    }
    
    // MARK: Helper methods
    private func configureLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    private func centerMap(){
        let actualPosition = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        let regionRadius: CLLocationDistance = 100000
        
        let region = MKCoordinateRegion(center: actualPosition, latitudinalMeters: regionRadius, longitudinalMeters: 100000)
        
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        
        loadNotesLocations()
    }
    
    private func loadNotesLocations()
    {
        for note in self.notes   {
            self.notesLocation.append(NoteLocation(note: note))
        }
    
    }
    
    @objc private func exportCSV() {
        
        coreDataStack.storeContainer.performBackgroundTask { [unowned self] context in
            
            var results: [Note] = []
            
            do {
                results = try self.coreDataStack.managedContext.fetch(self.notesFetchRequest(from: self.notebook))
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
            
            let exportPath = NSTemporaryDirectory() + "export.csv"
            let exportURL = URL(fileURLWithPath: exportPath)
            FileManager.default.createFile(atPath: exportPath, contents: Data(), attributes: nil)
            
            let fileHandle: FileHandle?
            do {
                fileHandle = try FileHandle(forWritingTo: exportURL)
            } catch let error as NSError {
                print(error.localizedDescription)
                fileHandle = nil
            }
            
            if let fileHandle = fileHandle {
                for note in results {
                    fileHandle.seekToEndOfFile()
                    guard let csvData = note.csv().data(using: .utf8, allowLossyConversion: false) else { return }
                    fileHandle.write(csvData)
                }
                
                fileHandle.closeFile()
                DispatchQueue.main.async { [weak self] in
                    self?.showExportFinishedAlert(exportPath)
                }
                
            } else {
                print("no podemos exportar la data")
            }
        }
        
    }
    
    private func showExportFinishedAlert(_ exportPath: String) {
        let message = "El archivo CSV se encuentra en \(exportPath)"
        let alertController = UIAlertController(title: "Exportacion terminada", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
    private func notesFetchRequest(from notebook: Notebook) -> NSFetchRequest<Note> {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return fetchRequest
    }
    
    @objc private func addNote() {
        let newNoteVC = NoteDetailsViewController(kind: .new(notebook: notebook), managedContext: coreDataStack.managedContext)
        newNoteVC.delegate = self
        let navVC = UINavigationController(rootViewController: newNoteVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
}

// MARK:- UICollectionViewDataSource

extension NewNotesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesListCollectionViewCell", for: indexPath) as! NotesListCollectionViewCell
        cell.configure(with: notes[indexPath.row])
        return cell
    }
    
}

// MARK:- UICollectionViewDelegate

extension NewNotesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = NoteDetailsViewController(kind: .existing(note: notes[indexPath.row]), managedContext: coreDataStack.managedContext)
        detailVC.delegate = self
      
        // custom animation
        let navVC = UINavigationController(rootViewController: detailVC)
        navVC.transitioningDelegate = self
        present(navVC, animated: true, completion: nil)
        
    }
}

// MARK:- UICollectionViewDelegateFlowLayout

extension NewNotesListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150)
    }
}

// MARK:- NoteDetailsViewControllerProtocol implementation

extension NewNotesListViewController: NoteDetailsViewControllerProtocol {
    func didSaveNote() {
        self.notes = (notebook.notes?.array as? [Note]) ?? []
    }
}

// MARK:- Custom Animation - UIViewControllerTransitioningDelegate

extension NewNotesListViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let indexPath = (collectionView.indexPathsForSelectedItems?.first!)!
        let cell = collectionView.cellForItem(at: indexPath)
        transition.originFrame = cell!.superview!.convert(cell!.frame, to: nil)
        
        transition.presenting = true
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

extension NewNotesListViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            centerMap()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("No se pudo conseguir la ubicación del usuario: \(error.localizedDescription)")
    }
}

extension NewNotesListViewController: MKMapViewDelegate {
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("Rendering")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        mapView.addAnnotations(notesLocation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "notesLocation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "notesLocation")
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.markerTintColor = .green
        annotationView?.titleVisibility = .visible
        annotationView?.subtitleVisibility = .adaptive
        
        return annotationView
    }
}
