//
//  MapPinExtension.swift
//  VirtualTourist
//
//  Created by Timothy Isenman on 5/15/18.
//  Copyright © 2018 Timothy Isenman. All rights reserved.
//

import Foundation
import CoreData

extension LocationPin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
