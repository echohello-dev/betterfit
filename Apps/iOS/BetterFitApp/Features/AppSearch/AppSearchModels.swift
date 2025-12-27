import SwiftUI

// MARK: - Search Category

struct SearchCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
    let tint: Color
    let items: [SearchCategoryItem]
}

// MARK: - Search Category Item

struct SearchCategoryItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
}

// MARK: - Search Result

struct SearchResult: Identifiable, Hashable {
    enum Kind: Hashable {
        case theme
        case demoMode
        case category
        case exercise
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String
    let category: SearchCategory
}

// MARK: - Exercise Info

struct ExerciseInfo {
    let equipment: String
    let difficulty: String
    let type: String
    let instructions: [String]
    let tips: [String]

    static let placeholder = ExerciseInfo(
        equipment: "Varies",
        difficulty: "Intermediate",
        type: "Strength",
        instructions: [
            "Set up with proper form",
            "Perform the movement with control",
            "Return to starting position",
        ],
        tips: [
            "Focus on mind-muscle connection",
            "Control the eccentric phase",
        ]
    )

    static let data: [String: ExerciseInfo] = [
        "Bench Press": ExerciseInfo(
            equipment: "Barbell, Bench",
            difficulty: "Intermediate",
            type: "Compound",
            instructions: [
                "Lie flat on the bench with feet firmly on the ground",
                "Grip the bar slightly wider than shoulder width",
                "Unrack the bar and lower it to your mid-chest",
                "Press the bar back up to the starting position",
            ],
            tips: [
                "Keep your shoulder blades retracted",
                "Maintain a slight arch in your lower back",
                "Don't bounce the bar off your chest",
            ]
        ),
        "Incline Dumbbell Press": ExerciseInfo(
            equipment: "Dumbbells, Incline Bench",
            difficulty: "Intermediate",
            type: "Compound",
            instructions: [
                "Set the bench to a 30-45 degree incline",
                "Hold dumbbells at shoulder level with palms facing forward",
                "Press the weights up until arms are extended",
                "Lower with control to the starting position",
            ],
            tips: [
                "Keep your back flat against the bench",
                "Don't let the weights drift too far forward",
                "Control the descent to maximize tension",
            ]
        ),
        "Squat": ExerciseInfo(
            equipment: "Barbell, Squat Rack",
            difficulty: "Intermediate",
            type: "Compound",
            instructions: [
                "Position the bar on your upper back",
                "Stand with feet shoulder-width apart",
                "Descend by breaking at hips and knees",
                "Go down until thighs are parallel to floor",
                "Drive through your heels to stand back up",
            ],
            tips: [
                "Keep your chest up throughout the movement",
                "Track your knees over your toes",
                "Brace your core before each rep",
            ]
        ),
        "Romanian Deadlift": ExerciseInfo(
            equipment: "Barbell or Dumbbells",
            difficulty: "Intermediate",
            type: "Compound",
            instructions: [
                "Hold the weight in front of your thighs",
                "Push your hips back while keeping legs mostly straight",
                "Lower the weight along your legs until you feel a hamstring stretch",
                "Drive hips forward to return to standing",
            ],
            tips: [
                "Keep a slight bend in your knees",
                "Maintain a neutral spine throughout",
                "Feel the stretch in your hamstrings",
            ]
        ),
        "Deadlift": ExerciseInfo(
            equipment: "Barbell",
            difficulty: "Advanced",
            type: "Compound",
            instructions: [
                "Stand with feet hip-width apart, bar over mid-foot",
                "Hinge at hips and grip the bar",
                "Flatten your back and brace your core",
                "Drive through your legs and pull the bar up",
                "Lock out at the top with hips fully extended",
            ],
            tips: [
                "Keep the bar close to your body",
                "Don't round your lower back",
                "Think of pushing the floor away",
            ]
        ),
        "Pull Up": ExerciseInfo(
            equipment: "Pull-up Bar",
            difficulty: "Intermediate",
            type: "Compound",
            instructions: [
                "Hang from the bar with arms fully extended",
                "Pull yourself up until chin clears the bar",
                "Lower yourself with control",
            ],
            tips: [
                "Initiate the pull with your lats, not arms",
                "Avoid swinging or kipping",
                "Use a band for assistance if needed",
            ]
        ),
        "Lat Pulldown": ExerciseInfo(
            equipment: "Cable Machine",
            difficulty: "Beginner",
            type: "Compound",
            instructions: [
                "Sit at the machine and grip the bar wider than shoulder width",
                "Pull the bar down to your upper chest",
                "Squeeze your shoulder blades together at the bottom",
                "Return the bar with control",
            ],
            tips: [
                "Don't lean back excessively",
                "Focus on pulling with your elbows, not hands",
                "Keep your chest up throughout",
            ]
        ),
        "Overhead Press": ExerciseInfo(
            equipment: "Barbell or Dumbbells",
            difficulty: "Intermediate",
            type: "Compound",
            instructions: [
                "Start with the bar at shoulder height",
                "Brace your core and squeeze your glutes",
                "Press the bar straight overhead",
                "Lower the bar back to shoulders with control",
            ],
            tips: [
                "Keep your elbows slightly in front of the bar",
                "Don't lean back excessively",
                "Move your head back slightly as the bar passes",
            ]
        ),
        "Barbell Row": ExerciseInfo(
            equipment: "Barbell",
            difficulty: "Intermediate",
            type: "Compound",
            instructions: [
                "Hinge at hips with the bar hanging at arm's length",
                "Pull the bar to your lower chest or upper abdomen",
                "Squeeze your shoulder blades together at the top",
                "Lower with control",
            ],
            tips: [
                "Keep your back flat, not rounded",
                "Don't use momentum to swing the weight",
                "Pull your elbows back, not just up",
            ]
        ),
        "Bicep Curl": ExerciseInfo(
            equipment: "Dumbbells or Barbell",
            difficulty: "Beginner",
            type: "Isolation",
            instructions: [
                "Stand with weights at your sides, palms forward",
                "Curl the weights up toward your shoulders",
                "Squeeze at the top of the movement",
                "Lower with control to the starting position",
            ],
            tips: [
                "Keep your elbows pinned to your sides",
                "Don't swing the weights",
                "Focus on the squeeze at the top",
            ]
        ),
    ]
}
