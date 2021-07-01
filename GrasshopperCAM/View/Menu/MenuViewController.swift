import UIKit
import RxSwift
import RxCocoa

final class MenuViewController: UIViewController {

    @IBOutlet var menuContainerView: UIView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var collectionViewContainer: UIView!
    
    /// Section : UICollectionView가 가질 섹션들을 정의해놓은 열거형
    enum Section: CaseIterable {
        case outline
    }
    
    enum CellType {
        case basic
        case header
        case toggle
    }
    
    struct Item: Hashable {
        private let identifier = UUID()
        let title: String?
        let menuItem: MenuItem?
        let cellType: CellType
        
        init(menuItem: MenuItem? = nil, title: String? = nil, cellType: CellType = .basic) {
            self.menuItem = menuItem
            self.title = title
            self.cellType = cellType
        }
    }
    
    let disposeBag = DisposeBag()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureHierarchy()
        configureDataSource()
        applyInitialSnapshots()
        bind()
    }
    
    private func setupUI() {
        menuContainerView.layer.cornerRadius = Constant.GHLayer.cornerRadius
    }
    
    private func bind() {
        closeButton.rx.controlEvent(.touchUpInside).asDriver()
            .drive { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }

}

extension MenuViewController: UICollectionViewDelegate {
    
    // MARK: - UICollectionView 추가
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: collectionViewContainer.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionViewContainer.addSubview(collectionView)
    }
    
    // MARK: - UICollectionViewCompositionalLayout
    
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection
            let sectionType = Section.allCases[sectionIndex]
            
            switch sectionType {
            case .outline:
                let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            }
            
            let inset = Constant.GHCollectionView.sectionContentInset
            section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    // MARK: - CellRegistration & UICollectionViewDiffableDataSource
    
    private func configureDataSource() {
        let listCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = item.menuItem?.text
            contentConfiguration.secondaryText = item.menuItem?.title
            cell.contentConfiguration = contentConfiguration
        }
        
        let outlineHeaderCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
            cell.tintColor = Constant.GHColor.menuDefaultColor
        }
        
        let cellNib = UINib(nibName: "ToggleCollectionViewCell", bundle: nil)
        let toggleCellRegistration = UICollectionView.CellRegistration<ToggleCollectionViewCell, Item>(cellNib: cellNib) { (cell, indexPath, item) in
            cell.titleLabel.text = item.title
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            (collectionView, indexPath, item) in
            let sectionType = Section.allCases[indexPath.section]
            
            switch sectionType {
            case .outline:
                switch item.cellType {
                case .basic:
                    return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item)
                case .header:
                    return collectionView.dequeueConfiguredReusableCell(using: outlineHeaderCellRegistration, for: indexPath, item: item)
                case .toggle:
                    return collectionView.dequeueConfiguredReusableCell(using: toggleCellRegistration, for: indexPath, item: item)
                }
            }
        }
        
    }
    
    // MARK: - NSDiffableDataSourceSnapshot
    
    private func applyInitialSnapshots() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot)
        
        var outlineSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let menuCategories = MenuItem.Category.allCases
        menuCategories.forEach {
            var type: CellType = .header
            if $0.items.count == 0 {
                type = .toggle
            }
            
            let item = Item(title: String(describing: $0), cellType: type)
            outlineSnapshot.append([item])
            outlineSnapshot.append($0.items.map { Item(menuItem: $0) }, to: item)
        }
        dataSource.apply(outlineSnapshot, to: .outline, animatingDifferences: false)
    }
    
}
