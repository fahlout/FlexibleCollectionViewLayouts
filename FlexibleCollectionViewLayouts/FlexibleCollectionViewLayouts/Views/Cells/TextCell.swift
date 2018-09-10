import UIKit

let imageCache = NSCache<NSString, UIImage>()

public class TextCell: UICollectionViewCell {
    
    /// The `UUID` for the data this cell is presenting.
    var representedId: UUID?
    
    public let label = UILabel()
    public let imageView = UIImageView()
    var sessionTask: URLSessionTask?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp() {
        clipsToBounds = true
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ])
        
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
    }
    
    func configure(with data: DisplayData?) {
        guard let image = data?.image else {
            imageView.isHidden = true
            return
        }
        imageView.isHidden = false
        imageView.image = image
    }
}

public class AutoSizeLoggingTextCell: TextCell {
    public override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        print(#function)
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        print(#function)
        super.apply(layoutAttributes)
    }
}

