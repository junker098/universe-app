//
//  PhotoLibraryViewController.swift
//  Universe App
//
//  Created by Yuriy on 18.03.2024.
//

import UIKit
import SnapKit
import Combine

final class PhotoLibraryViewController: BaseViewController {
    
    private var viewModel: PhotoLibraryViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: PhotoLibraryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 'Private constants'
    private enum UIConstants {
        static let cornerRadius: CGFloat = 25
        static let buttonSize: CGFloat = 60
        static let sideMargins: CGFloat = 32
    }
    
    //MARK: - 'Private properties'
    
    private let mainImageView: UIImageView = {
        $0.image = UIImage(named: ImagesNames.testImage.rawValue)
        $0.layer.cornerRadius = UIConstants.cornerRadius
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    
    private let binButton = {
        $0.setImage(UIImage(named: ImagesNames.bin.rawValue), for: .normal)
        $0.backgroundColor = UIColor.bin
        return $0
    }(UIButton())
    
    private let doneButton = {
        $0.setImage(UIImage(named: ImagesNames.done.rawValue), for: .normal)
        $0.backgroundColor = UIColor.done
        return $0
    }(UIButton())
    
    private let emptyBottomView = {
        $0.backgroundColor = UIColor.bottomTrash
        $0.layer.cornerRadius = UIConstants.cornerRadius
        return $0
    }(UIView())
    
    private let countLabel = {
        $0.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        $0.textColor = .white
        $0.text = "0"
        return $0
    }(UILabel())
    
    private let trashLabel = {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .white
        $0.text = "images in the trash"
        $0.numberOfLines = 2
        return $0
    }(UILabel())
    
    private let emptyTrashButton = {
        var configuration = UIButton.Configuration.filled()
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        configuration.attributedTitle = AttributedString("Empty trash", attributes: container)
        configuration.image = UIImage(named: ImagesNames.bin.rawValue)?.withRenderingMode(.alwaysTemplate)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 5
        configuration.baseBackgroundColor = UIColor.emptyTrash
        configuration.baseForegroundColor = UIColor.trashText
        configuration.background.cornerRadius = 12
        configuration.cornerStyle = .fixed
        let button = UIButton(configuration: configuration, primaryAction: nil)
        return button
    }()
    
    //MARK: - 'Lifecycle'
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopView()
        setupBottomView()
        addTargets()
        viewModel.startLoading()
        setupPublisher()
        showActivity()
    }
    
    private func setupImage(_ image : UIImage?) {
        if let newImage = image {
            mainImageView.image = newImage
        } else {
            mainImageView.image = UIImage(named: ImagesNames.blank_photo.rawValue)
        }
    }
    
    private func setupPublisher() {
        viewModel.photoPublisher.sink { [weak self]  event in
            DispatchQueue.main.async {
                guard let self else { return }
                switch event {
                case .errorMessage(let text):
                    self.showAllertMessage(text: text)
                case .photoPublisher(let uIImage):
                    self.setupImage(uIImage)
                    self.dismissActivity()
                case .trashCount(let count):
                    self.countLabel.text = count
                }
            }
        } .store(in: &cancellables)
    }
    
    //MARK: - 'Setup costraints'
    private func setupTopView() {
        view.addSubview(mainImageView)
        mainImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.horizontalEdges.equalToSuperview().inset(UIConstants.sideMargins)
        }
        
        view.addSubview(binButton)
        binButton.snp.makeConstraints { make in
            make.size.equalTo(UIConstants.buttonSize)
            make.leading.equalTo(mainImageView.snp.leading).offset(60)
            make.bottom.equalTo(mainImageView.snp.bottom).offset(-16)
        }
        binButton.layer.cornerRadius = UIConstants.buttonSize / 2
        binButton.clipsToBounds = true
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.size.equalTo(UIConstants.buttonSize)
            make.trailing.equalTo(mainImageView.snp.trailing).offset(-60)
            make.bottom.equalTo(mainImageView.snp.bottom).offset(-16)
        }
        doneButton.layer.cornerRadius = UIConstants.buttonSize / 2
        doneButton.clipsToBounds = true
    }
    
    private func setupBottomView() {
        let mainHStack = UIStackView()
        mainHStack.axis = .horizontal
        mainHStack.spacing = 12
        mainHStack.addArrangedSubview(countLabel)
        mainHStack.addArrangedSubview(trashLabel)
        mainHStack.addArrangedSubview(emptyTrashButton)
        
        emptyBottomView.addSubview(mainHStack)
        view.addSubview(emptyBottomView)
        emptyBottomView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(mainImageView.snp.bottom).offset(60)
            make.horizontalEdges.equalToSuperview().inset(UIConstants.sideMargins)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
        
        mainHStack.snp.makeConstraints { make in
            make.leading.equalTo(emptyBottomView.snp.leading).inset(16)
            make.trailing.equalTo(emptyBottomView.snp.trailing).inset(10)
            make.top.bottom.equalTo(emptyBottomView).inset(10)
        }
        
        emptyTrashButton.snp.makeConstraints { make in
            make.width.equalTo(179)
            make.height.equalTo(48)
        }
    }
}

//MARK: - 'Methods'

private extension PhotoLibraryViewController {
    
    func addTargets() {
        binButton.addTarget(self, action: #selector(binTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        emptyTrashButton.addTarget(self, action: #selector(clearTrashTapped), for: .touchUpInside)
    }
    
    @objc
    func binTapped() {
        viewModel.deleteTapped()
    }
    
    @objc
    func doneTapped() {
       viewModel.showNext()
    }
    
    @objc
    func clearTrashTapped() {
        self.showAlert(title: "Confirm deleting", message: "Please confirm deleting \(viewModel.deletingCount()) elements") { [weak self] result in
            DispatchQueue.main.async {
                if let self, result {
                    self.showActivity()
                    self.viewModel.emptyTrash { result in
                        self.dismissActivity()
                        switch result {
                        case .success(let success):
                            self.showAllertMessage(text: success)
                        case .failure(_):
                            self.showAllertMessage(text: "You did not allow these photos to be deleted")
                        }
                    }
                } else {
                    self?.dismissActivity()
                }
            }
        }
    }
}

