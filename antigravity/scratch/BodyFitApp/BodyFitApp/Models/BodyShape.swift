import Foundation

enum BodyShape: String, Codable, CaseIterable, Identifiable {
    case hourglass = "Hourglass"
    case pear = "Pear"
    case apple = "Apple"
    case rectangle = "Rectangle"
    case invertedTriangle = "Inverted Triangle"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .hourglass: return "⏳"
        case .pear: return "🍐"
        case .apple: return "🍎"
        case .rectangle: return "▬"
        case .invertedTriangle: return "🔻"
        }
    }

    var description: String {
        switch self {
        case .hourglass:
            return "Your bust and hips are roughly the same width with a clearly defined, narrower waist. This is considered the most proportionally balanced body shape."
        case .pear:
            return "Your hips are wider than your bust, with a defined waist. You tend to carry weight in your lower body — hips, thighs, and buttocks."
        case .apple:
            return "You carry weight around your midsection. Your bust and waist are similar in size, often wider than your hips. Shoulders may be broad."
        case .rectangle:
            return "Your bust, waist, and hips are roughly similar in width. Your body has a straight up-and-down silhouette with minimal waist definition."
        case .invertedTriangle:
            return "Your shoulders and bust are wider than your hips. You have a strong upper body with narrower hips and legs."
        }
    }

    var stylingTips: [String] {
        switch self {
        case .hourglass:
            return [
                "Fitted clothing that cinches at the waist works beautifully",
                "Wrap dresses and belted styles accentuate your curves",
                "V-necklines and scoop necks complement your proportions",
                "Avoid boxy or shapeless clothing that hides your waist",
                "High-waisted bottoms showcase your natural curves"
            ]
        case .pear:
            return [
                "Draw attention upward with statement necklines and shoulder details",
                "A-line skirts and bootcut pants balance your silhouette",
                "Structured shoulders and padded blazers create proportion",
                "Avoid clingy fabrics on the lower body",
                "Dark-colored bottoms with bright or patterned tops work well"
            ]
        case .apple:
            return [
                "Empire waistlines and A-line silhouettes flatter your midsection",
                "V-necklines elongate your torso beautifully",
                "Structured fabrics with some drape are your best friend",
                "Show off your legs with straight or slim-fit pants",
                "Avoid tight waistbands — opt for mid-rise styles"
            ]
        case .rectangle:
            return [
                "Create curves with peplum tops and belted dresses",
                "Ruffles, layers, and textures add dimension to your frame",
                "Off-shoulder and sweetheart necklines add visual interest",
                "High-waisted styles create the illusion of curves",
                "Fit-and-flare dresses work wonderfully for your shape"
            ]
        case .invertedTriangle:
            return [
                "Balance proportions with wide-leg pants and A-line skirts",
                "V-necklines draw the eye downward and narrow the shoulders",
                "Avoid shoulder pads and boat necklines",
                "Full skirts and flared bottoms add volume to your lower half",
                "Wrap tops and diagonal details soften the shoulder line"
            ]
        }
    }

    var fitConsiderations: [String: String] {
        switch self {
        case .hourglass:
            return [
                "tops": "Look for fitted styles that define the waist",
                "dresses": "Wrap and bodycon styles suit you perfectly",
                "pants": "High-waisted with a slight flare balances your curves",
                "skirts": "Pencil skirts and A-lines both work well"
            ]
        case .pear:
            return [
                "tops": "Opt for boat necks and off-shoulder to widen the upper body",
                "dresses": "A-line and fit-and-flare are most flattering",
                "pants": "Bootcut and wide-leg balance wider hips",
                "skirts": "A-line skirts that skim over hips work best"
            ]
        case .apple:
            return [
                "tops": "Empire and tunic styles skim the midsection",
                "dresses": "Shift dresses and empire waist styles are ideal",
                "pants": "Straight-leg with mid-rise provides comfort",
                "skirts": "A-line and circle skirts are most comfortable"
            ]
        case .rectangle:
            return [
                "tops": "Peplum and ruched styles create waist definition",
                "dresses": "Belted and fit-and-flare add feminine shape",
                "pants": "Tapered and cigarette styles with a defined waist",
                "skirts": "Pleated and tiered skirts add body and movement"
            ]
        case .invertedTriangle:
            return [
                "tops": "V-neck and wrap styles narrow the shoulder line",
                "dresses": "A-line with a detailed skirt portion",
                "pants": "Wide-leg and palazzo add balance below",
                "skirts": "Full, pleated, or ruffled skirts add lower volume"
            ]
        }
    }
}
