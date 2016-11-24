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

class KWGameVC: KWAlertVC, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {

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
    
    var availableCats = [KWCatCard]()
    var abilities = [KWAbilityCard]()
    var chanceCards = [KWChanceCard]()
    var playerCat: KWCatCard? = nil
    var playerCatHP: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide player view and opponent view, only show cat picking view
        playerView.isHidden = true
        opponentView.isHidden = true
        catPickingView.isHidden = false
        
        // setup cat picking view
        catPickingView.layer.borderWidth = 1
        catPickingView.layer.borderColor = UIColor(red:255/255.0, green:128/255.0, blue:0/255.0, alpha: 1.0).cgColor
        
        // setup available cats
        setupAvailableCats()
        
        // cat picking table view data source & delegate
        catPickingTableView.dataSource = self
        catPickingTableView.delegate = self
        
        playerChanceCardCollectionView.dataSource = self
        playerChanceCardCollectionView.delegate = self
    }
    
    private func setupAvailableCats() {
        // persian cat
        let persianCat = KWCatCard()
        persianCat.health = 8
        persianCat.title = "Persian Cat"
        persianCat.introduction = "The Persian cat is a long-haired breed of cat characterized by its round face and short muzzle. The Persian is generally described as a quiet cat. Typically placid in nature, it adapts quite well to apartment life."
        persianCat.inbornAbilityID = 0
        persianCat.catID = 0
        availableCats.append(persianCat)
        
        // ragdoll cat
        let ragdollCat = KWCatCard()
        ragdollCat.health = 10
        ragdollCat.title = "Ragdoll Cat"
        ragdollCat.introduction = "The Ragdoll's sweet temperament is probably its most outstanding trait. Ragdolls are large, bulky and handsome cats. They have been commonly referred to as \"the gentle giants\" - because in spite of their handsomeness and grace, they are extremely even-tempered and docile."
        ragdollCat.inbornAbilityID = 1
        ragdollCat.catID = 1
        availableCats.append(ragdollCat)
    }
    
    @IBAction func fight(_ sender: UIButton) {
        if selectedCatID == nil {
            return
        }
        
        // register to notification center
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(KWGameVC.handleSelectCatResult(notification:)),
                       name: selectCatResultNotification,
                       object: nil)

        
        KWNetwork.shared.selectCat(catID: selectedCatID!)
    }
    
    func handleSelectCatResult(notification: Notification) {
        if let result = notification.userInfo?[InfoKey.result] as? SelectCatResult {
            switch result {
            case .success:
                // get cat
                playerCat = availableCats[selectedCatID!]
                
                // wait for next response
                
                // hide cat picking table view & show game views
//                catPickingTableView.isHidden = true
//                playerView.isHidden = false
//                opponentView.isHidden = false
                
                // setup UI
                break
            case .failure:
                // alert fail
                showAlert(title: "Select Cat Failed",
                          message: "Select Cat Failed")
                break
            }
        }
    }
    
    @IBAction func basicMoveButtenPressed(_ sender: UIButton) {
        
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == catPickingTableView {
            return availableCats.count
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let catCard = availableCats[indexPath.row]
        
        // get the cat picking cell
        let cell = catPickingTableView.dequeueReusableCell(withIdentifier: StoryBoard.catPickingTableViewCellIdentifier) as! KWCatPickingTableViewCell
        
        // add the right information
        cell.setCatName(name: catCard.title)
        cell.setCatImage(catImage: UIImage(named: catCard.title)!)
        
        return cell
    }

    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == catPickingTableView {
            return 120
        }
        
        return 44
    }
    
    private var selectedCatID: Int? = nil
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == catPickingTableView {
            let catCard = availableCats[indexPath.row]
            selectedCatID = catCard.catID
            pickedCatNameLabel.text = "Picked \(catCard.title)"
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

}
