//
//  ViewController.swift
//  SwiftyColorKit
//
//  Created by MHN on 06/29/2023.
//  Copyright (c) 2023 MHN. All rights reserved.
//

import UIKit
import SwiftyColorKit

class ViewController: UIViewController {
    
    private var imagePaths: [String] = []
    private var currentIndex: Int = .zero

    // MARK: Outlets
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgMain: UIImageView! {
        didSet {
            // Just to make the corners of the ImageView round
            self.imgMain.layer.cornerRadius = 5
            
            // Swipe left gesture recognizer
            let slRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipedLeft))
            slRecognizer.direction = .left
            self.imgMain.addGestureRecognizer(slRecognizer)
            
            
            // Swipe right gesture recognizer
            let srRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipedRight))
            srRecognizer.direction = .right
            self.imgMain.addGestureRecognizer(srRecognizer)
            
            
            // Tap gesture recognizer
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSwipedLeft))
            self.imgMain.addGestureRecognizer(tapRecognizer)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupImagePaths()
        
        if let path = self.imagePaths.first {
            self.onNewImage(withPath: path)
        }
    }
    
    @objc private func onSwipedLeft() {
        self.currentIndex = (self.currentIndex + 1) % self.imagePaths.count
        self.onNewImage(withPath: self.imagePaths[self.currentIndex])
    }
    
    
    @objc private func onSwipedRight() {
        self.currentIndex = self.currentIndex == 0 ? (self.imagePaths.count - 1) : (self.currentIndex - 1)
        self.onNewImage(withPath: self.imagePaths[self.currentIndex])
    }
    
    
    private func onNewImage(withPath path: String) {
        guard let image = UIImage(contentsOfFile: path) else { return }
        UIView.animate(withDuration: 0.3) {
            self.imgMain.image = image
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let index = self?.currentIndex
            guard let colors = try? image.dominantColors(with: .best) else { return }
            DispatchQueue.main.async { [weak self] in
                guard self?.currentIndex == index else { return }
                self?.setBackground(withColors: colors)
            }
        }
    }
    
    
    private func setBackground(withColors colors: [UIColor]) {
        // Remove old layers
        self.viewContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradient = CAGradientLayer()
        gradient.frame = self.viewContainer.bounds
        gradient.colors = colors.map(\.cgColor)
        
        UIView.animate(withDuration: 0.3) {
            self.viewContainer.layer.insertSublayer(gradient, at: .zero)
        }
    }
}


// MARK: Image Importer
fileprivate extension ViewController {
    func setupImagePaths() {
        var paths: [String] = []
        for i in 1...30 {
            let path = Bundle.main.path(forResource: "image-\(i)", ofType: "jpg")!
            paths.append(path)
        }
        self.imagePaths = paths
    }
}
