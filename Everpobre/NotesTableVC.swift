//
//  NotesTableVC.swift
//  Everpobre
//
//  Created by Miguel Dos Santos Carregal on 12/3/18.
//  Copyright © 2018 Miguel. All rights reserved.
//

import UIKit
import CoreData

class NotesTableVC: UITableViewController, NSFetchedResultsControllerDelegate {
    var noteList:[Note] = []
    var observer: NSObjectProtocol?
    var fetchedResultController: NSFetchedResultsController<Note>!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        //Fetch request.
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        //1.- Creamos el objecto
        let fetchRequest = NSFetchRequest<Note>()
        
        //2.- Que entidad es de la que queremos objeto.
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Note", in: viewMOC)
        
        //3.- (Opcional) Indicamos orden.
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate, sortByTitle]

        //4.- (Opcional) Filtrado
        let created24 = Date().timeIntervalSince1970 - 24 * 3600
        let predicate = NSPredicate(format: "createdAtTI >= %f", created24)
        fetchRequest.predicate = predicate
        
        /* Sin fetchedResultController
         //5.- Ejecutamos la request.
        try! noteList = viewMOC.fetch(fetchRequest)
        
        observer = NotificationCenter.default.addObserver(forName:Notification.Name.NSManagedObjectContextDidSave, object: nil, queue: OperationQueue.main, using: {( notification) in
                self.tableView.reloadData()
        })*/
        
        /* Con fetchedResultController */
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultController.performFetch()
        
        fetchedResultController.delegate = self
    }

    deinit {
        if let obs = observer
        {
            NotificationCenter.default.removeObserver(obs)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /* Sin fetchedResultController
        return noteList.count*/
        
        /* Con fetchedResultController */
        return fetchedResultController.sections![section].numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        /* Sin fetchedResultController
        cell?.textLabel?.text = noteList[indexPath.row].title*/
        
        /* Con fetchedResultController */
        cell?.textLabel?.text = fetchedResultController.object(at: indexPath).title
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteViewController = NoteVCByCode()
        /* Sin fetchedResultController
        noteViewController.note = noteList[indexPath.row]*/
        
        /* Con fetchedResultController */
        noteViewController.note = fetchedResultController.object(at: indexPath)
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    @objc func addNewNote()  {
        /* En el hilo principal
        //TRADICIONALMENTE.
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: DataManager.sharedManager.persistentContainer.viewContext) as! Note
        note.title = "Nueva nota"
        note.createdAtTI = Date().timeIntervalSince1970
        try! DataManager.sharedManager.persistentContainer.viewContext.save()
        
        noteList.append(note)
        tableView.reloadData()*/
        
        /* En un hilo secundario */
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        privateMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: DataManager.sharedManager.persistentContainer.viewContext) as! Note
            note.title = "Nueva nota"
            note.createdAtTI = Date().timeIntervalSince1970
            //try! DataManager.sharedManager.persistentContainer.viewContext.save()
            try! privateMOC.save()
            
            DispatchQueue.main.async {
                let noteinMainThread = DataManager.sharedManager.persistentContainer.viewContext.object(with: note.objectID) as! Note
                self.noteList.append(noteinMainThread)
                
                /* Con fetchedResultController ya el delegado actualiza */
                //self.tableView.reloadData()
            }
            
        }
    }
    
    @objc func updateInfo(){
        print("Evento de cambio de contexto detectado")
        tableView.reloadData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
