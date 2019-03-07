//
//  NormalMode.swift
//  flip_card
//
//  Created by Lin Scott on 11/28/18.
//  Copyright © 2018 Scott Lin. All rights reserved.
//

import UIKit
import GameKit
import os.log
class NormalMode: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var cardCollections: [UIButton]!
    @IBOutlet weak var flipCountLabel: UILabel!
    
    
    let face = [UIImage(named: "01"),UIImage(named: "02"),UIImage(named: "03"),UIImage(named: "04"),UIImage(named: "05"),UIImage(named: "06")]
    var faceChoicedArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameInit()
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
    
    
    var flipCount: Int = 0{
        didSet{
            flipCountLabel.text = "翻牌次數：\(flipCount)"
        }
    }
    
    struct MatchState{
        var ready = false
        var cardIdentifier: Int = 0
        var cardCollectionIndex: Int? = nil
        var timeoutHolding = false
    }
    var matchState = MatchState()
    
    
    @IBAction func touchCard(_ sender: UIButton) {
        
        if let cardIndex = cardCollections.index(of: sender), !cards[cardIndex].isMatch , !matchState.timeoutHolding{
            
            //是否是還沒翻過牌（兩次的第一次）
            if !matchState.ready{
                matchState.ready = true
                matchState.cardIdentifier = cards[cardIndex].identifier
                matchState.cardCollectionIndex = cardIndex
                flipCount += 1
            sender.setImage(cards[cardIndex].cardImage, for: .normal)
                UIView.transition(with: sender, duration: 0.2, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
            else{
                if let bindingIndex = matchState.cardCollectionIndex, bindingIndex != cardIndex{
                    
                    matchState.ready = false
                    flipCount += 1
                    //判斷是否相同
                    sender.setImage(cards[cardIndex].cardImage, for: .normal)
                    UIView.transition(with: sender, duration: 0.2, options: .transitionFlipFromRight, animations: nil, completion: nil)
                    
                    if matchState.cardIdentifier == cards[cardIndex].identifier{ //如果一樣
                        
                        viewCardChange(for: bindingIndex, withImage: matchImage, transFrom: .transitionFlipFromTop)
                        cards[bindingIndex].isMatch = true
                        viewCardChange(for: cardIndex, withImage: matchImage, transFrom: .transitionFlipFromTop)
                        cards[cardIndex].isMatch = true
                    }
                    else{
                        matchState.timeoutHolding = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.viewCardChange(for: bindingIndex, withImage: self.backImage, transFrom: .transitionFlipFromLeft)
                            self.viewCardChange(for: cardIndex, withImage: self.backImage, transFrom: .transitionFlipFromLeft)
                            self.matchState.timeoutHolding = false
                        }
                        
                    }
                }
            }
            
        }
    }
    
    func viewCardChange (for cardIndex: Int, withImage: UIImage, transFrom: UIView.AnimationOptions){
        
        cardCollections[cardIndex].setImage(withImage, for: .normal)
        UIView.transition(with: cardCollections[cardIndex], duration: 0.2, options: transFrom, animations: nil, completion: nil)
        
    }
    
    @IBOutlet weak var temp: UILabel!
    let backImage = UIImage(named: "cardback")!
    let matchImage = UIImage(named: "ok")!
    var cards = [Card]()
    
    struct Card{
        var cardImage: UIImage
        let identifier: Int
        var isMatch: Bool
    }
    
    func gameInit (){
        
        faceChoicedArray = [UIImage]()
        cards = [Card]()        //卡片圖案用陣列儲存
        choiceFace() //亂數取出圖案
        matchState.ready = false //比對歸零
        
        //將圖案分配給卡片
        for i in cardCollections.indices {
            let btn = cardCollections[i]
            let card = Card(cardImage: faceChoicedArray[i], identifier: face.index(of: faceChoicedArray[i])! , isMatch: false)
            
            cards.append(card)
            btn.setImage(backImage, for: .normal)
        }
        
        
    }
    
    //取出目前所有卡片二分之一的圖案
    func choiceFace(){
        let randomOfnums = GKShuffledDistribution(lowestValue: 0, highestValue: face.count - 1)
        let numberOfPairsOfCards = Int(cardCollections.count / 2)
        for _ in 0 ..< numberOfPairsOfCards{
            let index = randomOfnums.nextInt()
            if let faceX = face[index]{
                faceChoicedArray.append(faceX)
                faceChoicedArray.append(faceX)
            }
        }
        faceChoicedArray.shuffle()
    }
    
    @IBAction func resetBtn(_ sender: UIButton) {
        gameInit()
        flipCount = 0
    }
    
    //back button
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        if (cardCollections[0].currentImage == UIImage(named: "ok")){
            if (cardCollections[1].currentImage == UIImage(named: "ok")){
                if (cardCollections[2].currentImage == UIImage(named: "ok")){
                    if (cardCollections[3].currentImage == UIImage(named: "ok")){
                        if (cardCollections[4].currentImage == UIImage(named: "ok")){
                            if (cardCollections[5].currentImage == UIImage(named: "ok")){
                                if (cardCollections[6].currentImage == UIImage(named: "ok")){
                                    if (cardCollections[7].currentImage == UIImage(named: "ok")){
                                        if (cardCollections[8].currentImage == UIImage(named: "ok")){
                                            if (cardCollections[9].currentImage == UIImage(named: "ok")){
                                                if (cardCollections[10].currentImage == UIImage(named: "ok")){
                                                    dismiss(animated: true, completion: nil)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    @IBAction func HomeButton(_ sender: Any) {
        //回主頁面ㄝ，homepage 是主頁面的ＩＤ
        if let controller = storyboard?.instantiateViewController(withIdentifier: "homepage") {
            print(controller.storyboard ?? "nil")
            present(controller, animated: true, completion: nil)
        }
    }
    
    
}

extension Array{
    mutating func shuffle(){
        for _ in 0 ..< self.count {
            sort{(_,_) in arc4random() < arc4random()}
        }
    }
}
