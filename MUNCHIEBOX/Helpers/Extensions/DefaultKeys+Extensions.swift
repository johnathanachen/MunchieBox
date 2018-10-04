//
//  DefaultKeys+Extensions.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 5/20/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let sessionToken = DefaultsKey<Bool>("sessionToken")
    
    static let userPhoneNumber = DefaultsKey<String>("userPhoneNumber")
    static let profileName = DefaultsKey<String>("profileName")
    
    static let openLaterSetting = DefaultsKey<Bool>("openLaterSetting")
    static let notInCity = DefaultsKey<Bool>("userCity")
    static let cityVerified = DefaultsKey<Bool>("cityVerified")
}
