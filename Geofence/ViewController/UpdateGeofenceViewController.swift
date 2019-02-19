//
//  UpdateGeofenceViewController.swift
//  Geofence
//
//  Created by Woon on 19/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UpdateGeofenceViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBinding()
    }
    
    private func setupBinding() {
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: bag)
    }
    
    deinit {
        print("deinit: \(String(describing: type(of: self)))")
    }
}
