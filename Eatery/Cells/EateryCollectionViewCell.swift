import UIKit
import DiningStack
import CoreLocation
import Kingfisher
import SnapKit

let metersInMile: Double = 1609.344

class EateryCollectionViewCell: UICollectionViewCell {

    var backgroundImageView = UIImageView()
    var titleLabel = UILabel()
    var statusLabel = UILabel()
    var timeLabel = UILabel()
    var distanceLabel = UILabel()
    var infoContainer = UIView()
    var menuTextView = UITextView()
    var menuTextViewHeight: NSLayoutConstraint!
    var contentViewWidth: NSLayoutConstraint!
    var backgroundImageViewHeight: NSLayoutConstraint!
    var paymentImageViews = [UIImageView]()
    var paymentContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if hasAmbiguousLayout {
            print ("ambigous layout")
        }
        
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(infoContainer)
        contentView.addSubview(menuTextView)
        contentView.addSubview(paymentContainer)
        infoContainer.addSubview(titleLabel)
        infoContainer.addSubview(statusLabel)
        infoContainer.addSubview(timeLabel)
        infoContainer.addSubview(distanceLabel)
        
        menuTextViewHeight = menuTextView.heightAnchor.constraint(equalToConstant: 0)
        menuTextViewHeight.isActive = true
        menuTextView.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewWidth = contentView.widthAnchor.constraint(equalToConstant: 0)
        contentViewWidth.isActive = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageViewHeight = backgroundImageView.heightAnchor.constraint(equalToConstant: 0)
        backgroundImageViewHeight.isActive = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(infoContainer.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        infoContainer.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(menuTextView.snp.top)
            make.height.equalTo(54)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.height.equalTo(14)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-8)
//            make.firstBaseline.equalTo(timeLabel.snp.firstBaseline)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(statusLabel)
            make.centerY.equalTo(distanceLabel)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.firstBaseline.equalTo(statusLabel.snp.firstBaseline)
        }
        
        distanceLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(titleLabel)
        }
        
        paymentContainer.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
        }
        
        menuTextView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(infoContainer.snp.bottom)
        }
        
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        distanceLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium)
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        
        infoContainer.backgroundColor = .white
        
        menuTextView.text = nil
        menuTextView.textContainerInset = UIEdgeInsets(top: 10.0, left: 6.0, bottom: 10.0, right: 6.0)
        
        let paymentImageRight = UIImageView()
        let paymentImageMiddle = UIImageView()
        let paymentImageLeft = UIImageView()
        
        paymentContainer.addSubview(paymentImageRight)
        paymentContainer.addSubview(paymentImageMiddle)
        paymentContainer.addSubview(paymentImageLeft)
        
        paymentImageRight.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.leading.equalTo(paymentImageMiddle.snp.trailing).offset(5)
        }
        
        paymentImageMiddle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.leading.equalTo(paymentImageLeft.snp.trailing).offset(5)
        }
        
        paymentImageLeft.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.leading.equalToSuperview().offset(5)
        }
        
        paymentImageViews.append(paymentImageRight)
        paymentImageViews.append(paymentImageMiddle)
        paymentImageViews.append(paymentImageLeft)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var eatery: Eatery!
    
    func update(userLocation: CLLocation?) {
        if let distance = userLocation?.distance(from: eatery.location) {
            distanceLabel.text = "\(Double(round(10 * distance / metersInMile) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }
    }
    
    func set(eatery: Eatery, userLocation: CLLocation?) {
        self.eatery = eatery
        
        titleLabel.text = eatery.nickname

        if let url = URL(string: eateryImagesBaseURL + eatery.slug + ".jpg") {
            let placeholder = UIImage.image(withColor: UIColor(white: 0.97, alpha: 1.0))
            backgroundImageView.kf.setImage(with: url, placeholder: placeholder)
        }
        
        update(userLocation: userLocation)
        
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        
        var images: [UIImage] = []
        
        if (eatery.paymentMethods.contains(.Cash) || eatery.paymentMethods.contains(.CreditCard)) {
            images.append(#imageLiteral(resourceName: "cashIcon"))
        }
        
        if (eatery.paymentMethods.contains(.BRB)) {
            images.append(#imageLiteral(resourceName: "brbIcon"))
        }
        
        if (eatery.paymentMethods.contains(.Swipes)) {
            images.append(#imageLiteral(resourceName: "swipeIcon"))
        }
        
        for (index, imageView) in paymentImageViews.enumerated() {
            if index < images.count {
                imageView.image = images[index]
                imageView.isHidden = false
            } else {
                imageView.isHidden = true
            }
        }

        backgroundImageView.subviews.last?.removeFromSuperview()
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            titleLabel.textColor = .black
            statusLabel.text = "Open"
            statusLabel.textColor = .eateryBlue
            timeLabel.text = message
            timeLabel.textColor = .gray
            distanceLabel.textColor = .darkGray
        case .closed(let message):
            if !eatery.isOpenToday() {
                statusLabel.text = "Closed Today"
                timeLabel.text = ""
            } else {
                statusLabel.text = "Closed"
                timeLabel.text = message
            }

            titleLabel.textColor = .darkGray
            statusLabel.textColor = .gray
            timeLabel.textColor = .gray
            distanceLabel.textColor = .gray

            let closedView = UIView()
            closedView.backgroundColor = UIColor(white: 1.0, alpha: 0.65)
            backgroundImageView.addSubview(closedView)
            closedView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
