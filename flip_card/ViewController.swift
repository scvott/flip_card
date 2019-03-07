//
//  ViewController.swift
//  flip_card
//
//  Created by Lin Scott on 11/28/18.
//  Copyright © 2018 Scott Lin. All rights reserved.
//

import UIKit
import GameKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        let flakeEmitterCell = CAEmitterCell()
        flakeEmitterCell.contents = UIImage(named: "snowFlake")?.cgImage
        flakeEmitterCell.scale = 0.06       //控制雪花的大小
        flakeEmitterCell.scaleRange = 0.4
        flakeEmitterCell.emissionRange = .pi
        flakeEmitterCell.lifetime = 20.0    //維持的秒數
        flakeEmitterCell.birthRate = 40     //每秒出現幾個雪花
        flakeEmitterCell.velocity = -30
        flakeEmitterCell.velocityRange = -20
        flakeEmitterCell.yAcceleration = 30
        flakeEmitterCell.xAcceleration = 5
        flakeEmitterCell.spin = -0.5        //轉動
        flakeEmitterCell.spinRange = 1.0
        
        let snowEmitterLayer = CAEmitterLayer()
        //雪花的路徑
        snowEmitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2.0, y: -50)
        snowEmitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 0)
        snowEmitterLayer.emitterShape = CAEmitterLayerEmitterShape.line//可控制雪花從哪裡發射，有各種不同的形狀可選擇
        snowEmitterLayer.beginTime = CACurrentMediaTime()
        snowEmitterLayer.timeOffset = 10
        snowEmitterLayer.emitterCells = [flakeEmitterCell]
        
        view.layer.addSublayer(snowEmitterLayer)
    }
    
    
    
    
    
}

