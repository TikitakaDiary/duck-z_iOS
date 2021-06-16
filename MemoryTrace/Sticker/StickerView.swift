//
//  StickerView.swift
//  StickerView
//
//  Copyright © All rights reserved.
//

import UIKit

enum StickerViewHandler:Int {
    case close = 0
    case control
}

func CGRectGetCenter(_ rect:CGRect) -> CGPoint {
    return CGPoint(x: rect.midX, y: rect.midY)
}

func CGRectScale(_ rect:CGRect, wScale:CGFloat, hScale:CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * wScale, height: rect.size.height * hScale)
}

func CGAffineTransformGetAngle(_ t:CGAffineTransform) -> CGFloat {
    return atan2(t.b, t.a)
}

func CGPointGetDistance(point1:CGPoint, point2:CGPoint) -> CGFloat {
    let fx = point2.x - point1.x
    let fy = point2.y - point1.y
    return sqrt(fx * fx + fy * fy)
}

@objc protocol StickerViewDelegate {
    @objc func stickerViewDidBeginMoving(_ stickerView: StickerView)
    @objc func stickerViewDidTap(_ stickerView: StickerView)
}

class StickerView: UIView {
    var delegate: StickerViewDelegate!
    var contentView:UIView!

    var enableClose:Bool = true {
        didSet {
            if self.showEditingHandlers {
                self.setEnableClose(self.enableClose)
            }
        }
    }

    var enablecontrol:Bool = true{
        didSet {
            if self.showEditingHandlers {
                self.setEnablecontrol(self.enablecontrol)
            }
        }
    }

    var showEditingHandlers:Bool = true {
        didSet {
            if self.showEditingHandlers {
                self.setEnableClose(self.enableClose)
                self.setEnablecontrol(self.enablecontrol)
                
                self.contentView?.layer.borderWidth = 1
            }
            else {
                self.setEnableClose(false)
                self.setEnablecontrol(false)
                
                self.contentView?.layer.borderWidth = 0
            }
        }
    }
    
    private var _minimumSize:NSInteger = 0
    public  var minimumSize:NSInteger {
        set {
            _minimumSize = max(newValue, self.defaultMinimumSize)
        }
        get {
            return _minimumSize
        }
    }

    private var _outlineBorderColor:UIColor = .clear
    public  var outlineBorderColor:UIColor {
        set {
            _outlineBorderColor = newValue
            self.contentView?.layer.borderColor = _outlineBorderColor.cgColor
        }
        get {
            return _outlineBorderColor
        }
    }

    public  var userInfo:Any?

    public init(contentView: UIView) {
        self.defaultInset = 11
        self.defaultMinimumSize = 4 * self.defaultInset
        
        var frame = contentView.frame
        frame = CGRect(x: 0, y: 0, width: frame.size.width + CGFloat(self.defaultInset) * 2, height: frame.size.height + CGFloat(self.defaultInset) * 2)
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addGestureRecognizer(self.moveGesture)
        self.addGestureRecognizer(self.tapGesture)
        
        self.contentView = contentView
        self.contentView.center = CGRectGetCenter(self.bounds)
        self.contentView.isUserInteractionEnabled = false
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.layer.allowsEdgeAntialiasing = true
        self.addSubview(self.contentView)
        
        let origin = self.contentView.frame.origin
        let size = self.contentView.frame.size
        
        closeImageView.center = origin
        closeImageView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        controlImageView.center = CGPoint(x: origin.x + size.width, y: origin.y + size.height)
        controlImageView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        
        self.addSubview(self.closeImageView)
        self.addSubview(self.controlImageView)
        
        self.showEditingHandlers = true
        self.enableClose = true
        self.enablecontrol = true
        
        self.minimumSize = self.defaultMinimumSize
        self.outlineBorderColor = .white
    }
    
    public  required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImage(_ image:UIImage, forHandler handler:StickerViewHandler) {
        switch handler {
        case .close:
            self.closeImageView.image = image
        case .control:
            self.controlImageView.image = image
        }
    }
    
    private var defaultInset:NSInteger
    private var defaultMinimumSize:NSInteger
    
    private var beginningPoint = CGPoint.zero
    private var beginningCenter = CGPoint.zero
    
    private var initialBounds = CGRect.zero
    private var initialDistance:CGFloat = 0
    private var deltaAngle:CGFloat = 0
    
    private lazy var moveGesture = {
        return UIPanGestureRecognizer(target: self, action: #selector(handleMoveGesture(_:)))
    }()
    
    private lazy var controlImageView:UIImageView = {
        let controlImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        controlImageView.contentMode = UIView.ContentMode.scaleAspectFit
        controlImageView.backgroundColor = UIColor.clear
        controlImageView.isUserInteractionEnabled = true
        controlImageView.addGestureRecognizer(self.controlGesture)
        
        return controlImageView
    }()
    private lazy var controlGesture = {
        return UIPanGestureRecognizer(target: self, action: #selector(handlecontrolGesture(_:)))
    }()
    
    private lazy var closeImageView:UIImageView = {
        let closeImageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        closeImageview.contentMode = UIView.ContentMode.scaleAspectFit
        closeImageview.backgroundColor = UIColor.clear
        closeImageview.isUserInteractionEnabled = true
        closeImageview.addGestureRecognizer(self.closeGesture)
        return closeImageview
    }()
    private lazy var closeGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleCloseGesture(_:)))
    }()
    
    private lazy var tapGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    }()
    
    // MARK: - Gesture Handlers
    @objc
    func handleMoveGesture(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: self.superview)
        switch recognizer.state {
        case .began:
            self.beginningPoint = touchLocation
            self.beginningCenter = self.center
            if let delegate = self.delegate {
                delegate.stickerViewDidBeginMoving(self)
            }
        case .changed:
            self.center = CGPoint(x: self.beginningCenter.x + (touchLocation.x - self.beginningPoint.x), y: self.beginningCenter.y + (touchLocation.y - self.beginningPoint.y))
        case .ended:
            self.center = CGPoint(x: self.beginningCenter.x + (touchLocation.x - self.beginningPoint.x), y: self.beginningCenter.y + (touchLocation.y - self.beginningPoint.y))
        default:
            break
        }
    }
    
    @objc
    func handlecontrolGesture(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: self.superview)
        let center = self.center
        
        switch recognizer.state {
        case .began:
            self.deltaAngle = CGFloat(atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))) - CGAffineTransformGetAngle(self.transform)
            self.initialBounds = self.bounds
            self.initialDistance = CGPointGetDistance(point1: center, point2: touchLocation)
        case .changed:
            let angle = atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))
            let angleDiff = Float(self.deltaAngle) - angle
            self.transform = CGAffineTransform(rotationAngle: CGFloat(-angleDiff))
            
            var scale = CGPointGetDistance(point1: center, point2: touchLocation) / self.initialDistance
            let minimumScale = CGFloat(self.minimumSize) / min(self.initialBounds.size.width, self.initialBounds.size.height)
            
            if scale < minimumScale {
                scale = minimumScale
            }
            
//            let maximumScale = minimumScale * 3
//
//            if scale < minimumScale {
//                scale = minimumScale
//            } else if scale > maximumScale {
//                scale = maximumScale
//            }
//            scale = max(scale, minimumScale)
            
            let scaledBounds = CGRectScale(self.initialBounds, wScale: scale, hScale: scale)
            self.bounds = scaledBounds
            self.setNeedsDisplay()
        case .ended:
            break
        default:
            break
        }
    }
    
    @objc
    func handleCloseGesture(_ recognizer: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }
    
    @objc
    func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.stickerViewDidTap(self)
        }
    }
    
    private func setEnableClose(_ enableClose:Bool) {
        self.closeImageView.isHidden = !enableClose
        self.closeImageView.isUserInteractionEnabled = enableClose
    }
    
    private func setEnablecontrol(_ enablecontrol:Bool) {
        self.controlImageView.isHidden = !enablecontrol
        self.controlImageView.isUserInteractionEnabled = enablecontrol
    }
}

extension StickerView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

