//
//  KWGameVC.swift
//  KittyWar
//
//  Created by Hejia Su on 11/9/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit

class KWCatPickingTableViewCell: UITableViewCell {
    @IBOutlet private weak var catImageView: UIImageView!
    @IBOutlet private weak var catNameLabel: UILabel!
    
    func setCatImage(catImage: UIImage) {
        catImageView.image = catImage
    }
    
    func setCatName(name: String) {
        catNameLabel.text = name
    }
    
}

class KWGameVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var playerView: UIView!
    @IBOutlet private weak var playerCatImageView: UIImageView!
    @IBOutlet private weak var playerCatNameLabel: UILabel!
    @IBOutlet private weak var playerCatAbilityOneLabel: UILabel!
    @IBOutlet private weak var playerCatAbilityTwoLabel: UILabel!
    @IBOutlet private weak var playerCatHPLabel: UILabel!
    @IBOutlet private weak var playerChanceCardCollectionView: UICollectionView!
    
    @IBOutlet private weak var opponentView: UIView!
    @IBOutlet private weak var opponentCatImageView: UIImageView!
    @IBOutlet private weak var opponentCatNameLabel: UILabel!
    @IBOutlet private weak var opponentCatAbilityOneLabel: UILabel!
    @IBOutlet private weak var opponentCatHPLabel: UILabel!
    
    @IBOutlet weak var catPickingView: UIView!
    @IBOutlet weak var catPickingTableView: UITableView!
    @IBOutlet weak var pickedCatNameLabel: UILabel!
    
    struct StoryBoard {
        static let catPickingTableViewCellIdentifier = "Cat Picking Cell"
    }
    
    var availableCats = [KWCat]()
    var abilities = [KWAbility]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide player view and opponent view, only show cat picking view
        playerView.isHidden = true
        opponentView.isHidden = true
        catPickingView.isHidden = false
        
        // cat picking table view data source & delegate
        catPickingTableView.dataSource = self
        catPickingTableView.delegate = self
        
        // setup available cats
        setupAvailableCats()
        
        playerChanceCardCollectionView.dataSource = self
        playerChanceCardCollectionView.delegate = self
    }
    
    private func setupAvailableCats() {
        
    }
    
    @IBAction func fight(_ sender: UIButton) {
        
    }
    
    @IBAction func basicMoveButtenPressed(_ sender: UIButton) {
        
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableCats.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return KWCatPickingTableViewCell()
    }

    
    // MARK: - UITableViewDelegate
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

}
