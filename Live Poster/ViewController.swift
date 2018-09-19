//
//  ViewController.swift
//  Live Poster
//
//  Created by Erine Natnat on 9/18/18.
//  Copyright © 2018 Erine Natnat. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var movie:Movie?
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        fetchMovie(withIMDBId: BH6MovieId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) {
            configuration.trackingImages = trackedImages
            
            configuration.maximumNumberOfTrackedImages = 1
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let videoNode = SKVideoNode(fileNamed: "LivePoster.mp4")
            
            videoNode.play()
            
            let videoScene = SKScene(size: CGSize(width: 640, height: 268))
            
            videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
            
            videoNode.yScale = -1.0
            
            videoScene.addChild(videoNode)
            
            
            let plane = SCNPlane(width: 0.24, height: 0.135)
            
            plane.firstMaterial?.diffuse.contents = videoScene
            
            let planeNode = SCNNode(geometry: plane)
            let translateVector = SCNVector3Make(0, 0.06, -0.03)
            planeNode.localTranslate(by: translateVector)
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
            if let movie = movie {
                node.addChildNode(addText(withInfoFromMovie: movie))
            }
        }
        
        return node
    }
    
    func addText(withInfoFromMovie movie: Movie) -> SCNNode {
        let positionNode = SCNNode()
        let text = SCNText(string: movie.textInfo(), extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 0.8)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let fontSize = Float(0.03)
        positionNode.geometry = text
        positionNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        positionNode.eulerAngles.x = -.pi / 2
        positionNode.position = SCNVector3(-0.12,0.07,-0.08)
        return positionNode
    }
    
    func fetchMovie(withIMDBId id:String) {
        MovieModel.fetchDataForMovie(withId: id) { (data, response, error) in
                if error != nil {
                    print(error)
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    let movieDict = json as! NSDictionary
                    guard let title = movieDict["Title"] as? String else { return }
                    guard let releasedDateString = movieDict["Released"] as? String else { return }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "d MMM yyyy"
                    guard let releaseDate = dateFormatter.date(from: releasedDateString) else { return }
                    guard let ratingStr = movieDict["imdbRating"] as? String else { return }
                    guard let rating = Double(ratingStr) else { return }
                    
                    let movie = Movie()
                    movie.title = title
                    movie.releaseDate = releaseDate
                    movie.ratingIMDB = rating
                    self.movie = movie
                } catch let jsonError {
                    print("JSONERROR: \(jsonError)")
                }
        }
    }
}

