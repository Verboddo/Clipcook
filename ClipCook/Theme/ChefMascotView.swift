import SwiftUI

enum ChefMood {
    case happy
    case sad
    case cooking
    case excited
    case wink
}

struct ChefMascotView: View {
    var mood: ChefMood = .happy
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.98, green: 0.94, blue: 0.85))
                .frame(width: size, height: size)

            Circle()
                .stroke(AppTheme.primary, lineWidth: size * 0.04)
                .frame(width: size, height: size)

            chefHat
                .offset(y: -size * 0.42)

            faceContent
        }
        .frame(width: size, height: size * 1.3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Chef mascot, feeling \(moodLabel)")
    }

    private var moodLabel: String {
        switch mood {
        case .happy: return "happy"
        case .sad: return "sad"
        case .cooking: return "focused"
        case .excited: return "excited"
        case .wink: return "playful"
        }
    }

    private var chefHat: some View {
        ZStack {
            Ellipse()
                .fill(Color.white.opacity(0.9))
                .frame(width: size * 0.55, height: size * 0.25)
                .offset(y: size * 0.05)

            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(Color(.systemGray5))
                .frame(width: size * 0.5, height: size * 0.22)
                .offset(y: -size * 0.02)

            Circle()
                .fill(Color(.systemGray5))
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(y: -size * 0.14)
        }
    }

    @ViewBuilder
    private var faceContent: some View {
        switch mood {
        case .happy:
            happyFace
        case .sad:
            sadFace
        case .cooking:
            cookingFace
        case .excited:
            excitedFace
        case .wink:
            winkFace
        }
    }

    private var happyFace: some View {
        VStack(spacing: size * 0.04) {
            HStack(spacing: size * 0.2) {
                eye
                eye
            }
            smile
        }
        .offset(y: size * 0.05)
    }

    private var sadFace: some View {
        VStack(spacing: size * 0.04) {
            HStack(spacing: size * 0.2) {
                sadEye
                sadEye
            }
            frown
        }
        .offset(y: size * 0.05)
    }

    private var cookingFace: some View {
        VStack(spacing: size * 0.04) {
            HStack(spacing: size * 0.2) {
                eye
                eye
            }
            straightMouth
        }
        .offset(y: size * 0.05)
    }

    private var excitedFace: some View {
        VStack(spacing: size * 0.04) {
            HStack(spacing: size * 0.2) {
                eye
                eye
            }
            bigSmile
        }
        .offset(y: size * 0.05)
    }

    private var winkFace: some View {
        VStack(spacing: size * 0.04) {
            HStack(spacing: size * 0.2) {
                eye
                winkEye
            }
            smile
        }
        .offset(y: size * 0.05)
    }

    private var eye: some View {
        Circle()
            .fill(Color(red: 0.25, green: 0.20, blue: 0.15))
            .frame(width: size * 0.08, height: size * 0.08)
    }

    private var sadEye: some View {
        Ellipse()
            .fill(Color(red: 0.25, green: 0.20, blue: 0.15))
            .frame(width: size * 0.09, height: size * 0.06)
    }

    private var winkEye: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color(red: 0.25, green: 0.20, blue: 0.15))
            .frame(width: size * 0.1, height: size * 0.025)
    }

    private var smile: some View {
        SmileShape()
            .stroke(Color(red: 0.25, green: 0.20, blue: 0.15), lineWidth: size * 0.025)
            .frame(width: size * 0.2, height: size * 0.1)
    }

    private var bigSmile: some View {
        SmileShape()
            .stroke(Color(red: 0.25, green: 0.20, blue: 0.15), lineWidth: size * 0.03)
            .frame(width: size * 0.25, height: size * 0.14)
    }

    private var frown: some View {
        FrownShape()
            .stroke(Color(red: 0.25, green: 0.20, blue: 0.15), lineWidth: size * 0.025)
            .frame(width: size * 0.18, height: size * 0.08)
    }

    private var straightMouth: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color(red: 0.25, green: 0.20, blue: 0.15))
            .frame(width: size * 0.18, height: size * 0.025)
    }
}

private struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY * 0.3))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY * 0.3),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

private struct FrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: 0)
        )
        return path
    }
}
