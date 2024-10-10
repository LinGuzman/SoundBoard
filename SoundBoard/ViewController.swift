//
//  ViewController.swift
//  SoundBoard
//
//  Created by Lin Abigail Guzman Gutierrez on 9/10/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    

    
    @IBOutlet var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            grabaciones = try
            context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        }catch{}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        let grabacion = grabaciones[indexPath.row]
//        cell.textLabel?.text = grabacion.nombre
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let grabacion = grabaciones[indexPath.row]
       
        // Configurar el reproductor de audio temporal para obtener la duración
        do {
            let audioPlayer = try AVAudioPlayer(data: grabacion.audio! as Data)
            let duracion = audioPlayer.duration
           
            let minutos = Int(duracion) / 60
            let segundos = Int(duracion) % 60
            cell.textLabel?.text = "\(grabacion.nombre ?? "Grabación") - \(String(format: "%02d:%02d", minutos, segundos))"
        } catch {
            cell.textLabel?.text = grabacion.nombre
        }
       
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do{
            reproducirAudio = try AVAudioPlayer(data:grabacion.audio! as Data)
            reproducirAudio?.play()
        }catch{}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let grabacion = grabaciones[indexPath.row]
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                
                tablaGrabaciones.reloadData()
            } catch {
                
                print("Error al obtener las grabaciones actualizadas: \(error)")
            }
        }
    }



}

