//
//  MCController.swift
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let CellID = "PhotoCell";

class MCController: UIViewController {
    // 插座属性
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: 数据
    var imageModels:Array<PhotoAssetsModel> = []
    // 选择分享模型
    var shareIamgesModel: Array<PhotoAssetsModel> = []
    // 接收分享的模型
    var reciveImageModel: Array<PhotoAssetsModel> = []
    
    // MARK: 与传输有关
    let serviceType = "HG-FileConnet"
    var peerID: MCPeerID!
    var session: MCSession!
    // 接受方
    var advertiser: MCNearbyServiceAdvertiser!
    // 邀请方
    var browser: MCNearbyServiceBrowser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 注册cell
        collectionView.register(UINib(nibName: CellID, bundle: nil), forCellWithReuseIdentifier: CellID)
        
        // 初始化
        let displayName = UIDevice.current.name
        peerID = MCPeerID(displayName: displayName)
        
        // 接收
        session = MCSession(peer: peerID)
        session.delegate = self
        
        // 接收方
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self

    }
    
    // 开启面对面 有点乱, 但是能通就行
    @IBAction func openShare(_ sender: UIButton) {
        // 先停止
        disConnect()
        
        // 开始接收
        advertiser.startAdvertisingPeer()
        
        // 开始邀请
        browser.startBrowsingForPeers()
    }
    
    func disConnect() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
    }
    
    // 选择照片
    @IBAction func beginSelectPhotos(_ sender: UIButton) {
        DispatchQueue.global().async {
            PhotoAssets.getAllOriginalImages(targetThumbSize: CGSize(width: 50, height: 50), isLoadVideo: false) { (photoArray) in
                
                self.imageModels = photoArray as! Array<PhotoAssetsModel>
                self.collectionView.reloadData()
            }
        }
    }
    
    // 分享照片
    @IBAction func beiginSharePhotos(_ sender: UIButton) {
        
        if self.shareIamgesModel.count == 0 {
            EXPTip(tips: "请选择分享图片")
            return
        }
        
        if self.session.connectedPeers.count == 0 {
            EXPTip(tips: "当前没有连接对象")
        }
        
        // 分享图片
        self.shareIamgesModel.flatMap { (model) -> UIImage? in
            return model.origImage
            }.map { (image) -> Void in
                if let imageData = UIImageJPEGRepresentation(image, 0.9) {
                    try? self.session.send(imageData, toPeers: self.session.connectedPeers, with: .unreliable)
                } else if let imageData = useImage(image: image) {
                    try? self.session.send(imageData, toPeers: self.session.connectedPeers, with: .unreliable)
                }
        }
    }
    
    // 清除照片
    @IBAction func cleanPhotos(_ sender: UIButton) {
        imageModels = []
        shareIamgesModel = []
        collectionView.reloadData()
    }
    
    // 清除选择照片
    @IBAction func cleanSelectPhotos(_ sender: UIButton) {
        shareIamgesModel = []
        imageModels = imageModels.flatMap { (model) -> PhotoAssetsModel in
            model.selected = false
            return model
        }
        collectionView.reloadData()
    }
    
}

// MARK: 代理
extension MCController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        cell.photoModel.selected = !cell.photoModel.selected
        
        if !self.shareIamgesModel.contains(cell.photoModel) {
            self.shareIamgesModel.append(cell.photoModel)
            cell.selectButton.isHidden = false
        } else {
            self.shareIamgesModel = self.shareIamgesModel.flatMap({ (model) -> PhotoAssetsModel? in
                if model != cell.photoModel {
                    return model
                }
                return nil
            })
            cell.selectButton.isHidden = true
        }
    }
}

extension MCController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath) as! PhotoCell
        cell.photoModel = self.imageModels[indexPath.item]
        return cell
    }


}

// MARK:接收数据 - MCSessionDelegate
extension MCController: MCSessionDelegate {
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    // 链接状态
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                EXPTip(tips: peerID.displayName + "已连接")
            case .connecting:
                EXPTip(tips: peerID.displayName + "连接中")
            case .notConnected:
                EXPTip(tips: peerID.displayName + "连接失败")
                
            }
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    // 接受数据
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if let image = UIImage(data: data) {
                print("接受到数据")
                let photoModel = PhotoAssetsModel()
                photoModel.origImage = image
                self.imageModels.append(photoModel)
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: 接收邀请 - MCNearbyServiceAdvertiserDelegate
extension MCController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("接受设备")
        let alertVC = UIAlertController(title: "是否接受", message: peerID.displayName, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "是", style: .default) { (action) in
            invitationHandler(true, self.session)
        }
        let action2 = UIAlertAction(title: "否", style: .default) { (action) in
            invitationHandler(false, nil)
        }
        alertVC.addAction(action1)
        alertVC.addAction(action2)
        self.present(alertVC, animated: true, completion: nil)
    }
}

// MARK: 发出邀请 - MCNearbyServiceBrowserDelegate
extension MCController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        print("发现设备")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 20)
    }
}

