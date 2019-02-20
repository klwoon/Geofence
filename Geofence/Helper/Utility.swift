//
//  Utility.swift
//  Geofence
//
//  Created by Woon on 19/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

struct AlertContent {
    let title: String
    let message: String
    let okAction: AlertAction?
    let cancelAction: AlertAction?
    
    init(title: String, message: String, okAction: AlertAction, cancelAction: AlertAction? = nil) {
        self.title = title
        self.message = message
        self.okAction = okAction
        self.cancelAction = cancelAction
    }
}

struct AlertAction {
    let title: String
    let action: (() -> Void)?
    
    init(title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }
}

protocol AlertDialogPresenter {
    func showSingleActionAlert(dialog: AlertContent)
    func showDoubleActionAlert(dialog: AlertContent)
}

extension AlertDialogPresenter where Self: UIViewController {

    func showSingleActionAlert(dialog: AlertContent) {
        let alert = UIAlertController(title: dialog.title,
                                      message: dialog.message,
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: dialog.okAction?.title,
                               style: .default,
                               handler: { _ in dialog.okAction?.action?()})
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    func showDoubleActionAlert(dialog: AlertContent) {
        let alert = UIAlertController(title: dialog.title,
                                      message: dialog.message,
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: dialog.okAction?.title,
                               style: .default,
                               handler: { _ in dialog.okAction?.action?()})
        let cancel = UIAlertAction(title: dialog.cancelAction?.title,
                                   style: .default,
                                   handler: { _ in dialog.cancelAction?.action?()})
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

extension UIApplication {
    
    @discardableResult
    static func openAppSettings() -> Bool {
        guard
            let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                return false
        }
        UIApplication.shared.open(url)
        return true
    }
}

struct Utility {
    
    static func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
}
