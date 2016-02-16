//
//  STYLES.swift
//  auth_app
//
//  Created by DASON ADAMOS on 12/20/15.
//  Copyright © 2015 DASON ADAMOS. All rights reserved.
//

import Foundation

public class STYLES
{
    public struct FontStyle
    {
        var color : UIColor
        var background_color : UIColor
    }
    
    private static let LABEL_CORNER_RADIUS = 7
    
    public static let SUCCESS = FontStyle (
        color: UIColor(red: 161/255, green: 212/255, blue: 144/255, alpha: 1),
        background_color: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
    
    public static let FAILURE = FontStyle (
        color: UIColor(red: 227/255, green: 148/255, blue: 148/255, alpha: 1),
        background_color: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
    
    public static let WARNING = FontStyle (
        color: UIColor(red: 235/255, green: 199/255, blue: 134/255, alpha: 1),
        background_color: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
    
    public static func SetLabelStyle (label : UILabel, style : FontStyle, invert : Bool)
    {
        if invert
        {
            label.textColor = style.background_color
            label.layer.backgroundColor = style.color.CGColor
        }
        else
        {
            label.layer.backgroundColor = style.background_color.CGColor
            label.textColor = style.color
        }
        label.layer.cornerRadius = CGFloat(LABEL_CORNER_RADIUS)
    }
}