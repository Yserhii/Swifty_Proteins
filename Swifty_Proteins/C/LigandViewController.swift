//
//  LigandViewController.swift
//  Swifty_Proteins
//
//  Created by Yolankyi SERHII on 9/3/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit
import SceneKit

class LigandViewController: UIViewController {

    var infoLigan: [String : [[String : String]]] = [:]
    private var allAtoms: [SCNNode] = []
    private var allHydrogen: [SCNNode] = []
    private let cameraNode = SCNNode()
    private var name: String = ""
    private var positionCamera: SCNVector3 = SCNVector3Make(0, 0, 0)
    private let alertController = AlertController()
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var imageLigan: UIImageView!
    
    //Sharing model
    @IBAction func sharingButtom(_ sender: UIBarButtonItem) {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img = image {
            let shareObject = [img] as [UIImage]
            let activityController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
            activityController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    @IBAction func showImageLigan(_ sender: UIButton) {
            imageLigan.isHidden = !imageLigan.isHidden
    }
    
    //Hidden Off or On for Hydrogen
    @IBAction func hydrogensHidden(_ sender: UIButton) {
        for node in allHydrogen {
            node.isHidden = !node.isHidden
        }
    }

    //Swow message with name Atom when click on Atom
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first?.location(in: sceneView)
        let hit = sceneView.hitTest(touchLocation!, options: nil)
        cameraNode.position = positionCamera
        if hit.isEmpty == false {
            let node = hit[0].node
            if node.name != nil {
                cameraNode.position = node.position
                cameraNode.position.z = cameraNode.position.z + 3
                alertController.showMessage(message: "Atom: \(node.name ?? "")", view: self.view)
            }
        }
    }
    
    // dd in sceneView scene and all Nodes
    func addSceneViewAndDrowLigand() {
        // Settings sceneView
        self.sceneView.backgroundColor = .black
        self.sceneView.allowsCameraControl = true
        self.sceneView.autoenablesDefaultLighting = true
        //Add scene
        self.sceneView.scene = SCNScene()
        // Parsing mun nodes and num links
        let numNode: Int = Int(infoLigan["num"]?[0]["nodes"] ?? "") ?? 0
        let numLink: Int = Int(infoLigan["num"]?[0]["links"] ?? "") ?? 0
        //Add nodes with Atom and Link between atom
        addAllAtom(numNode: numNode)
        addAllLinkBetweenAtom(numLink: numLink)
        //Add camere in cneneView
        cameraNode.camera = SCNCamera()
        cameraNode.position = positionCamera
        sceneView.scene?.rootNode.addChildNode(cameraNode)
    }
    
    func getImage() {
        imageLigan.isHidden = true
        if let image = URL(string: "http://cdn.rcsb.org/etl/ligand/img/\(self.name.first!)/\(self.name)/\(self.name)-large.png") {
            if let isImage = try? Data(contentsOf: image) {
                DispatchQueue.main.async {
                    self.imageLigan.image = UIImage(data: isImage)
                    self.imageLigan.contentMode = .scaleAspectFit
                    return
                }
            }
        } else {
            self.present(alertController.alertController("No chart"), animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name = String(infoLigan["name"]?[0]["nodename"] ?? "")
        self.navigationItem.title = name
        addSceneViewAndDrowLigand()
        getImage()
    }
    
}

//Extension with adding elements in sceneView
extension LigandViewController {
    
    func twoLink(positionOne: SCNVector3, positionTwo: SCNVector3, colorOne: Any, colorTwo: Any, pointOne: Int, pointTwo: Int) {
        //Create vector and move tow bond on it
        let vectroСoefMove = SCNVector3Make(0.07, 0.07, 0.07)
        let oneOne = SCNVector3(simd_float3(positionOne) + simd_float3(vectroСoefMove))
        let oneTwo = SCNVector3(simd_float3(positionTwo) + simd_float3(vectroСoefMove))
        let twoOne = SCNVector3(simd_float3(positionOne) - simd_float3(vectroСoefMove))
        let twoTwo = SCNVector3(simd_float3(positionTwo) - simd_float3(vectroСoefMove))
        //Center between atoms for frist bond between atoms
        let positionCenter1 = SCNVector3((simd_float3(oneOne) + simd_float3(oneTwo)) / 2)
        //Create cylinder from 1 point to center for frist bond between atoms
        let linkFromOneToCenter1 = SCNNode()
        self.sceneView.scene!.rootNode.addChildNode(linkFromOneToCenter1.buildLineInTwoPointsWithRotation(
            from: oneOne, to: positionCenter1, radius: 0.05, color: colorOne as! UIColor))
        //Create cylinder from 2 point to center for frist bond between atoms
        let linkFromTwoToCenter1 = SCNNode()
        self.sceneView.scene!.rootNode.addChildNode(linkFromTwoToCenter1.buildLineInTwoPointsWithRotation(
            from: positionCenter1, to: oneTwo, radius: 0.05, color: colorTwo as! UIColor))
        //Center between atoms for second bond between atoms
        let positionCenter2 = SCNVector3((simd_float3(twoOne) + simd_float3(twoTwo)) / 2)
        //Create cylinder from 1 point to center for second bond between atoms
        let linkFromOneToCenter2 = SCNNode()
        self.sceneView.scene!.rootNode.addChildNode(linkFromOneToCenter2.buildLineInTwoPointsWithRotation(
            from: twoOne, to: positionCenter2, radius: 0.05, color: colorOne as! UIColor))
        //Create cylinder from 2 point to center for second bond between atoms
        let linkFromTwoToCenter2 = SCNNode()
        self.sceneView.scene!.rootNode.addChildNode(linkFromTwoToCenter2.buildLineInTwoPointsWithRotation(
            from: positionCenter2, to: twoTwo, radius: 0.05, color: colorTwo as! UIColor))
        //Add in array "allHydrogen"Linls with Hydrogen
        if self.allAtoms[pointOne - 1].name == "H" || self.allAtoms[pointTwo - 1].name == "H" {
            allHydrogen.append(linkFromOneToCenter1)
            allHydrogen.append(linkFromTwoToCenter1)
            allHydrogen.append(linkFromOneToCenter2)
            allHydrogen.append(linkFromTwoToCenter2)
        }
    }
    
    func oneLink(positionOne: SCNVector3, positionTwo: SCNVector3, colorOne: Any, colorTwo: Any, pointOne: Int, pointTwo: Int) {
        //Center between atoms
        let positionCenter = SCNVector3((simd_float3(positionOne) + simd_float3(positionTwo)) / 2)
        //Create cylinder from 1 point to center
        let linkFromOneToCenter = SCNNode()
        self.sceneView.scene!.rootNode.addChildNode(linkFromOneToCenter.buildLineInTwoPointsWithRotation(
            from: positionOne, to: positionCenter, radius: 0.1, color: colorOne as! UIColor))
        //Create cylinder from 2 point to center
        let linkFromTwoToCenter = SCNNode()
        self.sceneView.scene!.rootNode.addChildNode(linkFromTwoToCenter.buildLineInTwoPointsWithRotation(
            from: positionCenter, to: positionTwo, radius: 0.1, color: colorTwo as! UIColor))
        //Add in array "allHydrogen"Linls with Hydrogen
        if self.allAtoms[pointOne - 1].name == "H" || self.allAtoms[pointTwo - 1].name == "H" {
            allHydrogen.append(linkFromOneToCenter)
            allHydrogen.append(linkFromTwoToCenter)
        }
    }
    
    func addAllLinkBetweenAtom(numLink: Int) {
        for index in 0..<numLink {
            //Parsing Num 1 and 2 atom
            let pointOne = Int(self.infoLigan["link"]?[index]["first"] ?? "") ?? 0
            let pointTwo = Int(self.infoLigan["link"]?[index]["second"] ?? "") ?? 0
            // Get informations about coordinateы and colors 1 and 2  Atom, calculate center between Atoms
            let positionOne = self.allAtoms[pointOne - 1].position
            let positionTwo  = self.allAtoms[pointTwo - 1].position
            let colorOne = self.allAtoms[pointOne - 1].geometry?.firstMaterial?.diffuse.contents ?? #colorLiteral(red: 0.8680813909, green: 0.4645460248, blue: 1, alpha: 1)
            let colorTwo = self.allAtoms[pointTwo - 1].geometry?.firstMaterial?.diffuse.contents ?? #colorLiteral(red: 0.8680813909, green: 0.4645460248, blue: 1, alpha: 1)
            //Bond between atoms
            let numLink = Int(self.infoLigan["link"]?[index]["link"] ?? "") ?? 0
            if numLink == 2 {
                twoLink(positionOne: positionOne, positionTwo: positionTwo,
                        colorOne: colorOne, colorTwo: colorTwo,
                        pointOne: pointOne, pointTwo: pointTwo)
            } else  {
                oneLink(positionOne: positionOne,positionTwo: positionTwo,
                        colorOne: colorOne, colorTwo: colorTwo,
                        pointOne: pointOne, pointTwo: pointTwo)
            }
        }
    }
    
    func addAllAtom(numNode: Int) {
        for index in 0..<numNode {
            // Parsing coordinate for One Node and collor
            let x = Double(infoLigan["node"]?[index]["x"] ?? "") ?? 0.0
            let y = Double(infoLigan["node"]?[index]["y"] ?? "") ?? 0.0
            let z = Double(infoLigan["node"]?[index]["z"] ?? "") ?? 0.0
            let color = Colors[infoLigan["node"]?[index]["name"] ?? ""] ?? #colorLiteral(red: 0.8680813909, green: 0.4645460248, blue: 1, alpha: 1)
            let vectorNode = SCNVector3(x, y, z)
            //Add position for camera
            if index == 0 {
                self.positionCamera = SCNVector3(x, y, z + 35)
            }
            // Create sphere
            let sphereGeometry = SCNSphere(radius: 0.30)
            // Create node
            let sphereNode = SCNNode(geometry: sphereGeometry)
            sphereNode.name = infoLigan["node"]?[index]["name"] ?? ""
            sphereNode.position = vectorNode
            sphereGeometry.firstMaterial?.diffuse.contents = color
            // Add in array "allHydrogen" Atoms with Hydrogen
            if sphereNode.name == "H" {
                allHydrogen.append(sphereNode)
            }
            //add node into scneView
            self.allAtoms.append(sphereNode)
            self.sceneView.scene!.rootNode.addChildNode(sphereNode)
        }
    }
}








