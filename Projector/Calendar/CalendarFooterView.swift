
import UIKit

class CalendarFooterView: UIView {
    
    lazy var previousMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.init(named: "calendarBackArrow"), for: .normal)
        button.setTitle("  PREVIOUS", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(didTapPreviousMonthButton), for: .touchUpInside)
        return button
    }()
    
    lazy var nextMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        //align image to the right side
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        
        button.setImage(UIImage.init(named: "calendarNextArrow"), for: .normal)
        button.setTitle("NEXT  ", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
        return button
    }()
    
    let didTapLastMonthCompletionHandler: (() -> Void)
    let didTapNextMonthCompletionHandler: (() -> Void)
    
    init(
        didTapLastMonthCompletionHandler: @escaping (() -> Void),
        didTapNextMonthCompletionHandler: @escaping (() -> Void)
        ) {
        self.didTapLastMonthCompletionHandler = didTapLastMonthCompletionHandler
        self.didTapNextMonthCompletionHandler = didTapNextMonthCompletionHandler
        
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(previousMonthButton)
        addSubview(nextMonthButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var previousOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //2X
        //half length of string
        let dayLabelHalfWidth = ceil("SAT".size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]).width)/2
        //half length of calendar cell
        let calendarCellHalfWidth = round((self.frame.width / 7)/2)
        //day label spacing :>)
        let properButtonPadding = calendarCellHalfWidth - dayLabelHalfWidth
        
        
        let smallDevice = UIScreen.main.bounds.width <= 350
        
        let fontPointSize: CGFloat = smallDevice ? 14 : 16
        
        previousMonthButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
        nextMonthButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
        
        NSLayoutConstraint.activate([
            
            previousMonthButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: properButtonPadding),
            previousMonthButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -properButtonPadding),
            nextMonthButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    @objc func didTapPreviousMonthButton() {
        didTapLastMonthCompletionHandler()
    }
    
    @objc func didTapNextMonthButton() {
        didTapNextMonthCompletionHandler()
    }
}
