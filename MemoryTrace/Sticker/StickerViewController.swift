//
//  StickerViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/14.
//

import UIKit

protocol StickerViewControllerDelegate: AnyObject {
    func dismissStickerView()
    func selectSticker(image: UIImage)
}

class StickerViewController: UIViewController {
    
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var firstButton: UIButton!
    
    @IBOutlet var buttons: [UIButton]!
    weak var delegate: StickerViewControllerDelegate?
    
    private lazy var currentButton: UIButton = UIButton()
    private var buttonImageNames: [String] = ["alphabet_0", "alphabet_capital", "ta-da_preview", "line_0",  "round_1", "music_preview", "nature_preview",]
    private lazy var stickerNames: [[String]] = [["alphabet_a","alphabet_b","alphabet_c","alphabet_d","alphabet_e","alphabet_f","alphabet_g","alphabet_h","alphabet_i","alphabet_j","alphabet_k","alphabet_l","alphabet_m","alphabet_n","alphabet_o","alphabet_p","alphabet_q","alphabet_r","alphabet_s","alphabet_t","alphabet_u","alphabet_v","alphabet_w","alphabet_x","alphabet_y","alphabet_z"], ["alphabet_A","alphabet_B","alphabet_C","alphabet_D","alphabet_E","alphabet_F","alphabet_G","alphabet_H","alphabet_I","alphabet_J","alphabet_K","alphabet_L","alphabet_M","alphabet_N","alphabet_O","alphabet_P","alphabet_Q","alphabet_R","alphabet_S","alphabet_T","alphabet_U","alphabet_V","alphabet_W","alphabet_X","alphabet_Y","alphabet_Z"],["Sticker","Sticker-1","Sticker-2","Sticker-3","Sticker-4","Sticker-5","Sticker-6","Sticker-7"],["line_1","line_2","line_3","line_4","line_5","line_6","line_7","line_8","line_9","line_10"],["round_1","round_2","round_3","round_4","round_5","roundring_1","roundring_2","roundring_3","roundring_4","roundring_5"],["Music_01","Music_02","Music_03","Music_04","Music_05","Music_06","Music_07","Music_08","Music_09","Music_10","Music_11","Music_12","Music_13","Music_14","Music_15","Music_16","Music_17","Music_18","Music_19","Music_20","Music_21","Music_22","Music_23","Music_24"], ["Nature_01","Nature_02","Nature_03","Nature_04","Nature_05","Nature_06","Nature_07","Nature_08","Nature_09","Nature_10","Nature_11","Nature_12"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerCollectionView.delegate = self
        stickerCollectionView.dataSource = self
        stickerCollectionView.collectionViewLayout = StickerViewLayout()
        self.view.layer.cornerRadius = 10
        
        buttons.forEach { button in
            let origImage = UIImage(named: buttonImageNames[button.tag])
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            button.setImage(tintedImage, for: .normal)
            
            if button.tag == 0 {
                button.tintColor = UIColor.init(white: 1, alpha: 1)
            } else {
                button.tintColor = UIColor.init(white: 1, alpha: 0.5)
            }
        }

        currentButton = firstButton
    }
    
    @IBAction func didPressCloseButton(_ sender: UIButton) {
        delegate?.dismissStickerView()
    }
    
    @IBAction func didPressButton(_ sender: UIButton) {
        currentButton.tintColor = UIColor.init(white: 1, alpha: 0.5)
        sender.tintColor = UIColor.init(white: 1, alpha: 1)
        stickerCollectionView.scrollToItem(at: IndexPath(item: sender.tag, section: 0), at: .centeredHorizontally, animated: false)
        currentButton = sender
    }
}

extension StickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return 7
        } else {
            return stickerNames[collectionView.tag-1].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerViewCell", for: indexPath) as! StickerViewCell
            cell.collectionView.tag = indexPath.row + 1
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            
            return cell
        } else {
            let stickerName = stickerNames[collectionView.tag - 1][indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
            
            if let sticker = UIImage(named: stickerName) {
                cell.stickerImageView.image = sticker
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag != 0 {
            let stickerName = stickerNames[collectionView.tag-1][indexPath.row]
            guard let sticker = UIImage(named: stickerName) else { return }
            delegate?.selectSticker(image: sticker)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            let idx = Int(scrollView.contentOffset.x / stickerCollectionView.frame.width)
            currentButton.tintColor = UIColor.init(white: 1, alpha: 0.5)
            buttons[idx].tintColor = UIColor.init(white: 1, alpha: 1)
            currentButton = buttons[idx]
        }
    }
}
