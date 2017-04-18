import Foundation
import UIKit

//Store how all buttons and UI elements are positioned in keyboard
struct Padding {
    var numberPads = NumberPads()
    var sidePanels = SidePanels()
    var spaceRegion = SpaceRegion()
    struct SpaceRegion {
        enum Keys {
            case global, space, switchKey
        }
        var numberPads = NumberPads()
        static let spaceWidth: CGFloat = 126.0
        static let spaceRegionVerticalSpacing: CGFloat = 10.0
        static let spaceRegionHorizontalSpacing: CGFloat = 10.0
        static let globalDimentions: (width: CGFloat, height: CGFloat) = (width: 30.0, height: 30.0)
        static let switchKeyDimentions: (width: CGFloat, height: CGFloat) = (width: 30.0, height: 30.0)
        var space: (left: CGFloat, top: CGFloat) {
            get {
                return (
                    left: UIScreen.main.bounds.width / 2 - SpaceRegion.spaceWidth / 2,
                    top: numberPads.forNumber(num: 9).top + NumberPads.buttonHeight + SpaceRegion.spaceRegionVerticalSpacing
                )
            }
        }
        var global: (left: CGFloat, top: CGFloat) {
            get {
                return (
                    left: space.left - SpaceRegion.spaceRegionHorizontalSpacing - SpaceRegion.globalDimentions.width,
                    top: space.top
                )
            }
        }
        var switchKey: (left: CGFloat, top: CGFloat) {
            get {
                return (
                    left: space.left + SpaceRegion.spaceWidth + SpaceRegion.spaceRegionHorizontalSpacing,
                    top: space.top
                )
            }
        }
        
    }
    struct SidePanels {
        enum Regions {
            case left, right, top
        }
        
        var baseWidth: CGFloat {
            get {
                return UIScreen.main.bounds.width
            }
        }
        
        var leftRegion = LeftRegion()
        var topRegion = TopRegion()
        var rightRegion = RightRegion()
        
        static let leftRegionSpacing: CGFloat = 8.0
        static let rightRegionSpacing: CGFloat = 8.0
        static let leftRegionWidth: CGFloat = (50.0 / 320.0) * UIScreen.main.bounds.width
        static let rightRegionWidth: CGFloat = (50.0 / 320.0) * UIScreen.main.bounds.width
        static let topRegionHeight: CGFloat = 70.0
        
        func forRegions(reg: Regions) -> (left: CGFloat, top: CGFloat) {
            switch reg {
            case .left:
                return (left: 0.0, top: SidePanels.topRegionHeight)
            case .right:
                return (left: baseWidth - SidePanels.rightRegionWidth, top: SidePanels.topRegionHeight)
            case .top:
                return (left: 0.0, top: 0.0)
            }
        }
        
        struct TopRegion {
            var displayWidth: CGFloat {
                get {
                    return (240.0 / 320.0) * UIScreen.main.bounds.width
                }
            }
            
            var predictWidth: CGFloat {
                get {
                    return (80.0 / 320.0) * UIScreen.main.bounds.width
                }
            }
            
            static let buttonsDimensions: (width: CGFloat, height: CGFloat) = (width: (40.0 / 320.0) * UIScreen.main.bounds.width,
                                                                               height: SidePanels.topRegionHeight / 2)
            static let predictDimensions: (width: CGFloat, height: CGFloat) = (width: (80.0 / 320.0) * UIScreen.main.bounds.width,
                                                                               height: SidePanels.topRegionHeight / 2)
            static let charDimensions: (width: CGFloat, height: CGFloat) = (width: (60.0 / 320.0) * UIScreen.main.bounds.width,
                                                                            height: SidePanels.topRegionHeight / 2)
            
            func charLayouts(index: Int) -> (left: CGFloat, top: CGFloat) {
                return (left: CGFloat(index - 1) * TopRegion.charDimensions.width, top: 0)
            }
            func buttonsLayouts(index: Int) -> (left: CGFloat, top: CGFloat){
                return (left: displayWidth + CGFloat(index - 1) * TopRegion.buttonsDimensions.width,
                        top: 0)
            }
            func predictLayouts(index: Int) -> (left: CGFloat, top: CGFloat){
                return (left: CGFloat(index - 4) * predictWidth, top: SidePanels.topRegionHeight / 2)
            }
        }
        
        struct LeftRegion {
            static let buttonDimensions: (width: CGFloat, height: CGFloat) = (width: (34.0 / 320.0) * UIScreen.main.bounds.width,
                                                                              height: (30.0/320.0)*UIScreen.main.bounds.width)
            func forButton(withIndex index: Int) -> (left: CGFloat, top: CGFloat) {
                return (
                    left: (SidePanels.leftRegionSpacing / 320.0) * UIScreen.main.bounds.width,
                    top: CGFloat(index) * SidePanels.leftRegionSpacing + CGFloat(index - 1) *
                        (LeftRegion.buttonDimensions.height)
                )
            }
        }
        
        struct RightRegion {
            static let buttonDimensions: (width: CGFloat, height: CGFloat) = (width: (34.0 / 320.0)*UIScreen.main.bounds.width,
                                                                              height: (30.0 / 320.0)*UIScreen.main.bounds.width)
            static let returnButtonDimensions: (width: CGFloat, height: CGFloat) = (width: (34.0 / 320.0) * UIScreen.main.bounds.width,
                                                                                    height: (72.0 / 320.0)*UIScreen.main.bounds.width)
            func forButton(withIndex index:Int) -> (left: CGFloat, top: CGFloat){
                return (
                    left: (SidePanels.rightRegionSpacing / 320.0) * UIScreen.main.bounds.width,
                    top: CGFloat(index) * SidePanels.rightRegionSpacing + CGFloat(index - 1) *
                        (RightRegion.buttonDimensions.height)
                )
            }
        }
    }
    
    struct NumberPads {
        static let buttonWidth: CGFloat = (60.0 / 320.0) * UIScreen.main.bounds.width
        static let buttonHeight: CGFloat = (33.0 / 320.0) * UIScreen.main.bounds.width
        static let horizontalGap: CGFloat = 8.0
        static let verticalGap: CGFloat = 8.0
        
        var baseWidth: CGFloat {
            get {
                return UIScreen.main.bounds.width
            }
        }
        
        var baseLeft: CGFloat {
            get {
                return UIScreen.main.bounds.width / 2
            }
        }
        
        func forNumber(num: Int) -> (left:CGFloat, top: CGFloat) {
            switch num {
            case 1,2,4,5,7,8:
                switch num {
                case 1,4,7:
                    return (
                        left: UIScreen.main.bounds.width / 2 - NumberPads.buttonWidth / 2 - NumberPads.horizontalGap - NumberPads.buttonWidth,
                        top: SidePanels.topRegionHeight + (modf(CGFloat(num) / 3.5).0 + 1) *
                            NumberPads.verticalGap + modf(CGFloat(num) / 3.5).0 * NumberPads.buttonHeight
                    )
                case 2,5,8:
                    return (
                        left: UIScreen.main.bounds.width / 2 - NumberPads.buttonWidth / 2,
                        top: SidePanels.topRegionHeight + (modf(CGFloat(num) / 3.5).0 + 1) *
                            NumberPads.verticalGap + modf(CGFloat(num) / 3.5).0 * NumberPads.buttonHeight
                    )
                default:
                    return (left: 0.0, top: 0.0)
                }
            case 3,6,9:
                return (
                    left: UIScreen.main.bounds.width / 2 + NumberPads.buttonWidth / 2 + NumberPads.horizontalGap,
                    top: SidePanels.topRegionHeight + (modf(CGFloat(num) / 3.5).0 + 1) *
                        NumberPads.verticalGap + modf(CGFloat(num) / 3.5).0 * NumberPads.buttonHeight)
            default:
                return (left: 0.0, top: 0.0)
            }
        }
    }
}
