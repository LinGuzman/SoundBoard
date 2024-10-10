//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Lin Abigail Guzman Gutierrez on 9/10/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    
    @IBOutlet weak var reproducirButton: UIButton!
    
    
    @IBOutlet weak var nombreTextFiled: UITextField!
    
    @IBOutlet weak var tiempo: UILabel!
   
    
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var volumen: UISlider!
    
    
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var grabarTimer: Timer?
    var tiempoGrabacion: Int = 0
    
    @objc func cambiarVolumen( sender: UISlider){
        reproducirAudio?.volume = sender.value
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        
        volumen.value = 0.5
        

    }
    func configurarGrabacion() {
        do {
            // Creando sesión de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)

            // Creando dirección para el archivo de audio
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!

            // Impresión de ruta donde se guardan los archivos
            print("***********************")
            print(audioURL!)
            print("***********************")

            // Crear opciones para el grabador de audio
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?

            // Crear el objeto de grabación de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            
            grabarTimer?.invalidate()
            grabarTimer=nil
        }else{
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            
            tiempoGrabacion = 0
            grabarTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempoGrabacion), userInfo: nil, repeats: true)
        }
    }
    
    
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio?.volume = volumen.value
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {
            print("mal")
        }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        
        let context = (UIApplication.shared.delegate as!
                       
            AppDelegate).persistentContainer.viewContext
        
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextFiled.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController (animated: true)
        }
    
    @objc func actualizarTiempoGrabacion() {
        tiempoGrabacion += 1
        let minutos = tiempoGrabacion / 60
        let segundos = tiempoGrabacion % 60
        tiempo.text = String(format: "%02d:%02d", minutos, segundos)
    }
    
    

}
