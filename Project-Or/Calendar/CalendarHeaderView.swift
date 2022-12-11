
import UIKit

class CalendarHeaderView: UIView {
    
    lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.text = "Month"
        label.accessibilityTraits = .header
        label.isAccessibilityElement = true
        return label
    }()
    
    lazy var dayOfWeekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return dateFormatter
    }()
    
    var baseDate = Date() {
        didSet {
            monthLabel.text = dateFormatter.string(from: baseDate)
        }
    }
    
    
    
    init() {
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(monthLabel)
        addSubview(dayOfWeekStackView)

        
        for dayNumber in 1...7 {
            let dayLabel = UILabel()
            dayLabel.font = .systemFont(ofSize: 12, weight: .bold)
            dayLabel.textColor = UIColor.init(displayP3Red: 164/255, green: 180/255, blue: 202/255, alpha: 1)
            dayLabel.textAlignment = .center
            dayLabel.text = dayOfWeekLetter(for: dayNumber)

            
            
            // VoiceOver users don't need to hear these days of the week read to them, nor do SwitchControl or Voice Control users need to select them
            // If fact, they get in the way!
            // When a VoiceOver user highlights a day of the month, the day of the week is read to them.
            // That method provides the same amount of context as this stack view does to visual users
            dayLabel.isAccessibilityElement = false
            dayOfWeekStackView.addArrangedSubview(dayLabel)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func dayOfWeekLetter(for dayNumber: Int) -> String {
        switch dayNumber {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return ""
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //half length of string
        let dayLabelHalfWidth = ceil("SAT".size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]).width)/2
        //half length of calendar cell
        let calendarCellHalfWidth = round((self.frame.width / 7)/2)
        //day label spacing :>)
        let properMonthLabelPadding = calendarCellHalfWidth - dayLabelHalfWidth
        
        
        NSLayoutConstraint.activate([
            
            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: properMonthLabelPadding),
            monthLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            dayOfWeekStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayOfWeekStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayOfWeekStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            ])
    }
}
