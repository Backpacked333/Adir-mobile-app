//
//  Ext+UIView.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 21.10.2021.
//

import UIKit


class BaseXibLoadableView: UIView {
    // MARK: - Public Properties

    var contentView: UIView?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    // MARK: - Public methods

    func xibSetup() {
        guard let contentView = loadViewFromNib() else { return }
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }

    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        return view
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: Double {
        get { return Double(self.layer.borderWidth) }
        set {self.layer.borderWidth = CGFloat(newValue) }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get { return UIColor(cgColor: self.layer.borderColor!) }
        set {self.layer.borderColor = newValue?.cgColor }
    }
    
    func addBottomShadowForNavigation() {
        layer.masksToBounds = false
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.6
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
    
    func addBottomShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 1.0
        layer.masksToBounds = false
        layer.cornerRadius = 10.0
    }
    
    func addCenterShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        layer.shadowOffset = CGSize(width: 6, height: 6)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: 0,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
    
    func showShadow(_ opacity: Float, blur: CGFloat, offset: CGSize, shouldRasterize: Bool = true) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = blur
        layer.shadowOffset = offset
        layer.shouldRasterize = shouldRasterize
        layer.masksToBounds = false
        
        if shouldRasterize {
            layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
//    func addBottomShadowForNavigation(isOpacity: Bool = true) {
//        layer.masksToBounds = false
//        layer.shadowRadius = 2
//        layer.shadowOpacity = isOpacity ? 0 : 1
//        layer.shadowColor = AppColors.systemBright.color.withAlphaComponent(0.3).cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
//                                                     y: bounds.maxY - layer.shadowRadius,
//                                                     width: bounds.width,
//                                                     height: layer.shadowRadius)).cgPath
//    }
//
//    func setupBottomShadow(alpha: Double? = nil, radius: CGFloat? = nil) {
//        layer.masksToBounds = false
//        layer.shadowRadius = radius ?? 3
//        layer.shadowOpacity = 1
//        layer.shadowColor = AppColors.systemBright.color.withAlphaComponent(CGFloat(alpha ?? 0.4)).cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        let frames = CGRect(x: 0, y: bounds.minY - layer.shadowRadius, width: bounds.width, height: layer.shadowRadius)
//        layer.shadowPath = UIBezierPath(rect: frames).cgPath
//    }
//
//    func addDashedBorder() {
//        let color = AppColors.systemBright.color.cgColor
//
//        let shapeLayer = CAShapeLayer()
//        let frameSize = frame.size
//        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
//
//        shapeLayer.bounds = shapeRect
//        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.strokeColor = color
//        shapeLayer.lineWidth = 1.5
//        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
//        shapeLayer.lineDashPattern = [11, 6]
//        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 12).cgPath
//
//        layer.addSublayer(shapeLayer)
//    }

    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while !(responder is UIViewController) {
            responder = responder?.next
            if responder == nil {
                break
            }
        }
        return (responder as? UIViewController)
    }

    func addWithDefaultConstraints(to parentView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
        topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
        leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 0).isActive = true
        trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0).isActive = true
    }

    enum ViewSide {
        case left, right, top, bottom
    }

    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color

        switch side {
        case .left: border.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: thickness, height: frame.size.height)
        case .right: border.frame = CGRect(x: frame.size.width - thickness, y: frame.origin.y, width: thickness, height: frame.size.height)
        case .top: border.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: thickness)
        case .bottom: border.frame = CGRect(x: frame.origin.x, y: frame.size.height - thickness, width: frame.size.width, height: thickness)
        }
        layer.addSublayer(border)
    }
}



