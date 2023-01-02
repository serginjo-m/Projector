//
//  CanvasNote.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import Photos

class CanvasViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: Properties
    lazy var canvas: CanvasView = {
        let canvas = CanvasView()
        canvas.backgroundColor = .white
        canvas.frame = view.frame
        return canvas
    }()
    
    private let cellIdent = "cellId"
    //56 colors
    let colorPalette = ColorPalette()
    
    lazy var colorPaletteCollectionView: UICollectionView = {
        
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.white
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //hide scrollbar
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        collectionView.register(ColorPaletteCell.self, forCellWithReuseIdentifier: cellIdent)
        
        collectionView.isHidden = true
        
        return collectionView
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "New Canvas"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "saveTo"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var colorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.init(red: 249/255, green: 65/255, blue: 68/255, alpha: 1)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(showColorPalette), for: .touchUpInside)
        return button
    }()
    
    lazy var strokeSizeButton: UIImageView = {
        let view = UIImageView(image: UIImage(named: "pencil"))
        view.isUserInteractionEnabled = true
        view.contentMode = .bottom
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showStrokeSizes)))
        return view
    }()
    
    var strokeSizeIndicator: StrokeSizeButton = {
        let button = StrokeSizeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var undoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "undo_button"), for: .normal)
        button.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let undoButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "Undo"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var redoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "redo_button"), for: .normal)
        button.addTarget(self, action: #selector(handleRedo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let redoButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "Redo"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "eraser"), for: .normal)
        button.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let clearButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "Clear"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.isHidden = true
        stack.spacing = 10
        return stack
    }()
    
    let stackBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    var collectionViewHeightAnchor: NSLayoutConstraint!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        configureStrokeButtons()
        
        view.addSubview(canvas)
        view.addSubview(dismissButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(saveButton)
        view.addSubview(colorPaletteCollectionView)
        view.addSubview(colorButton)
        view.addSubview(strokeSizeIndicator)
        view.addSubview(strokeSizeButton)
        
        view.addSubview(clearButton)
        view.addSubview(clearButtonTitle)
        view.addSubview(undoButton)
        view.addSubview(undoButtonTitle)
        view.addSubview(redoButton)
        view.addSubview(redoButtonTitle)
        view.addSubview(stackBackgroundView)
        view.addSubview(stackView)
        
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let cellForRowNum = Int(colorPaletteCollectionView.frame.width / 42)
        switch cellForRowNum {
        case 8:
            collectionViewHeightAnchor.constant = 284
        case 7:
            collectionViewHeightAnchor.constant = 326
        default:
            collectionViewHeightAnchor.constant = 284
        }
    }
    
    //MARK: Methods
    private func configureStrokeButtons(){
        
        for number in 1...6 {
            
            let button = StrokeSizeButton()
            let size = CGFloat((number + 1) * 3)
            button.strokeSizeIndicatorWidthAnchor.constant = size
            button.strokeSizeIndicatorHeightAnchor.constant = size
            button.strokeSizeIndicator.layer.cornerRadius = size / 2
            button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStrokeChange)))
            
            stackView.addArrangedSubview(button)
        }
    }
    
    
    @objc func showStrokeSizes(sender: UITapGestureRecognizer){
        colorPaletteCollectionView.isHidden = true
        stackView.isHidden = !stackView.isHidden
        stackBackgroundView.isHidden = stackView.isHidden
    }
    
    @objc func showColorPalette(){
        stackView.isHidden = true
        stackBackgroundView.isHidden = stackView.isHidden
        colorPaletteCollectionView.isHidden = !colorPaletteCollectionView.isHidden
    }
    
    @objc func handleColorChange(button: UIButton) {
        colorButton.backgroundColor = button.backgroundColor
        strokeSizeIndicator.strokeSizeIndicator.backgroundColor = button.backgroundColor
        canvas.setStrokeColor(color: button.backgroundColor ?? .black)
        colorPaletteCollectionView.isHidden = true
    }
    
    @objc func handleStrokeChange(sender: UITapGestureRecognizer){
        guard let sizeButton = sender.view as? StrokeSizeButton else {return}
        
        let sizeValue = sizeButton.strokeSizeIndicatorWidthAnchor.constant
        
        self.strokeSizeIndicator.strokeSizeIndicatorHeightAnchor.constant = sizeValue
        self.strokeSizeIndicator.strokeSizeIndicatorWidthAnchor.constant = sizeValue
        self.strokeSizeIndicator.strokeSizeIndicator.layer.cornerRadius = sizeValue / 2
        canvas.setStrokeWidth(width: Float(sizeValue))
        
        [stackView, stackBackgroundView].forEach { view in
            view.isHidden = true
        }
    }
    
    
    @objc func handleUndo (){
        [stackView, stackBackgroundView, colorPaletteCollectionView].forEach { view in
            view.isHidden = true
        }
        //remove last line
        canvas.undo()
    }
    
    @objc func handleRedo (){
        [stackView, stackBackgroundView, colorPaletteCollectionView].forEach { view in
            view.isHidden = true
        }
        canvas.redo()
    }
    
    @objc func handleClear() {
        [stackView, stackBackgroundView, colorPaletteCollectionView].forEach { view in
            view.isHidden = true
        }
        //remove all elements
        canvas.clear()
    }
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //back to previous view
    @objc func saveAction(_ sender: Any) {
        
        //newly created image
        let image = canvas.renderImageFromCanvas()
        //save newly created image to photo library
        saveImage(image: image)
    }
    
    func saveImage(image: UIImage) {
        //save action
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            queryLastPhoto()
        }
    }
    
    func queryLastPhoto() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if (fetchResult.firstObject != nil){
            let lastImageAsset: PHAsset = fetchResult.firstObject as! PHAsset
            //have to transfer it here, so I can grab image dimensions
            let imageHeight = lastImageAsset.pixelHeight
            let imageWidth = lastImageAsset.pixelWidth
            
            
            //retreave image URL
            lastImageAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
                if lastImageAsset.mediaType == .image {
                    if let strURL = contentEditingInput?.fullSizeImageURL?.description {
                        self.completeSaving(imageHeight: imageHeight, imageWidth: imageWidth, url: strURL, note: self.canvas.canvasObject)
                    }
                }
            })
        }
        
        
    }

    func completeSaving(imageHeight: Int, imageWidth: Int, url: String, note: CanvasNote){
        ProjectListRepository.instance.updateCanvasUrl(height: imageHeight, width: imageWidth, url: url, note: note)
        //save to data base
        ProjectListRepository.instance.createCanvasNote(canvasNote: note)
        //add action to activity journal
        UserActivitySingleton.shared.createUserActivity(description: "Canvas Note was Created")
        //exit from view
        self.dismiss(animated: true)
    }
    
    //MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        56
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdent, for: indexPath) as! ColorPaletteCell
        cell.template = colorPalette.intToColor[indexPath.item]
        cell.colorButton.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return cell
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 32, height: 32)
    }
    
    
    //MARK: Constrints
    func setupConstraints(){
        
        stackView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        stackView.leadingAnchor.constraint(equalTo: strokeSizeIndicator.trailingAnchor, constant: 15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: strokeSizeIndicator.bottomAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: strokeSizeIndicator.topAnchor, constant: 0).isActive = true
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        colorButton.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 30).isActive = true
        colorButton.centerXAnchor.constraint(equalTo: dismissButton.centerXAnchor).isActive = true
        colorButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        colorButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        strokeSizeButton.topAnchor.constraint(equalTo: strokeSizeIndicator.topAnchor).isActive = true
        strokeSizeButton.centerXAnchor.constraint(equalTo: dismissButton.centerXAnchor).isActive = true
        strokeSizeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        strokeSizeButton.heightAnchor.constraint(equalToConstant: 78).isActive = true
        
        strokeSizeIndicator.topAnchor.constraint(equalTo: colorButton.bottomAnchor, constant: 30).isActive = true
        strokeSizeIndicator.centerXAnchor.constraint(equalTo: dismissButton.centerXAnchor).isActive = true
        strokeSizeIndicator.widthAnchor.constraint(equalToConstant: 32).isActive = true
        strokeSizeIndicator.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        clearButton.topAnchor.constraint(equalTo: strokeSizeButton.bottomAnchor, constant: 30).isActive = true
        clearButton.centerXAnchor.constraint(equalTo: dismissButton.centerXAnchor).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: 29).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: 63).isActive = true
        
        clearButtonTitle.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 5).isActive = true
        clearButtonTitle.centerXAnchor.constraint(equalTo: clearButton.centerXAnchor).isActive = true
        clearButtonTitle.widthAnchor.constraint(equalToConstant: 32).isActive = true
        clearButtonTitle.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        undoButton.topAnchor.constraint(equalTo: clearButtonTitle.bottomAnchor, constant: 30).isActive = true
        undoButton.centerXAnchor.constraint(equalTo: dismissButton.centerXAnchor).isActive = true
        undoButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        undoButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        undoButtonTitle.topAnchor.constraint(equalTo: undoButton.bottomAnchor, constant: 5).isActive = true
        undoButtonTitle.centerXAnchor.constraint(equalTo: undoButton.centerXAnchor).isActive = true
        undoButtonTitle.widthAnchor.constraint(equalToConstant: 32).isActive = true
        undoButtonTitle.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        redoButton.topAnchor.constraint(equalTo: undoButtonTitle.bottomAnchor, constant: 30).isActive = true
        redoButton.centerXAnchor.constraint(equalTo: dismissButton.centerXAnchor).isActive = true
        redoButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        redoButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        redoButtonTitle.topAnchor.constraint(equalTo: redoButton.bottomAnchor, constant: 5).isActive = true
        redoButtonTitle.centerXAnchor.constraint(equalTo: redoButton.centerXAnchor).isActive = true
        redoButtonTitle.widthAnchor.constraint(equalToConstant: 32).isActive = true
        redoButtonTitle.heightAnchor.constraint(equalToConstant: 15).isActive = true

        colorPaletteCollectionView.topAnchor.constraint(equalTo: colorButton.topAnchor).isActive = true
        colorPaletteCollectionView.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 15).isActive = true
        colorPaletteCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        collectionViewHeightAnchor = colorPaletteCollectionView.heightAnchor.constraint(equalToConstant: 400)
        collectionViewHeightAnchor.isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        stackBackgroundView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -10).isActive = true
        stackBackgroundView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 10).isActive = true
        stackBackgroundView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -10).isActive = true
        stackBackgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant:  10).isActive = true
        
    }
}

//MARK: Cell
class ColorPaletteCell: UICollectionViewCell{
    //MARK: Cell Properties
    var template: UIColor? {
        didSet{
            guard let unwrappedTemplate = template else {return}
    
            colorButton.backgroundColor = unwrappedTemplate
        }
    }
    
    var colorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    
    
    //MARK: Cell Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Cell Methods
    func setupViews(){
        
        addSubview(colorButton)
        
        colorButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colorButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        colorButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        colorButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

class StrokeSizeButton: UIView {
    
    lazy var strokeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    var strokeSizeIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 249/255, green: 65/255, blue: 68/255, alpha: 1)
        view.layer.cornerRadius = 7.5
        view.layer.masksToBounds = true
        return view
    }()
    
    var strokeSizeIndicatorWidthAnchor: NSLayoutConstraint!
    var strokeSizeIndicatorHeightAnchor: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        addSubview(strokeView)
        addSubview(strokeSizeIndicator)
        
        
        configureView()
    }
    
    private func configureView(){
        strokeView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        strokeView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        strokeView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        strokeView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        strokeSizeIndicator.centerXAnchor.constraint(equalTo: strokeView.centerXAnchor).isActive = true
        strokeSizeIndicator.centerYAnchor.constraint(equalTo: strokeView.centerYAnchor).isActive = true
        strokeSizeIndicatorWidthAnchor = strokeSizeIndicator.widthAnchor.constraint(equalToConstant: 15)
        strokeSizeIndicatorHeightAnchor = strokeSizeIndicator.heightAnchor.constraint(equalToConstant: 15)
        strokeSizeIndicatorHeightAnchor.isActive = true
        strokeSizeIndicatorWidthAnchor.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
