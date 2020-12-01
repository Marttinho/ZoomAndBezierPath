//
//  ViewController.swift
//  testZooming
//
//  Created by Martin Nahalka on 11/11/2020.
//  Copyright © 2020 Martin Nahalka. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate {

    var scrollView: UIScrollView!
    var animateLassoLayer: CAShapeLayer!
    let opatic_red = UIColor(red: 255.0/255.0, green: 49.0/255.0, blue: 15.0/255.0, alpha: 122.0/255.0)
    
    var imageView: UIImageView!
    var imageViewbottom: UIImageView!
    var edit_mode = 1
    var coords:Array<CGPoint> = []
    var lastPoint = CGPoint.zero
    var brushWidth: CGFloat = 35.0 / UIScreen.main.scale
    var tempbrush = UIImageView()
    var shapeLayer = CAShapeLayer()
    var viewContainer = UIView()
    var widthDiv : CGFloat = 0
    var heightDiv : CGFloat = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scrollView = UIScrollView(frame: CGRect( x:80,y:300,width:300, height:300))
        scrollView.backgroundColor = .red
        imageView = UIImageView(frame: CGRect( x:0,y:0,width:300, height:300))
        imageView.image = UIImage(named: "test")
        imageViewbottom = UIImageView(frame: CGRect( x:0,y:0,width:300, height:300))
        imageViewbottom.image = UIImage(named: "test1")
        viewContainer = UIStackView(frame: CGRect( x:0,y:0,width:300, height:300))
        
        view.addSubview(scrollView)
        
        
        scrollView.addSubview(viewContainer)
        viewContainer.addSubview(imageViewbottom)
        viewContainer.addSubview(imageView)
        print(imageView.frame.width)
        print(imageView.image!.size.width)
        widthDiv = CGFloat(imageView.frame.width / imageView.image!.size.width)
        heightDiv = CGFloat(imageView.frame.height / imageView.image!.size.height)
        
//        scrollView.addSubview(imageViewbottom)
//        scrollView.addSubview(imageView)
//        imageView.contentMode = .scaleToFill
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
        
        imageView.isUserInteractionEnabled = true
        imageView.isExclusiveTouch = true
        tempbrush = UIImageView(frame: imageView.frame)
//        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImage)))
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(self.handleGesture(_:))))
        imageView.addGestureRecognizer(panGesture)
        
    
    }
    

    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        var touches : Array<CGPoint> = []
        
        switch sender.state {
        case .began:
            let translation = sender.location(in: self.imageView)
            self.coords = []
            self.coords.append(translation)
            lastPoint = translation
            
        case .changed:
            print("changed")
            let translation = sender.location(in: self.imageView)
            touches.append(translation)
            coords.append(translation)
            drawLine(capMode: .round, touches: touches, blendMode: .normal)
            imageView.addSubview(tempbrush)
        case .cancelled: print("cancelled")
        case .ended: print("ended")
            tempbrush.removeFromSuperview()
            tempbrush = UIImageView(frame: imageView.frame)
        UIGraphicsBeginImageContextWithOptions(imageView.image!.size, false, 0)
            //UIGraphicsBeginImageContext(imageView.image!.size)
            imageView.image!.draw(at: CGPoint.zero)
            let context:CGContext = UIGraphicsGetCurrentContext()!;
            let a = create()
            animateLassoLayer = CAShapeLayer()
            animateLassoLayer.path = createForCAShapeLayer().cgPath
            animateLassoLayer.fillColor = opatic_red.cgColor
            imageView.layer.addSublayer(animateLassoLayer)
            context.addPath(a.cgPath)
//            context.clip();
            
            
            //
            context.setBlendMode(.clear)
            context.setFillColor(UIColor.clear.cgColor)
            context.fillPath()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.animateLassoLayer.removeFromSuperlayer()
            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();

            self.imageView.image = newImage
        }
            
        default:
            break
        }
    }
    
    func create()-> UIBezierPath{
            let path = UIBezierPath()
            path.move(to: CGPoint(x:coords[0].x/widthDiv,y: coords[0].y/heightDiv))
            
            for i in coords {
    
                    path.addLine(to: CGPoint(x:i.x/widthDiv, y:i.y/heightDiv))
    
            }
            
            path.close()
            return path
        }
    
    func createForCAShapeLayer()-> UIBezierPath{
            let path = UIBezierPath()
            print("creating bezier")
            print("pre path")
            path.move(to: CGPoint(x:coords[0].x,y: coords[0].y))
            print(coords[0])
            print("post path")
            for i in coords {
    
                    path.addLine(to: CGPoint(x:i.x, y:i.y))
    
            }
            
            path.close()

            return path
        }
    
    
    
    func drawLine(capMode: CGLineCap, touches: Array<CGPoint>, blendMode: CGBlendMode){
            
            if self.edit_mode == 1{
              let imageViewTouch:UIImageView = tempbrush

              if let touch = touches.first{
                 
                 let currentPoint = touch
                
    
                    self.coords.append(currentPoint)
    
                
                   UIGraphicsBeginImageContextWithOptions(imageViewTouch.frame.size, false, 0)
                 imageViewTouch.image?.draw(in: CGRect(x: 0, y: 0, width: imageViewTouch.frame.size.width, height: imageViewTouch.frame.size.height))
                 UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
                 UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))

                 UIGraphicsGetCurrentContext()?.setLineCap(capMode)
                 UIGraphicsGetCurrentContext()?.setLineWidth(brushWidth)

                UIGraphicsGetCurrentContext()?.setStrokeColor(red: 255.0/255.0, green: 49.0/255.0, blue: 15.0/255.0, alpha: 1.0)
                 UIGraphicsGetCurrentContext()?.setBlendMode(blendMode)
                 UIGraphicsGetCurrentContext()?.strokePath()
                 imageViewTouch.image = UIGraphicsGetImageFromCurrentImageContext()
                //imageViewTouch.alpha = 0.48 //CGFloat(opacity1)
                 UIGraphicsEndImageContext()
                 lastPoint = currentPoint

              }
            }
        }

    
    
    

    


    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //imageView
        viewContainer
    }
    

    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//for 1 imageview
        if scrollView.zoomScale > 1 {

            if let image = imageView.image {

                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height

                let ratio = ratioW < ratioH ? ratioW:ratioH

                let newWidth = image.size.width*ratio
                let newHeight = image.size.height*ratio

                let left = 0.5 * (newWidth * scrollView.zoomScale > imageView.frame.width ? (newWidth - imageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > imageView.frame.height ? (newHeight - imageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    
        
    }
    
    
    
    
    
    
    
    
    
}

