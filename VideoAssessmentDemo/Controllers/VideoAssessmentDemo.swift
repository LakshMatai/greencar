//
//  VideoAssessmentDemo.swift
//  VideoAssessmentDemo
//
//  Created by Daniel Vershinin on 13/02/2019.
//  Copyright © 2019 Polarr, Inc. All rights reserved.
//

import UIKit
import PolarrFoundation

//This demo features open source CoreML model wrapped with Polarr's `NeuralModelDefinition` and Polarr's smart crop.
//Demo detects when video feed frames score is higher than a certain threshold and then provides a smart crop for a top level frame.
//This demo shows how to define your own `NeuralModelDefiniton` for an open source CoreML model and then use it with other models.
class VideoAssessmentDemo: CameraViewController {

    //Open source assessment model definition
    //Please see the `Model` folder for the model definition
    let emissions:[String:Int] = ["Jaguar":164,"Kia":137,"Hyundai":134,"Honda":133,"Mazda":126,"Opel":126,"Audi":126,"BMW":124,"Daimler":122,"Dacia":120,"Suzuki":120,"Volkswagen":117,"Ford":116,"Seat":116,"Fiat":116,"Skoda":115,"Nissan":113,"Toyota":108,"Renault":105,"Volvo":120,"Mercedes":120,"Benz":120,"Cruze":110,"Cadillac":150,"Rapid":115,"Mustang":123,"Jetta":100,"Camaro":145]
    
    let assessmentRunner = NeuralModelRunner(AssessmentModelDefinition.self)
    
    //Polarr smart crop model defintion
    //let smartCropRunner = NeuralModelRunner(SmartCropModelDefinition.self)
    
    //Queue to run both model runners and discard late results
    let queue : OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    ///View to display smart crop boundaries
    var smartCropBoundariesView : UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.yellow.cgColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = 3.0
        view.layer.masksToBounds = true
        view.layer.backgroundColor = UIColor.clear.cgColor
        return view
    }()
    
    ///View to display score of the image
    var assessmentScoreView : UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        view.textColor = UIColor.yellow
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(assessmentScoreView)
        self.view.addSubview(smartCropBoundariesView)
        
        assessmentScoreView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10.0).isActive = true
        assessmentScoreView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10.0).isActive = true
    }
    
    //Processing the input texture in a separate queue to discard late results
    override func processTexture(_ texture: MTLTexture, completion: @escaping (MTLTexture) -> Void) {
        //We are not doing anything to the texture so we just pass it through to be displayed.
        completion(texture)
        
        let operation = BlockOperation()
        operation.addExecutionBlock { [weak operation, weak self] in
            guard let theOperation = operation, theOperation.isCancelled == false else {
                return
            }
            
            guard let `self` = self else {
                return
            }
            
            //First getting the assessment result
            guard let carOutput = self.assessmentRunner.run(on: texture, parameters: [:]) else {
                return
            }
            
//            print(carOutput)
            //Showing score anyway
            self.displayScore(carOutput.0)
            
            //We need to make sure assessment score if more than 4
//            guard score > 4.5 else {
//                //Hiding crop if score is too low
//                self.hideCrop()
//                return
//            }
            
            //If we are here, score is pretty high to obtain crop. Let's do the crop and display the cropping view.
//            var smartCropParameters = SmartCropParameters()
//            smartCropParameters.aspectRatio = 0.0
//            smartCropParameters.size = self.contentRect.size
//
            //The runner will return the rectangle to display as a crop.
//            guard let rect = self.smartCropRunner.run(on: texture, parameters: smartCropParameters) else {
//                return
//            }
            
            //We need to update UI on the main thread to display the crop rectangle.
            //self.displayCrop(for: rect)
        }
        
        queue.cancelAllOperations()
        queue.addOperation(operation)
    }
    
    fileprivate func displayScore(_ score : String) {
        DispatchQueue.main.async {
            var flag=0
            var final=""
            print(score)
            for (model,em) in self.emissions{
                if model.contains(score) || score.contains(model){
                    flag=1
                    final=score+", CO2 emission: \(em) g/km"
                    break
                }
            if flag==0{
                final=score+", CO2 emission: 130 g/km"
            }
                
            }
            self.assessmentScoreView.text = "\(final)"
        }
    }
    
    fileprivate func hideCrop() {
        DispatchQueue.main.async {
            self.smartCropBoundariesView.isHidden = true
        }
    }
    
//    fileprivate func displayCrop(for rect : CGRect) {
//        DispatchQueue.main.async {
//            self.smartCropBoundariesView.isHidden = false
//            self.smartCropBoundariesView.frame = CGRect(x: self.contentRect.origin.x + rect.origin.x * self.contentRect.width,
//                                                    y: self.contentRect.origin.y + rect.origin.y * self.contentRect.height,
//                                                    width: rect.width * self.contentRect.width,
//                                                    height: rect.height * self.contentRect.height)
//        }
//    }
    
}

