//
//  PhotoLibraryViewController.swift
//  Universe App
//
//  Created by Yuriy on 18.03.2024.
//

import UIKit
import SnapKit

class PhotoLibraryViewController: UIViewController {
    
    //MARK: - 'Private constants'
    private enum UIConstants {
        static let cornerRadius: CGFloat = 25
        static let buttonSize: CGFloat = 60
        static let sideMargins: CGFloat = 32
    }
    
    //MARK: - 'Private properties'
    
    private let mainImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "testImage"))
        image.layer.cornerRadius = UIConstants.cornerRadius
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let binButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bin"), for: .normal)
        button.backgroundColor = UIColor.bin
        return button
    }()
    
    private let doneButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "done"), for: .normal)
        button.backgroundColor = UIColor.done
        return button
    }()
    
    private let emptyBottomView = {
        let view = UIView()
        view.backgroundColor = UIColor.bottomTrash
        view.layer.cornerRadius = UIConstants.cornerRadius
        return view
    }()
    
    private let countLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        label.text = "1110"
        return label
    }()
    
    private let trashLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.text = "images in the trash"
        label.numberOfLines = 2
        return label
    }()
    
    private let emptyTrashButton = {
        var configuration = UIButton.Configuration.filled()
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        configuration.attributedTitle = AttributedString("Empty trash", attributes: container)
        configuration.image = UIImage(named: "bin")?.withRenderingMode(.alwaysTemplate)
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
        mainHStack.spacing = 16
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

extension PhotoLibraryViewController {
    
    private func addTargets() {
        binButton.addTarget(self, action: #selector(binTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        emptyTrashButton.addTarget(self, action: #selector(clearTrashTapped), for: .touchUpInside)
    }
    
    @objc
    func binTapped() {
        print("binTapped")
    }
    
    @objc
    func doneTapped() {
        print("doneTapped")
    }
    
    @objc
    func clearTrashTapped() {
        print("clearTrashTapped")
    }
}

