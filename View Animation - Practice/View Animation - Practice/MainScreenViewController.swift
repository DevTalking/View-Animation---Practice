//
//  MainScreenViewController.swift
//  View Animation - Practice
//
//  Created by JaceFu on 15/7/12.
//  Copyright © 2015年 DevTalking. All rights reserved.
//

import UIKit

enum RotateDirection: Int {
    case Positive = 1
    case Negative = -1
}

class MainScreenViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var landedOrDepatureTimeTopLabel: UILabel!
    @IBOutlet weak var landedOrDepatureBigArrowImageView: UIImageView!
    @IBOutlet weak var landedOrDepatureLabel: UILabel!
    @IBOutlet weak var landedOrDepatureTimeBottomLabel: UILabel!
    @IBOutlet weak var flightNo: UILabel!
    @IBOutlet weak var landedOrDepatureSmallArrowImageView: UIImageView!
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var rightLine: UIView!
    @IBOutlet weak var ternimalAndGateLabel: UILabel!
    @IBOutlet weak var sourcePlace: UILabel!
    @IBOutlet weak var targetPlace: UILabel!
    @IBOutlet weak var airplaneImageView: UIImageView!
    var airplaneImageViewOriginalCenter: CGPoint!
    
    lazy var flight: NSArray = {
        let path = NSBundle.mainBundle().pathForResource("Flight", ofType: "plist")
        return NSArray(contentsOfFile: path!)!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.numberOfPages = self.flight.count
        let flightItem = self.flight[self.pageControl.currentPage] as! NSDictionary
        self.backgroundImageView.image = UIImage(named: flightItem["bg"] as! String)
        if flightItem["flightStatus"] as! String == "LANDED" {
            self.leftLine.alpha = 0
            self.rightLine.alpha = 1
        } else {
            self.leftLine.alpha = 1
            self.rightLine.alpha = 0
        }
        self.airplaneImageViewOriginalCenter = self.airplaneImageView.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func swipeToRight(sender: AnyObject) {
        guard self.pageControl.currentPage < self.flight.count - 1 else {
            print("be guarded right")
            return
        }
        self.pageControl.currentPage++
        let flightItem = self.flight[self.pageControl.currentPage] as! NSDictionary
        self.animateView(flightItem)
    }

    @IBAction func swipeToLeft(sender: AnyObject) {
        guard self.pageControl.currentPage > 0 else {
            print("be guarded left")
            return
        }
        self.pageControl.currentPage--
        let flightItem = self.flight[self.pageControl.currentPage] as! NSDictionary
        self.animateView(flightItem)
    }
    
    // MARK: CustomMethod
    
    func animateView(flightItem: NSDictionary) {
        UIView.transitionWithView(self.backgroundImageView, duration: 2, options: .TransitionCrossDissolve, animations: {
            self.backgroundImageView.image = UIImage(named: flightItem["bg"] as! String)
        }, completion: nil)
        
        if flightItem["flightStatus"] as! String == "LANDED" {
            self.cubeAnimate(self.landedOrDepatureTimeTopLabel, flightInfo: flightItem["landTime"] as! String)
            self.cubeAnimate(self.landedOrDepatureBigArrowImageView, flightInfo: "landedArrowBig")
            self.rotateAnimate(RotateDirection.Positive.rawValue)
            UIView.animateWithDuration(1, animations: {
                self.leftLine.alpha = 0
            })
            UIView.animateWithDuration(1, delay: 1.0, options: [], animations: {
                self.rightLine.alpha = 1
            }, completion: nil)
            self.landOrDepatureBottomLabelAnimate("DEPATURED " + (flightItem["depatureTime"] as! String))
        } else {
            self.cubeAnimate(self.landedOrDepatureTimeTopLabel, flightInfo: flightItem["depatureTime"] as! String)
            self.cubeAnimate(self.landedOrDepatureBigArrowImageView, flightInfo: "depatureArrowBig")
            self.rotateAnimate(RotateDirection.Negative.rawValue)
            UIView.animateWithDuration(1, animations: {
                self.rightLine.alpha = 0
            })
            UIView.animateWithDuration(1, delay: 1.0, options: [], animations: {
                self.leftLine.alpha = 1
            }, completion: nil)
            self.landOrDepatureBottomLabelAnimate("LAND " + (flightItem["landTime"] as! String))
        }
        self.cubeAnimate(self.landedOrDepatureLabel, flightInfo: flightItem["flightStatus"] as! String)
        self.cubeAnimate(self.flightNo, flightInfo: flightItem["flightNo"] as! String)
        self.cubeAnimate(self.ternimalAndGateLabel, flightInfo: flightItem["tg"] as! String)
//        self.airplaneAndPlaceAnimate(self.sourcePlace, yValue: -100, flightInfo: flightItem["sourcePlace"] as! String)
//        self.airplaneAndPlaceAnimate(self.targetPlace, yValue: 100, flightInfo: flightItem["targetPlace"] as! String)
        self.placeAndAirplaneAnimate(flightItem)
    }
    
    func cubeAnimate(targetView: UIView, flightInfo: String) {
        // 判断UIView的具体实现类
        if targetView.isKindOfClass(UILabel) {
            let virtualTargetView = targetView as! UILabel
            // 复制UIView，作为底面
            let viewCopy = UILabel(frame: virtualTargetView.frame)
            viewCopy.alpha = 0
            viewCopy.text = flightInfo
            viewCopy.font = virtualTargetView.font
            viewCopy.textAlignment = virtualTargetView.textAlignment
            viewCopy.textColor = virtualTargetView.textColor
            viewCopy.backgroundColor = UIColor.clearColor()
            // 设置底面UIView的初始位置和高度
            viewCopy.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, viewCopy.frame.height / 2))
            self.topView.addSubview(viewCopy)
            UIView.animateWithDuration(2, animations: {
                // 执行UIView和UIViewCopy的动画
                virtualTargetView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, -virtualTargetView.frame.height / 2))
                virtualTargetView.alpha = 0
                viewCopy.alpha = 1
                viewCopy.transform = CGAffineTransformIdentity
            }, completion: { _ in
                // 当动画执行完毕后，将UIViewCopy的信息赋值给UIView，并还原UIView的状态，即与UIViewCopy相同的状态，然后移除UIViewCopy
                virtualTargetView.alpha = 1
                virtualTargetView.text = viewCopy.text
                virtualTargetView.transform = CGAffineTransformIdentity
                viewCopy.removeFromSuperview()
            })
        } else if targetView.isKindOfClass(UIImageView) {
            let virtualTargetView = targetView as! UIImageView
            let viewCopy = UIImageView(frame: virtualTargetView.frame)
            viewCopy.alpha = 0
            viewCopy.image = UIImage(named: flightInfo)
            viewCopy.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, viewCopy.frame.height / 2))
            self.topView.addSubview(viewCopy)
            UIView.animateWithDuration(2, animations: {
                virtualTargetView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, -virtualTargetView.frame.height / 2))
                virtualTargetView.alpha = 0
                viewCopy.alpha = 1
                viewCopy.transform = CGAffineTransformIdentity
            }, completion: { _ in
                virtualTargetView.alpha = 1
                virtualTargetView.image = viewCopy.image
                virtualTargetView.transform = CGAffineTransformIdentity
                viewCopy.removeFromSuperview()
            })
        }
    }
    
    func rotateAnimate(direction: Int) {
        UIView.animateWithDuration(2, animations: {
            // 判断向上还是向下旋转
            if RotateDirection.Positive.rawValue == direction {
                // 在这个示例中小箭头的初始位置是飞机已降落状态，所以想要降头从起飞状态旋转到降落状态，只要恢复初始状态即可
                self.landedOrDepatureSmallArrowImageView.transform = CGAffineTransformIdentity
            } else {
                // 向上旋转
                let rotation = CGAffineTransformMakeRotation(CGFloat(RotateDirection.Negative.rawValue) * CGFloat(M_PI_2))
                self.landedOrDepatureSmallArrowImageView.transform = rotation
            }
        }, completion: nil)
    }
    
    func airplaneAndPlaceAnimate(targetView: UILabel, yValue: CGFloat, flightInfo: String) {
        UIView.animateWithDuration(1, delay: 0, options: [], animations: {
            targetView.center.y += yValue
            targetView.alpha = 0
            self.airplaneImageView.center.x += self.view.bounds.width / 2
        }, completion: { _ in
            targetView.text = flightInfo
            self.airplaneImageView.center.x -= self.view.bounds.width
            self.airplaneImageView.transform = CGAffineTransformMakeRotation(-3.14/13)
            UIView.animateWithDuration(1.0, animations: {
                targetView.center.y -= yValue
                targetView.alpha = 1
                self.airplaneImageView.center = self.airplaneImageViewOriginalCenter
            })
            UIView.animateWithDuration(0.7, delay: 0.5, options: [], animations: {
                self.airplaneImageView.transform = CGAffineTransformIdentity
            }, completion: nil)
        })
    }
    
    func placeAndAirplaneAnimate(flightItem: NSDictionary) {
        UIView.animateWithDuration(1, delay: 0, options: [], animations: {
            // 将起飞地向上移动，同时淡出
            self.targetPlace.center.y += 100
            self.targetPlace.alpha = 0
            // 将目的地向下移动，同时淡出
            self.sourcePlace.center.y -= 100
            self.sourcePlace.alpha = 0
            // 将飞机向右移出屏幕
            self.airplaneImageView.center.x += self.view.bounds.width / 1.5
            }, completion: { _ in
                // 根据传入的数据源更改起飞地和目的地
                self.targetPlace.text = flightItem["targetPlace"] as? String
                self.sourcePlace.text = flightItem["sourcePlace"] as? String
                // 将飞机移到屏幕左侧外，这里没有补间动画
                self.airplaneImageView.center.x -= self.view.bounds.width * 1.5
                // 将飞机向上旋转一个角度，这里没有补间动画
                self.airplaneImageView.transform = CGAffineTransformMakeRotation(-3.14/10)
                UIView.animateWithDuration(1.0, animations: {
                    // 将起飞地向下移动，也就是恢复到初始位值，同时淡入
                    self.targetPlace.center.y -= 100
                    self.targetPlace.alpha = 1
                    // 将目的地向上移动，也就是恢复到初始位值，同时淡入
                    self.sourcePlace.center.y += 100
                    self.sourcePlace.alpha = 1
                    // 将飞机移动到初始位置
                    self.airplaneImageView.center = self.airplaneImageViewOriginalCenter
                })
                UIView.animateWithDuration(0.7, delay: 0.5, options: [], animations: {
                    // 将飞机的角度恢复到初始状态
                    self.airplaneImageView.transform = CGAffineTransformIdentity
                }, completion: nil)
        })
    }
    
    func landOrDepatureBottomLabelAnimate(flightInfo: String){
        UIView.animateWithDuration(1, delay: 0, options: [], animations: {
            self.landedOrDepatureTimeBottomLabel.alpha = 0
        }, completion: { _ in
            self.landedOrDepatureTimeBottomLabel.text = flightInfo
            UIView.animateWithDuration(1, animations: {
                self.landedOrDepatureTimeBottomLabel.alpha = 1
            })
        })
    }

}
