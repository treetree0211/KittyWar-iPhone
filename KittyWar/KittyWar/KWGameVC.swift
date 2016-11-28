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

class KWChanceCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var chanceCardImageView: UIImageView!
}

class KWGameVC: KWAlertVC, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var playerView: UIView!
    @IBOutlet private weak var playerCatImageView: UIImageView!
    @IBOutlet private weak var playerCatNameLabel: UILabel!
    @IBOutlet private weak var playerCatHPLabel: UILabel!
    @IBOutlet private weak var playerCatBornWithAbilityButton: UIButton!
    @IBOutlet private weak var playerCatRandomAbilityButton: UIButton!
    @IBOutlet private weak var playerChanceCardCollectionView: UICollectionView!
    
    @IBOutlet private weak var opponentView: UIView!
    @IBOutlet private weak var opponentCatImageView: UIImageView!
    @IBOutlet private weak var opponentCatNameLabel: UILabel!
    @IBOutlet private weak var opponentCatHPLabel: UILabel!
    @IBOutlet weak var opponentCatAbilityImageView: UIImageView!
    
    @IBOutlet weak var catPickingView: UIView!
    @IBOutlet weak var catPickingTableView: UITableView!
    @IBOutlet weak var pickedCatNameLabel: UILabel!
    
    struct StoryBoard {
        static let catPickingTableViewCellIdentifier = "Cat Picking Cell"
        static let chanceCardCollectionViewCellIdentifier = "Chance Card Cell"
    }
    
    var availableCats = [KWCatCard]()
    var availableAbilities = [KWAbilityCard]()
    var availableChanceCards = [KWChanceCard]()
    
    var playerCat: KWCatCard? = nil
    var playerCatHP: Int = 0 {
        didSet {
            playerCatHPLabel.text = "HP: \(playerCatHP)"
        }
    }
    
    var playerCatAbilities = [KWAbilityCard]()
    var playerChanceCards = [KWChanceCard]()

    var opponentCat: KWCatCard? = nil
    var opponentCatHP: Int = 0 {
        didSet {
            opponentCatHPLabel.text = "HP: \(opponentCatHP)"
        }
    }
    
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
        
        // setup available abilities
        setupAvailableAbilities()
        
        // setup available chance cards
        setupAvailableChanceCards()
        
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
    
    private func setupAvailableAbilities() {
        // rejuvenation
        let rejuvenation = KWAbilityCard()
        rejuvenation.title = "Rejuvenation"
        rejuvenation.id = 0
        rejuvenation.phase = 5
        rejuvenation.coolDown = 10
        rejuvenation.introduction = "Gain 1 HP"
        availableAbilities.append(rejuvenation)
        
        // gentleman
        let gentleman = KWAbilityCard()
        gentleman.title = "Gentleman"
        gentleman.id = 1
        gentleman.phase = 0
        gentleman.coolDown = 1
        gentleman.introduction = "Gain 1 chance card if you successfully dodge two points damage"
        availableAbilities.append(gentleman)
        
        // hunting
        let hunting = KWAbilityCard()
        availableAbilities.append(hunting)
        
        // recycling
        let recycling = KWAbilityCard()
        availableAbilities.append(recycling)
        
        // loneliness
        let loneliness = KWAbilityCard()
        availableAbilities.append(loneliness)
        
        // spotlight
        let spotlight = KWAbilityCard()
        availableAbilities.append(spotlight)
        
        // attacker
        let attacker = KWAbilityCard()
        attacker.title = "Attacker"
        attacker.id = 6
        attacker.phase = 0
        attacker.coolDown = 1
        attacker.introduction = "Double the damage you cause in current round (work together with Double Scratch chance card) at the cost of losing 1 HP (lose 1 HP at postlude phase)"
        availableAbilities.append(attacker)
        
        // critical hit
        let criticalHit = KWAbilityCard()
        criticalHit.title = "Critical Hit"
        criticalHit.id = 7
        criticalHit.phase = 1
        criticalHit.coolDown = 10
        criticalHit.introduction = "Double the damage you cause in current round (work together with Double Scratch chance card) at the cost of losing 1 HP (lose 1 HP at postlude phase)"
        availableAbilities.append(criticalHit)
    }
    
    private func setupAvailableChanceCards() {
        // double purring
        let doublePurring = KWChanceCard()
        doublePurring.title = "Double Purring"
        doublePurring.id = 0
        doublePurring.type = "Purr Chance"
        doublePurring.introduction = "Totally gain 2 HP if you don't get attacked"
        doublePurring.basicCardID = 0
        availableChanceCards.append(doublePurring)
        
        // guaranteed purring
        let guaranteedPurring = KWChanceCard()
        guaranteedPurring.title = "Guaranteed Purring"
        guaranteedPurring.id = 1
        guaranteedPurring.type = "Purr Chance"
        guaranteedPurring.introduction = "Totally gain 1 HP no matter you get attacked or not"
        guaranteedPurring.basicCardID = 0
        availableChanceCards.append(guaranteedPurring)
        
        // purr and draw
        let purrAndDraw = KWChanceCard()
        purrAndDraw.title = "Purr and Draw"
        purrAndDraw.id = 2
        purrAndDraw.type = "Purr Chance"
        purrAndDraw.introduction = "Draw a new chance card if successfully gain 1 HP"
        purrAndDraw.basicCardID = 0
        availableChanceCards.append(purrAndDraw)
        
        // reverse scratch
        let reverseScratch = KWChanceCard()
        reverseScratch.title = "Reverse Scratch"
        reverseScratch.id = 3
        reverseScratch.type = "Guard Chance"
        reverseScratch.introduction = "Reverse the damage"
        reverseScratch.basicCardID = 1
        availableChanceCards.append(reverseScratch)
        
        // guard and heal
        let guardAndHeal = KWChanceCard()
        guardAndHeal.title = "Guard and Heal"
        guardAndHeal.id = 4
        guardAndHeal.type = "Guard Chance"
        guardAndHeal.introduction = "Totally gain 1 HP if you successfully dodge"
        guardAndHeal.basicCardID = 1
        availableChanceCards.append(guardAndHeal)
        
        // guard and draw
        let guardAndDraw = KWChanceCard()
        guardAndDraw.title = "Guard and Draw"
        guardAndDraw.id = 5
        guardAndDraw.type = "Guard Chance"
        guardAndDraw.introduction = "Draw a new chance card if you successfully dodge"
        guardAndDraw.basicCardID = 1
        availableChanceCards.append(guardAndDraw)
        
        // can't reverse
        let cantReverse = KWChanceCard()
        cantReverse.title = "Can't Reverse"
        cantReverse.id = 6
        cantReverse.type = "Scratch Chance"
        cantReverse.introduction = "Damage can't be reversed"
        cantReverse.basicCardID = 2
        availableChanceCards.append(cantReverse)
        
        // can't guard
        let cantGuard = KWChanceCard()
        cantGuard.title = "Can't Guard"
        cantGuard.id = 7
        cantGuard.type = "Scratch Chance"
        cantGuard.introduction = "Scratch can't be dodged"
        cantGuard.basicCardID = 2
        availableChanceCards.append(cantGuard)
        
        // double scratch
        let doubleScratch = KWChanceCard()
        doubleScratch.title = "Double Scratch"
        doubleScratch.id = 8
        doubleScratch.type = "Scratch Chance"
        doubleScratch.introduction = "Totally cause 2 points damage"
        doubleScratch.basicCardID = 2
        availableChanceCards.append(doubleScratch)
    }
    
    // 1. next phase response (98) 2. opponent cat id(49) 3. random ability 4. chance cards
    @IBAction func fight(_ sender: UIButton) {
        print("Selected cat id: \(selectedCatID!)")
        
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
                
                // add cat's born with ability
                playerCatAbilities.append(availableAbilities[playerCat!.inbornAbilityID])
                
                // register to notification center
                let nc = NotificationCenter.default
                nc.addObserver(self,
                               selector: #selector(KWGameVC.handleSetupGameNotification(notification:)),
                               name: setupGameNotification,
                               object: nil)
                
                // send ready for cat selection
                KWNetwork.shared.sendReadyForCatSelectionMessageToGameServer()
                break
            case .failure:
                // alert fail
                showAlert(title: "Select Cat Failed",
                          message: "Select Cat Failed")
                break
            }
        }
    }
    
    // setup game!
    func handleSetupGameNotification(notification: Notification) {
        let opponentCatID = notification.userInfo?[InfoKey.opponentCatID] as! Int
        let randomAbilityID = notification.userInfo?[InfoKey.randomAbilityID] as! Int
        let chanceCards = notification.userInfo?[InfoKey.chanceCards] as! [Int]
        
        // hide cat picking table view & show game views
        catPickingView.isHidden = true
        playerView.isHidden = false
        opponentView.isHidden = false
        
        // setup opponent view
        opponentCat = availableCats[opponentCatID]
        opponentCatImageView.image = UIImage(named: opponentCat!.title)
        opponentCatNameLabel.text = opponentCat!.title
        opponentCatHP = opponentCat!.health
        opponentCatAbilityImageView.image = UIImage(named: availableAbilities[opponentCat!.inbornAbilityID].title)
        
        // setup player view
        playerCatImageView.image = UIImage(named: playerCat!.title)
        playerCatNameLabel.text = playerCat!.title
        playerCatHP = playerCat!.health
        
        playerCatAbilities.append(availableAbilities[randomAbilityID])
        playerCatBornWithAbilityButton.setImage(UIImage(named: playerCatAbilities[0].title), for: .normal)
        playerCatRandomAbilityButton.setImage(UIImage(named: playerCatAbilities[1].title), for: .normal)
        
        playerChanceCards.append(availableChanceCards[chanceCards[0]])
        playerChanceCards.append(availableChanceCards[chanceCards[1]])
        playerChanceCardCollectionView.reloadData()
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
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if tableView == catPickingTableView {
            let catCard = availableCats[indexPath.row]
            selectedCatID = catCard.catID
            pickedCatNameLabel.text = "Picked \(catCard.title)"
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerChanceCards.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryBoard.chanceCardCollectionViewCellIdentifier,
                                                      for: indexPath) as! KWChanceCardCollectionViewCell
        cell.chanceCardImageView.image = UIImage(named: playerChanceCards[indexPath.row].title)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width - 3 * 8
        let height: CGFloat = width / 3 * 4
        
        return CGSize(width: width, height: height)
    }

}
