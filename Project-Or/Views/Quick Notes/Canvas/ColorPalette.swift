//
//  ColorPalette.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 28/12/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit

class ColorPalette {
    let colorToInt: [UIColor: Int] = [
        UIColor.init(red: 249/255, green: 65/255, blue: 68/255, alpha: 1) : 0,
        UIColor.init(red: 243/255, green: 114/255, blue: 44/255, alpha: 1) : 1,
        UIColor.init(red: 248/255, green: 150/255, blue: 30/255, alpha: 1) : 2,
        UIColor.init(red: 249/255, green: 132/255, blue: 74/255, alpha: 1) : 3,
        UIColor.init(red: 249/255, green: 199/255, blue: 79/255, alpha: 1) : 4,
        UIColor.init(red: 144/255, green: 190/255, blue: 109/255, alpha: 1) : 5,
        UIColor.init(red: 67/255, green: 170/255, blue: 139/255, alpha: 1) : 6,
        UIColor.init(red: 77/255, green: 144/255, blue: 142/255, alpha: 1) : 7,
        UIColor.init(red: 87/255, green: 117/255, blue: 144/255, alpha: 1) : 8,
        UIColor.init(red: 39/255, green: 125/255, blue: 161/255, alpha: 1) : 9,
        UIColor.init(red: 204/255, green: 218/255, blue: 209/255, alpha: 1) : 10,
        UIColor.init(red: 156/255, green: 174/255, blue: 169/255, alpha: 1) : 11,
        UIColor.init(red: 120/255, green: 133/255, blue: 133/255, alpha: 1) : 12,
        UIColor.init(red: 111/255, green: 104/255, blue: 102/255, alpha: 1): 13,
        UIColor.init(red: 56/255, green: 48/255, blue: 46/255, alpha: 1): 14,
        UIColor.init(red: 229/255, green: 190/255, blue: 237/255, alpha: 1): 15,
        UIColor.init(red: 149/255, green: 147/255, blue: 217/255, alpha: 1): 16,
        UIColor.init(red: 124/255, green: 144/255, blue: 219/255, alpha: 1): 17,
        UIColor.init(red: 115/255, green: 107/255, blue: 146/255, alpha: 1): 18,
        UIColor.init(red: 125/255, green: 92/255, blue: 101/255, alpha: 1): 19,
        UIColor.init(red: 111/255, green: 29/255, blue: 27/255, alpha: 1): 20,
        UIColor.init(red: 187/255, green: 148/255, blue: 87/255, alpha: 1): 21,
        UIColor.init(red: 67/255, green: 40/255, blue: 24/255, alpha: 1): 22,
        UIColor.init(red: 153/255, green: 88/255, blue: 42/255, alpha: 1): 23,
        UIColor.init(red: 255/255, green: 230/255, blue: 167/255, alpha: 1): 24,
        UIColor.init(red: 214/255, green: 214/255, blue: 214/255, alpha: 1): 25,
        UIColor.init(red: 255/255, green: 238/255, blue: 50/255, alpha: 1): 26,
        UIColor.init(red: 255/255, green: 209/255, blue: 0/255, alpha: 1): 27,
        UIColor.init(red: 32/255, green: 32/255, blue: 32/255, alpha: 1): 28,
        UIColor.init(red: 51/255, green: 53/255, blue: 51/255, alpha: 1): 29,
        UIColor.init(red: 24/255, green: 31/255, blue: 28/255, alpha: 1): 30,
        UIColor.init(red: 39/255, green: 64/255, blue: 41/255, alpha: 1): 31,
        UIColor.init(red: 49/255, green: 92/255, blue: 43/255, alpha: 1): 32,
        UIColor.init(red: 96/255, green: 113/255, blue: 47/255, alpha: 1): 33,
        UIColor.init(red: 158/255, green: 169/255, blue: 63/255, alpha: 1): 34,
        UIColor.init(red: 247/255, green: 37/255, blue: 133/255, alpha: 1): 35,
        UIColor.init(red: 181/255, green: 23/255, blue: 158/255, alpha: 1): 36,
        UIColor.init(red: 114/255, green: 9/255, blue: 183/255, alpha: 1): 37,
        UIColor.init(red: 86/255, green: 11/255, blue: 173/255, alpha: 1): 38,
        UIColor.init(red: 72/255, green: 12/255, blue: 168/255, alpha: 1): 39,
        UIColor.init(red: 58/255, green: 12/255, blue: 163/255, alpha: 1): 40,
        UIColor.init(red: 63/255, green: 55/255, blue: 201/255, alpha: 1): 41,
        UIColor.init(red: 67/255, green: 97/255, blue: 238/255, alpha: 1): 42,
        UIColor.init(red: 72/255, green: 149/255, blue: 239/255, alpha: 1): 43,
        UIColor.init(red: 76/255, green: 201/255, blue: 240/255, alpha: 1): 44,
        UIColor.init(red: 54/255, green: 48/255, blue: 115/255, alpha: 1): 45,
        UIColor.init(red: 219/255, green: 255/255, blue: 0/255, alpha: 1): 46,
        UIColor.init(red: 137/255, green: 131/255, blue: 196/255, alpha: 1): 47,
        UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1): 48,
        UIColor.init(red: 196/255, green: 187/255, blue: 175/255, alpha: 1): 49,
        UIColor.init(red: 165/255, green: 151/255, blue: 139/255, alpha: 1): 50,
        UIColor.init(red: 92/255, green: 71/255, blue: 66/255, alpha: 1): 51,
        UIColor.init(red: 141/255, green: 91/255, blue: 76/255, alpha: 1): 52,
        UIColor.init(red: 90/255, green: 42/255, blue: 39/255, alpha: 1): 53,
        UIColor.init(red: 0/255, green: 52/255, blue: 89/255, alpha: 1): 54,
        UIColor.init(red: 0/255, green: 126/255, blue: 167/255, alpha: 1): 55,
        UIColor.init(red: 0/255, green: 168/255, blue: 232/255, alpha: 1): 56,
    ]
    
    let intToColor: [Int: UIColor] = [
        0 : UIColor.init(red: 249/255, green: 65/255, blue: 68/255, alpha: 1),
        1 : UIColor.init(red: 243/255, green: 114/255, blue: 44/255, alpha: 1),
        2 : UIColor.init(red: 248/255, green: 150/255, blue: 30/255, alpha: 1),
        3 : UIColor.init(red: 249/255, green: 132/255, blue: 74/255, alpha: 1),
        4 : UIColor.init(red: 249/255, green: 199/255, blue: 79/255, alpha: 1),
        5 : UIColor.init(red: 144/255, green: 190/255, blue: 109/255, alpha: 1),
        6 : UIColor.init(red: 67/255, green: 170/255, blue: 139/255, alpha: 1),
        7 : UIColor.init(red: 77/255, green: 144/255, blue: 142/255, alpha: 1),
        8 : UIColor.init(red: 87/255, green: 117/255, blue: 144/255, alpha: 1),
        9 : UIColor.init(red: 39/255, green: 125/255, blue: 161/255, alpha: 1),
        10 : UIColor.init(red: 204/255, green: 218/255, blue: 209/255, alpha: 1),
        11 : UIColor.init(red: 156/255, green: 174/255, blue: 169/255, alpha: 1),
        12 : UIColor.init(red: 120/255, green: 133/255, blue: 133/255, alpha: 1),
        13 : UIColor.init(red: 111/255, green: 104/255, blue: 102/255, alpha: 1),
        14 : UIColor.init(red: 56/255, green: 48/255, blue: 46/255, alpha: 1),
        15 : UIColor.init(red: 229/255, green: 190/255, blue: 237/255, alpha: 1),
        16 : UIColor.init(red: 149/255, green: 147/255, blue: 217/255, alpha: 1),
        17 : UIColor.init(red: 124/255, green: 144/255, blue: 219/255, alpha: 1),
        18 : UIColor.init(red: 115/255, green: 107/255, blue: 146/255, alpha: 1),
        19 : UIColor.init(red: 125/255, green: 92/255, blue: 101/255, alpha: 1),
        20 : UIColor.init(red: 111/255, green: 29/255, blue: 27/255, alpha: 1),
        21 : UIColor.init(red: 187/255, green: 148/255, blue: 87/255, alpha: 1),
        22 : UIColor.init(red: 67/255, green: 40/255, blue: 24/255, alpha: 1),
        23 : UIColor.init(red: 153/255, green: 88/255, blue: 42/255, alpha: 1),
        24 : UIColor.init(red: 255/255, green: 230/255, blue: 167/255, alpha: 1),
        25 : UIColor.init(red: 214/255, green: 214/255, blue: 214/255, alpha: 1),
        26 : UIColor.init(red: 255/255, green: 238/255, blue: 50/255, alpha: 1),
        27 : UIColor.init(red: 255/255, green: 209/255, blue: 0/255, alpha: 1),
        28 : UIColor.init(red: 32/255, green: 32/255, blue: 32/255, alpha: 1),
        29 : UIColor.init(red: 51/255, green: 53/255, blue: 51/255, alpha: 1),
        30 : UIColor.init(red: 24/255, green: 31/255, blue: 28/255, alpha: 1),
        31 : UIColor.init(red: 39/255, green: 64/255, blue: 41/255, alpha: 1),
        32 : UIColor.init(red: 49/255, green: 92/255, blue: 43/255, alpha: 1),
        33 : UIColor.init(red: 96/255, green: 113/255, blue: 47/255, alpha: 1),
        34 : UIColor.init(red: 158/255, green: 169/255, blue: 63/255, alpha: 1),
        35 : UIColor.init(red: 247/255, green: 37/255, blue: 133/255, alpha: 1),
        36 : UIColor.init(red: 181/255, green: 23/255, blue: 158/255, alpha: 1),
        37 : UIColor.init(red: 114/255, green: 9/255, blue: 183/255, alpha: 1),
        38 : UIColor.init(red: 86/255, green: 11/255, blue: 173/255, alpha: 1),
        39 : UIColor.init(red: 72/255, green: 12/255, blue: 168/255, alpha: 1),
        40 : UIColor.init(red: 58/255, green: 12/255, blue: 163/255, alpha: 1),
        41 : UIColor.init(red: 63/255, green: 55/255, blue: 201/255, alpha: 1),
        42 : UIColor.init(red: 67/255, green: 97/255, blue: 238/255, alpha: 1),
        43 : UIColor.init(red: 72/255, green: 149/255, blue: 239/255, alpha: 1),
        44 : UIColor.init(red: 76/255, green: 201/255, blue: 240/255, alpha: 1),
        45 : UIColor.init(red: 54/255, green: 48/255, blue: 115/255, alpha: 1),
        46 : UIColor.init(red: 219/255, green: 255/255, blue: 0/255, alpha: 1),
        47 : UIColor.init(red: 137/255, green: 131/255, blue: 196/255, alpha: 1),
        48 : UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1),
        49 : UIColor.init(red: 196/255, green: 187/255, blue: 175/255, alpha: 1),
        50 : UIColor.init(red: 165/255, green: 151/255, blue: 139/255, alpha: 1),
        51 : UIColor.init(red: 92/255, green: 71/255, blue: 66/255, alpha: 1),
        52 : UIColor.init(red: 141/255, green: 91/255, blue: 76/255, alpha: 1),
        53 : UIColor.init(red: 90/255, green: 42/255, blue: 39/255, alpha: 1),
        54 : UIColor.init(red: 0/255, green: 52/255, blue: 89/255, alpha: 1),
        55 : UIColor.init(red: 0/255, green: 126/255, blue: 167/255, alpha: 1),
        56 : UIColor.init(red: 0/255, green: 168/255, blue: 232/255, alpha: 1),
    ]
}
