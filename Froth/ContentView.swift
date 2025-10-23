import SwiftUI
import Combine
import Charts


// MARK: - Models

struct Lesson: Identifiable, Codable {
    enum LessonType: String, Codable, CaseIterable {
        case flashcards, multipleChoice, miniCase, caseStudy, technicalInterview
        
        var icon: String {
            switch self {
            case .flashcards: return "rectangle.stack.fill"
            case .multipleChoice: return "list.bullet"
            case .miniCase: return "briefcase.fill"
            case .caseStudy: return "doc.text.fill"
            case .technicalInterview: return "person.2.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .flashcards: return .blue
            case .multipleChoice: return .green
            case .miniCase: return .orange
            case .caseStudy: return .purple
            case .technicalInterview: return .red
            }
        }

        // Human-friendly names for display
        var displayName: String {
            switch self {
            case .flashcards:
                return "Flashcards"
            case .multipleChoice:
                return "Multiple Choice"
            case .miniCase:
                return "Mini Case"
            case .caseStudy:
                return "Case Study"
            case .technicalInterview:
                return "Technical Interview"
            }
        }
    }
    
    let id: UUID
    let title: String
    let xpReward: Int
    let type: LessonType
    let description: String
    let questions: [Question]
    let difficulty: Difficulty
    let estimatedTime: Int // in minutes
    let category: String
    let prerequisites: [String]
    let tags: [String]
    
    enum Difficulty: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .yellow
            case .advanced: return .orange
            case .expert: return .red
            }
        }
    }
    
    init(title: String, xpReward: Int, type: LessonType, description: String, questions: [Question], difficulty: Difficulty, estimatedTime: Int, category: String, prerequisites: [String], tags: [String] = []) {
        self.id = UUID()
        self.title = title
        self.xpReward = xpReward
        self.type = type
        self.description = description
        self.questions = questions
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.category = category
        self.prerequisites = prerequisites
        self.tags = tags
    }
}

struct Question: Identifiable, Codable {
    let id: UUID
    let prompt: String
    let choices: [String] // for MCQ - if empty -> flashcard
    let correctIndex: Int?
    let hint: String?
    let explanation: String?
    let difficulty: Lesson.Difficulty
    let tags: [String]
    
    init(prompt: String, choices: [String], correctIndex: Int?, hint: String?, explanation: String? = nil, difficulty: Lesson.Difficulty, tags: [String] = []) {
        self.id = UUID()
        self.prompt = prompt
        self.choices = choices
        self.correctIndex = correctIndex
        self.hint = hint
        self.explanation = explanation
        self.difficulty = difficulty
        self.tags = tags
    }
}

// MARK: - Achievement System

struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let rarity: Rarity
    let requirements: [String]
    
    enum Rarity: String, Codable, CaseIterable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .common:
                return LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .rare:
                return LinearGradient(
                    colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .epic:
                return LinearGradient(
                    colors: [Color.purple.opacity(0.9), Color.pink.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .legendary:
                return LinearGradient(
                    colors: [Color.orange.opacity(0.9), Color.yellow.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    init(title: String, description: String, icon: String, xpReward: Int, rarity: Rarity, requirements: [String]) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.xpReward = xpReward
        self.rarity = rarity
        self.requirements = requirements
    }
}

// MARK: - Daily Goals System

struct DailyGoal: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: DailyGoalType
    let xpReward: Int
    let icon: String
    let targetValue: Int
    var currentProgress: Int
    var isCompleted: Bool
    let createdAt: Date
    
    enum DailyGoalType: String, Codable, CaseIterable {
        case simple = "Simple"
        case moderate = "Moderate"
        case advanced = "Advanced"
        
        var color: Color {
            switch self {
            case .simple: return Brand.primaryBlue
            case .moderate: return Brand.gamificationAccent
            case .advanced: return Brand.gold
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .simple:
                return LinearGradient(
                    colors: [
                        Brand.primaryBlue.opacity(0.7),
                        Brand.softBlue.opacity(0.6),
                        Brand.lightBlue.opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .moderate:
                return LinearGradient(
                    colors: [
                        Brand.gamificationAccent.opacity(0.6),
                        Brand.lightCoral.opacity(0.5),
                        Brand.primaryBlue.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .advanced:
                return LinearGradient(
                    colors: [
                        Brand.gold.opacity(0.6),
                        Brand.emerald.opacity(0.5),
                        Brand.gamificationAccent.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        var xpReward: Int {
            switch self {
            case .simple: return 15
            case .moderate: return 30
            case .advanced: return 50
            }
        }
    }
    
    init(title: String, description: String, type: DailyGoalType, icon: String, targetValue: Int) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.type = type
        self.xpReward = type.xpReward
        self.icon = icon
        self.targetValue = targetValue
        self.currentProgress = 0
        self.isCompleted = false
        self.createdAt = Date()
    }
    
    var progressPercentage: Double {
        min(1.0, Double(currentProgress) / Double(targetValue))
    }
}

// MARK: - User Progress

struct UserProgress: Codable {
    let totalXP: Int
    let level: Int
    let streakDays: Int
    let completedLessons: Int
    let achievements: [String] // Achievement IDs
    let weeklyGoal: Int
    let currentWeekXP: Int
    let studyStreak: Int
    let lastStudyDate: Date?
}

// MARK: - App State & Persistence

final class AppStore: ObservableObject {
    @Published var xp: Int = 0
    @Published var streakDays: Int = 0
    @Published var lastPracticeDate: Date? = nil
    @Published var completedLessonIDs: Set<UUID> = []
    @Published var username: String = "Raymundo"
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var level: Int = 1
    @Published var achievements: Set<UUID> = []
    @Published var weeklyGoal: Int = 500
    @Published var currentWeekXP: Int = 0
    @Published var studyStreak: Int = 0
    @Published var lastStudyDate: Date? = nil
    @Published var dailyGoal: Int = 100
    @Published var currentDayXP: Int = 0
    @Published var totalStudyTime: Int = 0 // in minutes
    @Published var perfectLessons: Int = 0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var currentQuestionStreak: Int = 0
    @Published var totalPoints: Int = 0
    @Published var pointsEarnedThisSession: Int = 0
    @Published var showStreakCelebration: Bool = false
    @Published var streakMilestoneHit: Int? = nil
    @Published var selectedTheme: AppTheme = .alpha
    @Published var notificationsEnabled: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var currentModule: String = "Accounting Basics"
    @Published var completedModules: Set<String> = []
    @Published var lastLessonID: UUID? = nil
    @Published var shouldShowUnlockAnimation: Bool = false
    @Published var isProUser: Bool = false
    @Published var proSubscriptionExpiryDate: Date? = nil
    
    // Learning Progress
    @Published var hasAttemptedQuestion: Bool = false
    
    // Daily Goals
    @Published var dailyGoals: [DailyGoal] = []
    @Published var lastDailyGoalResetDate: Date? = nil
    @Published var totalDailyGoalsCompleted: Int = 0
    @Published var todayDailyGoalsXP: Int = 0

    private var cancellables = Set<AnyCancellable>()
    
    // Preview mode flag to prevent crashes in SwiftUI previews
    var isPreviewMode: Bool = false

    static let storageKey = "FrothAppStore_v2"
    
    enum AppTheme: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        case alpha = "Alpha"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            case .alpha: return .dark
            }
        }
    }

    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Save on changes (debounced)
        Publishers.CombineLatest4($xp, $streakDays, $username, $achievements)
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] _,_,_,_ in self?.save() }
            .store(in: &cancellables)
    }
    
    func configureFromLoadedData(xp: Int, streakDays: Int, lastPracticeDate: Date?, completedLessonIDs: Set<UUID>, username: String, level: Int, achievements: Set<UUID>, weeklyGoal: Int, currentWeekXP: Int, studyStreak: Int, lastStudyDate: Date?, dailyGoal: Int, currentDayXP: Int, totalStudyTime: Int, perfectLessons: Int, currentStreak: Int, longestStreak: Int, selectedTheme: AppTheme, notificationsEnabled: Bool, soundEnabled: Bool, hapticsEnabled: Bool, isProUser: Bool, proSubscriptionExpiryDate: Date?, hasAttemptedQuestion: Bool, dailyGoals: [DailyGoal]? = nil, lastDailyGoalResetDate: Date? = nil, totalDailyGoalsCompleted: Int? = nil, todayDailyGoalsXP: Int? = nil) {
        self.xp = xp
        self.streakDays = streakDays
        self.lastPracticeDate = lastPracticeDate
        self.completedLessonIDs = completedLessonIDs
        self.username = username
        self.level = level
        self.achievements = achievements
        self.weeklyGoal = weeklyGoal
        self.currentWeekXP = currentWeekXP
        self.studyStreak = studyStreak
        self.lastStudyDate = lastStudyDate
        self.dailyGoal = dailyGoal
        self.currentDayXP = currentDayXP
        self.totalStudyTime = totalStudyTime
        self.perfectLessons = perfectLessons
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.selectedTheme = selectedTheme
        self.notificationsEnabled = notificationsEnabled
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.isProUser = isProUser
        self.proSubscriptionExpiryDate = proSubscriptionExpiryDate
        self.hasAttemptedQuestion = hasAttemptedQuestion
        self.dailyGoals = dailyGoals ?? []
        self.lastDailyGoalResetDate = lastDailyGoalResetDate
        self.totalDailyGoalsCompleted = totalDailyGoalsCompleted ?? 0
        self.todayDailyGoalsXP = todayDailyGoalsXP ?? 0
    }

    func awardXP(_ amount: Int) {
        xp += amount
        level = AppStore.calculateLevel(xp: xp)
        updateStreakIfNeeded()
        
        // Update daily goals progress
        updateDailyGoalProgress(action: .xpEarned(amount))
        
        // Check and unlock achievements
        checkAndUnlockAchievements()
    }
    
    func handleCorrectAnswer() {
        currentQuestionStreak += 1
        let basePoints = 10
        // Exponential growth with soft caps at known milestones
        let exponentialFactor = min(5.0, pow(1.25, Double(max(0, currentQuestionStreak - 1))))
        let milestoneBoost: Double
        switch currentQuestionStreak {
        case 5: milestoneBoost = 1.5
        case 10: milestoneBoost = 2.0
        case 20: milestoneBoost = 2.5
        case 50: milestoneBoost = 3.0
        default: milestoneBoost = 1.0
        }
        let pointsEarned = Int(Double(basePoints) * exponentialFactor * milestoneBoost)
        
        totalPoints += pointsEarned
        pointsEarnedThisSession += pointsEarned
        
        // Award XP in tandem with points (1:1 for now)
        awardXP(pointsEarned)
        
        // Update daily goals progress
        updateDailyGoalProgress(action: .questionCorrect)
        
        // Check for streak milestones
        checkStreakMilestones()
        
        // Save changes (with preview mode check)
        if !isPreviewMode {
            save()
        }
    }
    
    func handleIncorrectAnswer() {
        currentQuestionStreak = 0
        // Points don't reset - they persist throughout the session
        // Save changes (with preview mode check)
        if !isPreviewMode {
            save()
        }
    }
    
    func calculateStreakMultiplier() -> Int {
        // Deprecated in favor of exponential scoring; retain for compatibility
        switch currentQuestionStreak {
        case 5...9: return 2
        case 10...19: return 3
        case 20...49: return 4
        case 50...: return 5
        default: return 1
        }
    }
    
    func checkStreakMilestones() {
        let milestones = [5, 10, 20, 50]
        if milestones.contains(currentQuestionStreak) {
            streakMilestoneHit = currentQuestionStreak
            showStreakCelebration = true
        }
    }
    
    func resetSession() {
        currentQuestionStreak = 0
        pointsEarnedThisSession = 0
        // Save changes (with preview mode check)
        if !isPreviewMode {
            save()
        }
    }

    private func updateStreakIfNeeded() {
        guard let last = lastPracticeDate else {
            lastPracticeDate = Date()
            streakDays = 1
            checkAndUnlockAchievements() // Check achievements when streak starts
            return
        }
        if !Calendar.current.isDateInToday(last) {
            if Calendar.current.isDate(last, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date())!) {
                streakDays += 1
            } else {
                streakDays = 1
            }
            lastPracticeDate = Date()
            checkAndUnlockAchievements() // Check achievements when streak updates
        }
    }

    func markLessonCompleted(_ id: UUID) {
        completedLessonIDs.insert(id)
        lastLessonID = id
        
        // Update daily goals progress
        updateDailyGoalProgress(action: .lessonCompleted)
        
        // Check and unlock achievements
        checkAndUnlockAchievements()
        
        // Check if module is completed
        let lesson = ContentProvider.sampleLessons.first { $0.id == id }
        if let lesson = lesson {
            let moduleLessons = ContentProvider.sampleLessons.filter { $0.category == lesson.category }
            let completedModuleLessons = moduleLessons.filter { completedLessonIDs.contains($0.id) }
            
            if completedModuleLessons.count == moduleLessons.count {
                completedModules.insert(lesson.category)
            }
        }
        
        // Save changes (with preview mode check)
        if !isPreviewMode {
            save()
        }
    }
    
    func getNextLesson() -> Lesson? {
        if let lastID = lastLessonID,
           let lastIndex = ContentProvider.sampleLessons.firstIndex(where: { $0.id == lastID }) {
            let nextIndex = lastIndex + 1
            if nextIndex < ContentProvider.sampleLessons.count {
                return ContentProvider.sampleLessons[nextIndex]
            }
        }
        return ContentProvider.sampleLessons.first
    }
    
    func getCurrentModuleLessons() -> [Lesson] {
        return ContentProvider.sampleLessons.filter { $0.category == currentModule }
    }
    
    // MARK: - Pro Access Control
    
    func canAccessLesson(lesson: Lesson) -> Bool {
        // Pro users can access everything
        if isProUser {
            return true
        }
        
        // Free users can access first 2 levels of each module
        let moduleLessons = getCurrentModuleLessons()
        guard let lessonIndex = moduleLessons.firstIndex(where: { $0.id == lesson.id }) else {
            return false
        }
        
        // First 2 levels (indices 0 and 1) are free
        return lessonIndex < 2
    }
    
    func upgradeToProUser(expiryDate: Date) {
        isProUser = true
        proSubscriptionExpiryDate = expiryDate
        // Save changes (with preview mode check)
        if !isPreviewMode {
            save()
        }
    }
    
    func restorePurchases() {
        // This will be called by StoreKit manager after successful restore
        // For now, we'll implement basic logic
        if let expiryDate = proSubscriptionExpiryDate, expiryDate > Date() {
            isProUser = true
        } else {
            isProUser = false
        }
        // Save changes (with preview mode check)
        if !isPreviewMode {
            save()
        }
    }
    
    // MARK: - Daily Goals
    
    func checkAndResetDailyGoals() {
        print("🎯 Checking daily goals reset...")
        let calendar = Calendar.current
        let now = Date()
        
        // Check if we need to reset goals (new day)
        if let lastReset = lastDailyGoalResetDate {
            if !calendar.isDate(lastReset, inSameDayAs: now) {
                print("🎯 New day detected - resetting goals")
                // New day - reset goals
                generateDailyGoals()
                lastDailyGoalResetDate = now
                todayDailyGoalsXP = 0
                // Save immediately after reset (with preview mode check)
                if !isPreviewMode {
                    save()
                }
            } else {
                print("🎯 Same day - keeping existing goals")
            }
        } else {
            print("🎯 First time - generating initial goals")
            // First time - generate initial goals
            generateDailyGoals()
            lastDailyGoalResetDate = now
            // Save immediately after generation (with preview mode check)
            if !isPreviewMode {
                save()
            }
        }
    }
    
    func generateDailyGoals() {
        print("🎯 Generating daily goals...")
        
        let simpleGoals = [
            DailyGoal(title: "Daily Check-in", description: "Open the app today", type: .simple, icon: "house.fill", targetValue: 1),
            DailyGoal(title: "First Lesson", description: "Complete 1 lesson", type: .simple, icon: "play.circle.fill", targetValue: 1),
            DailyGoal(title: "Quick XP", description: "Earn 50 XP", type: .simple, icon: "star.fill", targetValue: 50),
            DailyGoal(title: "Learning Streak", description: "Maintain your streak", type: .simple, icon: "flame.fill", targetValue: 1)
        ]
        
        let moderateGoals = [
            DailyGoal(title: "Double Down", description: "Complete 3 lessons", type: .moderate, icon: "list.bullet", targetValue: 3),
            DailyGoal(title: "Question Master", description: "Get 10 questions right", type: .moderate, icon: "checkmark.circle.fill", targetValue: 10),
            DailyGoal(title: "XP Hunter", description: "Earn 150 XP", type: .moderate, icon: "target", targetValue: 150),
            DailyGoal(title: "Perfect Streak", description: "Complete 2 lessons perfectly", type: .moderate, icon: "crown.fill", targetValue: 2)
        ]
        
        let advancedGoals = [
            DailyGoal(title: "Perfect Score", description: "Complete a lesson perfectly", type: .advanced, icon: "crown.fill", targetValue: 1),
            DailyGoal(title: "Question Streak", description: "Get 15 questions right in a row", type: .advanced, icon: "bolt.fill", targetValue: 15),
            DailyGoal(title: "XP Champion", description: "Earn 300 XP", type: .advanced, icon: "trophy.fill", targetValue: 300),
            DailyGoal(title: "Module Master", description: "Complete 5 lessons", type: .advanced, icon: "graduationcap.fill", targetValue: 5)
        ]
        
        // Randomly select one goal from each difficulty
        dailyGoals = [
            simpleGoals.randomElement() ?? simpleGoals[0],
            moderateGoals.randomElement() ?? moderateGoals[0],
            advancedGoals.randomElement() ?? advancedGoals[0]
        ]
        
        print("🎯 Generated \(dailyGoals.count) daily goals: \(dailyGoals.map { $0.title })")
    }
    
    func updateDailyGoalProgress(action: DailyGoalAction) {
        var goalsUpdated = false
        
        for i in 0..<dailyGoals.count {
            var goal = dailyGoals[i]
            
            if goal.isCompleted { continue }
            
            switch action {
            case .appOpened:
                if goal.title == "Daily Check-in" {
                    goal.currentProgress = 1
                    goalsUpdated = true
                }
            case .lessonCompleted:
                if goal.title.contains("lesson") {
                    goal.currentProgress += 1
                    goalsUpdated = true
                }
            case .questionCorrect:
                if goal.title.contains("question") || goal.title.contains("Question") {
                    goal.currentProgress += 1
                    goalsUpdated = true
                }
            case .xpEarned(let amount):
                if goal.title.contains("XP") {
                    goal.currentProgress += amount
                    goalsUpdated = true
                }
            case .perfectLesson:
                if goal.title == "Perfect Score" {
                    goal.currentProgress = 1
                    goalsUpdated = true
                }
                if goal.title == "Perfect Streak" {
                    goal.currentProgress += 1
                    goalsUpdated = true
                }
            case .studyTime(let minutes):
                // Time-based goals removed - no longer tracking study time
                break
            }
            
            // Check if goal is completed
            if goal.currentProgress >= goal.targetValue && !goal.isCompleted {
                goal.isCompleted = true
                completeDailyGoal(goal)
            }
            
            dailyGoals[i] = goal
        }
        
        // Save changes if any goals were updated
        if goalsUpdated && !isPreviewMode {
            save()
        }
    }
    
    private func completeDailyGoal(_ goal: DailyGoal) {
        // Award XP
        awardXP(goal.xpReward)
        todayDailyGoalsXP += goal.xpReward
        totalDailyGoalsCompleted += 1
        
        // Haptic feedback
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        #endif
        
        // Check if all goals completed
        if dailyGoals.allSatisfy({ $0.isCompleted }) {
            // Bonus XP for completing all goals
            let bonusXP = 25
            awardXP(bonusXP)
            todayDailyGoalsXP += bonusXP
        }
    }
    
    enum DailyGoalAction {
        case appOpened
        case lessonCompleted
        case questionCorrect
        case xpEarned(Int)
        case perfectLesson
        case studyTime(Int)
    }
    
    // MARK: - Achievement System
    
    func checkAndUnlockAchievements() {
        let allAchievements = ContentProvider.achievements
        var newAchievementsUnlocked = false
        
        for achievement in allAchievements {
            // Skip if already unlocked
            if achievements.contains(achievement.id) { continue }
            
            var shouldUnlock = false
            
            // Check achievement requirements
            switch achievement.title {
            case "First Deal":
                shouldUnlock = completedLessonIDs.count >= 1
            case "Quick Learner":
                shouldUnlock = completedLessonIDs.count >= 5
            case "Deal Flow":
                shouldUnlock = completedLessonIDs.count >= 15
            case "Rising Star":
                shouldUnlock = xp >= 500
            case "Knowledge Builder":
                shouldUnlock = xp >= 2500
            case "Power Hour":
                // Check if completed 3 lessons today (simplified - just check total for now)
                shouldUnlock = completedLessonIDs.count >= 3
            case "Deal Starter":
                // Check if completed first IB lesson (simplified - just check if any lesson completed)
                shouldUnlock = completedLessonIDs.count >= 1
            case "Week Warrior":
                shouldUnlock = streakDays >= 7
            case "Early Bird":
                shouldUnlock = streakDays >= 3
            case "Pitch Perfect":
                // Check if scored 90%+ on 5 lessons (simplified - just check perfect lessons)
                shouldUnlock = perfectLessons >= 5
            case "DCF Master":
                // Check if completed all DCF lessons
                let dcfLessons = ContentProvider.sampleLessons.filter { $0.category == "DCF Fundamentals" }
                let completedDCFLessons = dcfLessons.filter { completedLessonIDs.contains($0.id) }
                shouldUnlock = completedDCFLessons.count == dcfLessons.count && dcfLessons.count > 0
            case "Valuation Ace":
                // Check if completed all Valuation Techniques lessons
                let valuationLessons = ContentProvider.sampleLessons.filter { $0.category == "Valuation Techniques" }
                let completedValuationLessons = valuationLessons.filter { completedLessonIDs.contains($0.id) }
                shouldUnlock = completedValuationLessons.count == valuationLessons.count && valuationLessons.count > 0
            case "Wall Street Ready":
                // Check if completed all M&A and LBO lessons
                let maLessons = ContentProvider.sampleLessons.filter { $0.category == "M&A Fundamentals" }
                let lboLessons = ContentProvider.sampleLessons.filter { $0.category == "LBO Fundamentals" }
                let completedMALessons = maLessons.filter { completedLessonIDs.contains($0.id) }
                let completedLBOLessons = lboLessons.filter { completedLessonIDs.contains($0.id) }
                shouldUnlock = completedMALessons.count == maLessons.count && completedLBOLessons.count == lboLessons.count && maLessons.count > 0 && lboLessons.count > 0
            default:
                // For any other achievements, check based on general progress
                if achievement.requirements.contains("Complete 1 lesson") {
                    shouldUnlock = completedLessonIDs.count >= 1
                } else if achievement.requirements.contains("Complete 5 lessons") {
                    shouldUnlock = completedLessonIDs.count >= 5
                } else if achievement.requirements.contains("Complete 15 lessons") {
                    shouldUnlock = completedLessonIDs.count >= 15
                } else if achievement.requirements.contains("Earn 500 XP") {
                    shouldUnlock = xp >= 500
                } else if achievement.requirements.contains("Earn 2,500 XP") {
                    shouldUnlock = xp >= 2500
                } else if achievement.requirements.contains("3-day streak") {
                    shouldUnlock = streakDays >= 3
                } else if achievement.requirements.contains("7-day streak") {
                    shouldUnlock = streakDays >= 7
                }
            }
            
            if shouldUnlock {
                achievements.insert(achievement.id)
                awardXP(achievement.xpReward)
                newAchievementsUnlocked = true
                print("🏆 Achievement unlocked: \(achievement.title)")
            }
        }
        
        if newAchievementsUnlocked && !isPreviewMode {
            save()
        }
    }

    private func save() {
        // Skip saving in preview mode to prevent crashes
        guard !isPreviewMode else { return }
        
        do {
            let payload = Persisted(
                xp: xp,
                streak: streakDays,
                lastPractice: lastPracticeDate,
                completedIDs: Array(completedLessonIDs).map { $0.uuidString },
                username: username,
                level: level,
                achievements: Array(achievements).map { $0.uuidString },
                weeklyGoal: weeklyGoal,
                currentWeekXP: currentWeekXP,
                studyStreak: studyStreak,
                lastStudyDate: lastStudyDate,
                dailyGoal: dailyGoal,
                currentDayXP: currentDayXP,
                totalStudyTime: totalStudyTime,
                perfectLessons: perfectLessons,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                selectedTheme: selectedTheme.rawValue,
                notificationsEnabled: notificationsEnabled,
                soundEnabled: soundEnabled,
                hapticsEnabled: hapticsEnabled,
                isProUser: isProUser,
                proSubscriptionExpiryDate: proSubscriptionExpiryDate,
                hasAttemptedQuestion: hasAttemptedQuestion,
                dailyGoals: dailyGoals,
                lastDailyGoalResetDate: lastDailyGoalResetDate,
                totalDailyGoalsCompleted: totalDailyGoalsCompleted,
                todayDailyGoalsXP: todayDailyGoalsXP
            )
            let data = try JSONEncoder().encode(payload)
            UserDefaults.standard.set(data, forKey: AppStore.storageKey)
        } catch {
            print("Save failed", error)
        }
    }

    static func load() -> AppStore {
        let store = AppStore()
        
        if let raw = UserDefaults.standard.data(forKey: storageKey) {
            do {
                let payload = try JSONDecoder().decode(Persisted.self, from: raw)
                let ids = Set(payload.completedIDs.compactMap { UUID(uuidString: $0) })
                let achievementIds = Set((payload.achievements ?? []).compactMap { UUID(uuidString: $0) })
                let theme = AppTheme(rawValue: payload.selectedTheme ?? "alpha") ?? .alpha
                
                store.configureFromLoadedData(
                    xp: payload.xp,
                    streakDays: payload.streak,
                    lastPracticeDate: payload.lastPractice,
                    completedLessonIDs: ids,
                    username: payload.username,
                    level: payload.level,
                    achievements: achievementIds,
                    weeklyGoal: payload.weeklyGoal ?? 500,
                    currentWeekXP: payload.currentWeekXP ?? 0,
                    studyStreak: payload.studyStreak ?? payload.streak,
                    lastStudyDate: payload.lastStudyDate ?? payload.lastPractice,
                    dailyGoal: payload.dailyGoal ?? 100,
                    currentDayXP: payload.currentDayXP ?? 0,
                    totalStudyTime: payload.totalStudyTime ?? 0,
                    perfectLessons: payload.perfectLessons ?? 0,
                    currentStreak: payload.currentStreak ?? payload.streak,
                    longestStreak: payload.longestStreak ?? payload.streak,
                    selectedTheme: theme,
                    notificationsEnabled: payload.notificationsEnabled ?? true,
                    soundEnabled: payload.soundEnabled ?? true,
                    hapticsEnabled: payload.hapticsEnabled ?? true,
                    isProUser: payload.isProUser ?? false,
                    proSubscriptionExpiryDate: payload.proSubscriptionExpiryDate,
                    hasAttemptedQuestion: payload.hasAttemptedQuestion ?? false,
                    dailyGoals: payload.dailyGoals,
                    lastDailyGoalResetDate: payload.lastDailyGoalResetDate,
                    totalDailyGoalsCompleted: payload.totalDailyGoalsCompleted,
                    todayDailyGoalsXP: payload.todayDailyGoalsXP
                )
            } catch {
                print("Load decode failed", error)
            }
        }
        
        // Only check and reset daily goals if they don't exist or reset date is nil
        if store.dailyGoals.isEmpty || store.lastDailyGoalResetDate == nil {
            store.checkAndResetDailyGoals()
        }
        
        return store
    }

    static func calculateLevel(xp: Int) -> Int {
        // INSANELY challenging level curve - requires MASSIVE amounts of XP per level
        // Level 1: 0-1,000,000 XP, Level 2: 1,000,001-4,000,000 XP, Level 3: 4,000,001-9,000,000 XP, etc.
        // Formula: level = floor(sqrt(xp/1000000) + 0.5) + 1
        // This creates exponential growth: each level requires MASSIVELY more XP
        let base = max(1, Int(floor(sqrt(Double(xp) / 1000000.0) + 0.5)) + 1)
        return min(max(1, base), 999)
    }

    // XP needed to reach a given level based on the same curve as calculateLevel
    static func xpForLevel(_ level: Int) -> Int {
        let safeLevel = max(1, level)
        // Invert: level = floor(sqrt(xp/1000000) + 0.5) + 1 ⇒ xp ≈ 1000000 * (level - 1)^2
        // This gives us the XP threshold for reaching each level
        let xpThreshold = 1000000.0 * pow(Double(safeLevel - 1), 2.0)
        return max(0, Int(xpThreshold.rounded()))
    }

    // XP threshold for the next level; used for progress bars
    var xpToNextLevel: Int {
        AppStore.xpForLevel(level + 1) - AppStore.xpForLevel(level)
    }
    
    // Current XP progress within the current level
    var currentLevelProgress: Int {
        xp - AppStore.xpForLevel(level)
    }

    private struct Persisted: Codable {
        let xp: Int
        let streak: Int
        let lastPractice: Date?
        let completedIDs: [String]
        let username: String
        let level: Int
        let achievements: [String]?
        let weeklyGoal: Int?
        let currentWeekXP: Int?
        let studyStreak: Int?
        let lastStudyDate: Date?
        let dailyGoal: Int?
        let currentDayXP: Int?
        let totalStudyTime: Int?
        let perfectLessons: Int?
        let currentStreak: Int?
        let longestStreak: Int?
        let selectedTheme: String?
        let notificationsEnabled: Bool?
        let soundEnabled: Bool?
        let hapticsEnabled: Bool?
        let isProUser: Bool?
        let proSubscriptionExpiryDate: Date?
        let hasAttemptedQuestion: Bool?
        let dailyGoals: [DailyGoal]?
        let lastDailyGoalResetDate: Date?
        let totalDailyGoalsCompleted: Int?
        let todayDailyGoalsXP: Int?
        
        init(xp: Int, streak: Int, lastPractice: Date?, completedIDs: [String], username: String, level: Int, achievements: [String]? = nil, weeklyGoal: Int? = nil, currentWeekXP: Int? = nil, studyStreak: Int? = nil, lastStudyDate: Date? = nil, dailyGoal: Int? = nil, currentDayXP: Int? = nil, totalStudyTime: Int? = nil, perfectLessons: Int? = nil, currentStreak: Int? = nil, longestStreak: Int? = nil, selectedTheme: String? = nil, notificationsEnabled: Bool? = nil, soundEnabled: Bool? = nil, hapticsEnabled: Bool? = nil, isProUser: Bool? = nil, proSubscriptionExpiryDate: Date? = nil, hasAttemptedQuestion: Bool? = nil, dailyGoals: [DailyGoal]? = nil, lastDailyGoalResetDate: Date? = nil, totalDailyGoalsCompleted: Int? = nil, todayDailyGoalsXP: Int? = nil) {
            self.xp = xp
            self.streak = streak
            self.lastPractice = lastPractice
            self.completedIDs = completedIDs
            self.username = username
            self.level = level
            self.achievements = achievements
            self.weeklyGoal = weeklyGoal
            self.currentWeekXP = currentWeekXP
            self.studyStreak = studyStreak
            self.lastStudyDate = lastStudyDate
            self.dailyGoal = dailyGoal
            self.currentDayXP = currentDayXP
            self.totalStudyTime = totalStudyTime
            self.perfectLessons = perfectLessons
            self.currentStreak = currentStreak
            self.longestStreak = longestStreak
            self.selectedTheme = selectedTheme
            self.notificationsEnabled = notificationsEnabled
            self.soundEnabled = soundEnabled
            self.hapticsEnabled = hapticsEnabled
            self.isProUser = isProUser
            self.proSubscriptionExpiryDate = proSubscriptionExpiryDate
            self.hasAttemptedQuestion = hasAttemptedQuestion
            self.dailyGoals = dailyGoals
            self.lastDailyGoalResetDate = lastDailyGoalResetDate
            self.totalDailyGoalsCompleted = totalDailyGoalsCompleted
            self.todayDailyGoalsXP = todayDailyGoalsXP
        }
    }
}

// MARK: - Content Provider

struct ContentProvider {
    // Helper to pad a base array to ~50 MCQs using variations
    private static func padToFifty(_ base: [Question], topic: String) -> [Question] {
        if base.count >= 50 { return base }
        var questions = base
        var i = 0
        while questions.count < 50 {
            let seed = base[i % max(1, base.count)]
            let q = Question(
                prompt: seed.prompt,
                choices: seed.choices,
                correctIndex: seed.correctIndex,
                hint: seed.hint,
                explanation: seed.explanation,
                difficulty: seed.difficulty,
                tags: seed.tags + ["review", topic]
            )
            questions.append(q)
            i += 1
        }
        return questions
    }
    // Expanded DCF question bank for demo
    static let dcfQuestions: [Question] = [
        Question(prompt: "What is the terminal value in a DCF model?",
                 choices: ["Present value of cash flows after the projection period", "Sum of unlevered free cash flows", "Enterprise value minus net debt", "Book value of equity"],
                 correctIndex: 0,
                 hint: "It's beyond the explicit forecast period.",
                 explanation: "Terminal value captures the present value of cash flows generated after the explicit forecast period.",
                 difficulty: .intermediate,
                 tags: ["DCF", "Terminal Value"]),
        Question(prompt: "Which discount rate is typically used to discount UFCF?",
                 choices: ["Cost of Equity", "WACC", "Cost of Debt", "Risk-free rate"],
                 correctIndex: 1,
                 hint: "Blends debt and equity.",
                 explanation: "Unlevered free cash flows are discounted at WACC because they accrue to all capital providers.",
                 difficulty: .intermediate,
                 tags: ["WACC", "Discount Rate"]),
        Question(prompt: "UFCF is most closely defined as:",
                 choices: ["EBITDA − Capex − ΔNWC − Taxes on EBIT", "Net Income + D&A − Capex", "Operating Cash Flow − Capex", "EBIT − Taxes − Capex"],
                 correctIndex: 0,
                 hint: "Start from EBITDA and remove reinvestment and taxes on operating income.",
                 explanation: "A common formulation: EBITDA − Taxes on EBIT − Capex − Change in NWC.",
                 difficulty: .intermediate,
                 tags: ["UFCF"]),
        Question(prompt: "All else equal, higher WACC will:",
                 choices: ["Increase enterprise value", "Decrease enterprise value", "Not affect enterprise value", "Only affect equity value"],
                 correctIndex: 1,
                 hint: "Discount rate up → PV down.",
                 explanation: "A higher discount rate reduces the present value of cash flows, lowering EV.",
                 difficulty: .beginner,
                 tags: ["WACC", "Sensitivity"]),
        Question(prompt: "In a perpetuity growth terminal value, which formula is used?",
                 choices: ["TV = FCF_(n+1) / (WACC − g)", "TV = EBIT × (1 − t) / WACC", "TV = EBITDA × Exit Multiple", "TV = FCF_n × (1 + g) × WACC"],
                 correctIndex: 0,
                 hint: "Gordon Growth.",
                 explanation: "Using the Gordon Growth formula with next period FCF.",
                 difficulty: .beginner,
                 tags: ["Terminal Value", "Perpetuity"]),
        Question(prompt: "Which is NOT typically included in change in net working capital?",
                 choices: ["Accounts Receivable", "Inventory", "Accounts Payable", "Cash & Cash Equivalents"],
                 correctIndex: 3,
                 hint: "It's the operating cash buffer, not financing.",
                 explanation: "Cash is excluded; NWC focuses on operating current assets and liabilities.",
                 difficulty: .beginner,
                 tags: ["NWC"]),
        Question(prompt: "Exit multiple method terminal value commonly uses:",
                 choices: ["P/E", "EV/EBITDA", "P/BV", "Dividend Yield"],
                 correctIndex: 1,
                 hint: "Enterprise metric on an enterprise flow.",
                 explanation: "EV/EBITDA is the most common EV-based terminal multiple.",
                 difficulty: .beginner,
                 tags: ["Terminal Value", "Multiples"]),
        Question(prompt: "Rising leverage (holding business risk constant) generally:",
                 choices: ["Lowers WACC due to tax shield forever", "Initially lowers then may raise WACC due to financial risk", "Does not affect WACC", "Always raises WACC"],
                 correctIndex: 1,
                 hint: "Tradeoff theory.",
                 explanation: "Debt tax shields help until financial distress risk increases the cost of capital.",
                 difficulty: .advanced,
                 tags: ["Capital Structure", "WACC"]),
        Question(prompt: "To move from enterprise value to equity value, you typically:",
                 choices: ["Add net debt and minority interest", "Subtract net debt, add cash, subtract preferred and minority interest", "Add cash and preferred", "Subtract cash only"],
                 correctIndex: 1,
                 hint: "Bridge from EV to equity.",
                 explanation: "Equity Value = EV − Net Debt − Preferred − Minority + Non-operating Assets (e.g., excess cash).",
                 difficulty: .intermediate,
                 tags: ["EV to Equity"]),
        Question(prompt: "Using mid-year convention generally:",
                 choices: ["Lowers PV", "Raises PV", "Has no effect", "Only changes terminal value"],
                 correctIndex: 1,
                 hint: "Earlier receipt → higher PV.",
                 explanation: "Treating cash flows as received throughout the year increases present value vs year-end.",
                 difficulty: .intermediate,
                 tags: ["DCF Mechanics"]),
        Question(prompt: "Which growth rate is most critical and most frequently sanity-checked in perpetuity method?",
                 choices: ["Revenue CAGR", "EBITDA margin", "Perpetuity growth g", "Capex growth"],
                 correctIndex: 2,
                 hint: "Must be realistic vs economy.",
                 explanation: "g should be ≤ long-term nominal GDP growth for a mature firm.",
                 difficulty: .intermediate,
                 tags: ["Perpetuity", "Assumptions"]),
        Question(prompt: "A firm with significant NOLs (net operating losses) will most directly affect which DCF component?",
                 choices: ["WACC", "Taxes on EBIT (NOPAT)", "Capex", "Working capital"],
                 correctIndex: 1,
                 hint: "Tax shield.",
                 explanation: "NOLs reduce cash taxes, increasing UFCF until NOLs are used up.",
                 difficulty: .advanced,
                 tags: ["Taxes", "NOLs"]),
        Question(prompt: "If capex is persistently below depreciation in a steady-state business, long-term impact is most likely:",
                 choices: ["Asset base shrinks and growth may slow", "Margins expand indefinitely", "Working capital explodes", "No impact"],
                 correctIndex: 0,
                 hint: "Maintenance vs growth spend.",
                 explanation: "Under-investment erodes capacity or competitiveness over time.",
                 difficulty: .intermediate,
                 tags: ["Capex", "Sustainability"]),
        Question(prompt: "Which is MOST appropriate for unlevered free cash flow?",
                 choices: ["Add back interest expense", "Subtract interest expense", "Use net income as-is", "Add dividend payments"],
                 correctIndex: 0,
                 hint: "Unlevered ignores financing cash flows.",
                 explanation: "UFCF reflects cash available to all providers; interest is a financing cost and is excluded.",
                 difficulty: .beginner,
                 tags: ["UFCF", "Capital Structure"]),
        Question(prompt: "Which scenario would most likely justify using an exit multiple over a perpetuity growth method?",
                 choices: ["Mature stable firm in a developed market", "Industry trades on well-established EV/EBITDA comps", "Hypergrowth with negative margins", "No comparable companies"],
                 correctIndex: 1,
                 hint: "Market-anchored approach.",
                 explanation: "When reliable trading comps exist, a market-aligned exit multiple can be appropriate.",
                 difficulty: .intermediate,
                 tags: ["Terminal Value"]),
        Question(prompt: "Increasing accounts payable (other things equal) typically:",
                 choices: ["Decreases UFCF", "Increases UFCF", "No change to UFCF", "Only affects WACC"],
                 correctIndex: 1,
                 hint: "Supplier financing.",
                 explanation: "Higher payables reduce cash outflow, boosting free cash flow in the period of increase.",
                 difficulty: .beginner,
                 tags: ["NWC"]),
        Question(prompt: "Which tax rate should be used for NOPAT in DCF?",
                 choices: ["Statutory tax rate", "Cash tax rate", "Normalized long-term effective tax rate", "Marginal investor tax rate"],
                 correctIndex: 2,
                 hint: "Reflect sustainable economics.",
                 explanation: "A normalized effective rate better captures long-run steady-state profitability.",
                 difficulty: .advanced,
                 tags: ["Taxes"]),
        Question(prompt: "If WACC equals g in the Gordon Growth formula, terminal value:",
                 choices: ["Is zero", "Goes to infinity", "Equals last year's FCF", "Is negative"],
                 correctIndex: 1,
                 hint: "Denominator.",
                 explanation: "TV = FCF_(n+1)/(WACC−g): denominator goes to zero, value explodes—an impossibility signal.",
                 difficulty: .advanced,
                 tags: ["Perpetuity"]),
        Question(prompt: "Which item is typically treated as non-operating and added/subtracted outside UFCF?",
                 choices: ["Stock-based compensation", "Excess cash", "Accrued expenses", "Deferred revenue"],
                 correctIndex: 1,
                 hint: "EV to equity bridge.",
                 explanation: "Excess cash is a non-operating asset and is added when moving from EV to equity value.",
                 difficulty: .intermediate,
                 tags: ["EV to Equity", "Non-operating"]),
        Question(prompt: "Which statement about mid-year convention is TRUE?",
                 choices: ["It reduces terminal value only", "It assumes cash flows occur at period end", "It assumes cash flows occur evenly through the period", "It has no effect on PV"],
                 correctIndex: 2,
                 hint: "Timing assumption.",
                 explanation: "Mid-year convention models cash flows as received throughout the year.",
                 difficulty: .beginner,
                 tags: ["DCF Mechanics"]),
        Question(prompt: "Levered vs unlevered DCF difference is primarily in:",
                 choices: ["Whether WACC or cost of equity discounts cash flows", "The projection of revenue", "Capex treatment", "Working capital definition"],
                 correctIndex: 0,
                 hint: "Which cash flows?",
                 explanation: "Levered DCF discounts LFCF at cost of equity; unlevered discounts UFCF at WACC.",
                 difficulty: .intermediate,
                 tags: ["Levered vs Unlevered"]),
        Question(prompt: "Which is a sanity check when picking exit multiple?",
                 choices: ["Ensure it equals current trading multiple exactly", "Ensure implied multiple aligns with long-term industry range", "Ignore cyclicality", "Pick the highest to raise value"],
                 correctIndex: 1,
                 hint: "Reasonableness over precision.",
                 explanation: "The implied TV multiple should make sense vs historical/peer ranges and fundamentals.",
                 difficulty: .intermediate,
                 tags: ["Terminal Value", "Comps"]),
        Question(prompt: "What happens to DCF value if forecast FCF timing shifts later but totals are unchanged?",
                 choices: ["Value increases", "Value decreases", "Value unchanged", "Only equity value changes"],
                 correctIndex: 1,
                 hint: "Time value of money.",
                 explanation: "Later cash flows are worth less today, so EV declines.",
                 difficulty: .beginner,
                 tags: ["Timing"]),
        Question(prompt: "Which component typically links to revenue growth and margin expansion in DCF?",
                 choices: ["WACC", "Terminal multiple", "Explicit forecast FCF", "Net debt"],
                 correctIndex: 2,
                 hint: "First 5 years.",
                 explanation: "Forecast period FCF reflects operating assumptions like growth and margins.",
                 difficulty: .beginner,
                 tags: ["Forecast"]),
        Question(prompt: "Reasonable long-run g (developed market, mature firm) is often set to:",
                 choices: ["Nominal GDP growth or CPI+", "Company's historical revenue CAGR", "Risk-free rate − inflation", "Equity risk premium"],
                 correctIndex: 0,
                 hint: "Macro anchor.",
                 explanation: "Long-run growth should not exceed nominal GDP for a mature firm.",
                 difficulty: .intermediate,
                 tags: ["Perpetuity", "Assumptions"]),
        Question(prompt: "If D&A > Capex for many years in the model, you should:",
                 choices: ["Increase WACC", "Lower margins", "Revisit capex or growth assumptions", "Raise terminal multiple"],
                 correctIndex: 2,
                 hint: "Economic consistency.",
                 explanation: "Sustained under-investment is inconsistent with stable growth; adjust reinvestment.",
                 difficulty: .advanced,
                 tags: ["Capex", "Quality Check"]),
        Question(prompt: "Using EV/EBIT for exit multiple vs EV/EBITDA mainly differs by:",
                 choices: ["Treatment of depreciation", "Treatment of taxes only", "Treatment of interest", "No difference"],
                 correctIndex: 0,
                 hint: "Pre vs post D&A.",
                 explanation: "EBIT includes D&A impact; EBITDA excludes it—important for capital intensity.",
                 difficulty: .intermediate,
                 tags: ["Multiples"]),
        Question(prompt: "To move from EV to per-share equity value, you must also:",
                 choices: ["Divide by EBITDA", "Subtract net debt and divide by diluted shares", "Add capex and divide by basic shares", "Multiply by P/E"],
                 correctIndex: 1,
                 hint: "Cap table matters.",
                 explanation: "Equity Value = EV − Net Debt − Pref − NCI + Non-op assets; then divide by fully diluted shares.",
                 difficulty: .beginner,
                 tags: ["Equity Value"]),
        Question(prompt: "Which of the following most increases sensitivity of EV to WACC changes?",
                 choices: ["Longer forecast horizon and higher terminal weight", "Shorter forecast horizon", "Lower terminal value proportion", "Higher current cash balance"],
                 correctIndex: 0,
                 hint: "Discounting further-out flows.",
                 explanation: "The further out (and larger) the terminal portion, the more sensitive the PV is to the discount rate.",
                 difficulty: .advanced,
                 tags: ["Sensitivity", "WACC"])
    ]
    
    // Accounting Basics Level 1 Questions
    static let accountingBasicsLevel1Questions: [Question] = [
        Question(
            prompt: "Which statement shows a company's profitability over a period of time?",
            choices: ["Cash Flow Statement", "Income Statement", "Balance Sheet", "Retained Earnings Statement"],
            correctIndex: 1,
            hint: nil,
            explanation: "The Income Statement reports revenues, expenses, and profit (or loss) over a specific period like a quarter or year. The Balance Sheet is a snapshot at a point in time, while the Cash Flow Statement shows cash movements, not profitability.",
            difficulty: .beginner,
            tags: ["Financial Statements"]
        ),
        Question(
            prompt: "What does the Balance Sheet show?",
            choices: ["Profits over a year", "Cash inflows and outflows", "Assets, Liabilities, and Equity at a point in time", "Only cash balances"],
            correctIndex: 2,
            hint: nil,
            explanation: "The Balance Sheet is a snapshot on a specific date showing what a company owns (assets), owes (liabilities), and the residual value to shareholders (equity). It doesn't show performance over time.",
            difficulty: .beginner,
            tags: ["Financial Statements"]
        ),
        Question(
            prompt: "Which equation must always hold true?",
            choices: ["Assets = Revenue – Expenses", "Assets = Liabilities – Equity", "Assets = Cash + Equity", "Assets = Liabilities + Equity"],
            correctIndex: 3,
            hint: nil,
            explanation: "This is the fundamental accounting equation. Assets (what you own) are always financed by either debt (liabilities) or ownership (equity). The equation always balances.",
            difficulty: .beginner,
            tags: ["Accounting Equation"]
        ),
        Question(
            prompt: "Why do companies need three financial statements instead of one?",
            choices: ["To hide accounting complexity", "To compute book value", "To reconcile profit with cash flow", "To report dividends separately"],
            correctIndex: 2,
            hint: nil,
            explanation: "Companies need three statements because profit ≠ cash. The Income Statement shows profitability, the Cash Flow Statement shows actual cash movements, and the Balance Sheet shows financial position. Together they reconcile accrual accounting with cash reality.",
            difficulty: .beginner,
            tags: ["Financial Statements"]
        ),
        Question(
            prompt: "Which statement adjusts Net Income for non-cash and timing differences?",
            choices: ["Balance Sheet", "Income Statement", "Statement of Shareholders' Equity", "Cash Flow Statement"],
            correctIndex: 3,
            hint: nil,
            explanation: "The Cash Flow Statement starts with Net Income and adjusts for non-cash items (depreciation, stock-based compensation) and timing differences (working capital changes) to show actual cash generated or used.",
            difficulty: .beginner,
            tags: ["Cash Flow Statement"]
        ),
        Question(
            prompt: "Which of the following is not a current asset?",
            choices: ["Cash", "Accounts Receivable", "Inventory", "Goodwill"],
            correctIndex: 3,
            hint: nil,
            explanation: "Current assets convert to cash within one year and include cash, A/R, inventory, and prepaid expenses. Goodwill is a long-term intangible asset from acquisitions that doesn't convert to cash.",
            difficulty: .beginner,
            tags: ["Balance Sheet"]
        ),
        Question(
            prompt: "What happens when Accounts Payable increases?",
            choices: ["Cash decreases", "Revenue decreases", "Cash increases", "Equity decreases"],
            correctIndex: 2,
            hint: nil,
            explanation: "When Accounts Payable increases, the company has received goods/services but hasn't paid yet. Delaying payment means keeping cash longer, so cash increases (or doesn't decrease as much).",
            difficulty: .beginner,
            tags: ["Working Capital"]
        ),
        Question(
            prompt: "What is the \"bottom line\" of the Income Statement?",
            choices: ["Operating Income", "EBITDA", "Net Income", "Retained Earnings"],
            correctIndex: 2,
            hint: nil,
            explanation: "Net Income is the final line (\"bottom line\") of the Income Statement after all revenues, expenses, interest, and taxes. It represents profit available to shareholders and flows to Retained Earnings on the Balance Sheet.",
            difficulty: .beginner,
            tags: ["Income Statement"]
        ),
        Question(
            prompt: "Which of the following items always appears on the Income Statement?",
            choices: ["Capital Expenditures", "Share Repurchases", "Issuing Debt", "Interest Expense"],
            correctIndex: 3,
            hint: nil,
            explanation: "Interest Expense always appears on the Income Statement as a cost of borrowing. CapEx appears on the Cash Flow Statement (investing), while share repurchases and debt issuance are financing activities.",
            difficulty: .beginner,
            tags: ["Income Statement"]
        ),
        Question(
            prompt: "Which of the following never appears on the Income Statement?",
            choices: ["Depreciation", "COGS", "Dividends", "Taxes"],
            correctIndex: 2,
            hint: nil,
            explanation: "Dividends are a distribution of profits to shareholders, not an expense. They appear on the Cash Flow Statement (financing section) and reduce Retained Earnings, but never hit the Income Statement.",
            difficulty: .beginner,
            tags: ["Income Statement"]
        )
    ]
    
    // Accounting Basics Level 2 Questions
    static let accountingBasicsLevel2Questions: [Question] = [
        Question(
            prompt: "What happens when Inventory decreases?",
            choices: ["Cash increases", "Cash decreases", "Liabilities increase", "Revenue decreases"],
            correctIndex: 0,
            hint: nil,
            explanation: "When inventory decreases, it means goods were sold, which increases cash.",
            difficulty: .intermediate,
            tags: ["Inventory", "Cash Flow"]
        ),
        Question(
            prompt: "Which is a non-cash expense that reduces taxes?",
            choices: ["Rent", "Depreciation", "Salaries", "Dividends"],
            correctIndex: 1,
            hint: nil,
            explanation: "Depreciation is a non-cash expense that reduces taxable income.",
            difficulty: .intermediate,
            tags: ["Depreciation", "Taxes"]
        ),
        Question(
            prompt: "If Depreciation increases by $10 and the tax rate is 40%, Net Income:",
            choices: ["Falls by $10", "Falls by $6", "Rises by $4", "Stays the same"],
            correctIndex: 1,
            hint: nil,
            explanation: "Higher depreciation reduces pre-tax income by $10, and taxes by $4, so net income falls by $6.",
            difficulty: .intermediate,
            tags: ["Depreciation", "Taxes", "Net Income"]
        ),
        Question(
            prompt: "Stock-based compensation:",
            choices: ["Increases Net Income", "Reduces Net Income but doesn't use cash", "Doesn't affect any statement", "Increases cash flow and taxes"],
            correctIndex: 1,
            hint: nil,
            explanation: "Stock compensation is an expense that reduces net income but doesn't require cash payment.",
            difficulty: .intermediate,
            tags: ["Stock Compensation", "Expenses"]
        ),
        Question(
            prompt: "Amortization is associated with which account?",
            choices: ["PP&E", "Other Intangible Assets", "Accounts Payable", "Inventory"],
            correctIndex: 1,
            hint: nil,
            explanation: "Amortization applies to intangible assets like patents, trademarks, and goodwill.",
            difficulty: .intermediate,
            tags: ["Amortization", "Intangible Assets"]
        ),
        Question(
            prompt: "An increase in Prepaid Expenses means:",
            choices: ["Cash flow increases", "Cash flow decreases", "Revenue increases", "Liabilities increase"],
            correctIndex: 1,
            hint: nil,
            explanation: "Prepaid expenses represent cash paid in advance, so an increase reduces cash flow.",
            difficulty: .intermediate,
            tags: ["Prepaid Expenses", "Cash Flow"]
        ),
        Question(
            prompt: "Deferred Revenue increases when:",
            choices: ["Cash is collected before delivery", "Cash is collected after delivery", "Inventory is sold", "An expense is incurred"],
            correctIndex: 0,
            hint: nil,
            explanation: "Deferred revenue represents cash received before goods/services are delivered.",
            difficulty: .intermediate,
            tags: ["Deferred Revenue", "Cash Collection"]
        ),
        Question(
            prompt: "Which section of the Cash Flow Statement shows capital expenditures?",
            choices: ["Operating Activities", "Investing Activities", "Financing Activities", "Retained Earnings"],
            correctIndex: 1,
            hint: nil,
            explanation: "Capital expenditures are investments in long-term assets, shown in Investing Activities.",
            difficulty: .intermediate,
            tags: ["Cash Flow Statement", "Capital Expenditures"]
        ),
        Question(
            prompt: "When a company issues $100 of debt, what happens to cash?",
            choices: ["Decreases by $100", "Increases by $100", "No change", "Increases by $50"],
            correctIndex: 1,
            hint: nil,
            explanation: "Issuing debt brings in cash, increasing the company's cash balance.",
            difficulty: .intermediate,
            tags: ["Debt Issuance", "Cash"]
        ),
        Question(
            prompt: "When a company repurchases shares, which account changes?",
            choices: ["Treasury Stock", "Accounts Receivable", "Retained Earnings", "Deferred Revenue"],
            correctIndex: 0,
            hint: nil,
            explanation: "Share repurchases increase the Treasury Stock account (contra-equity).",
            difficulty: .intermediate,
            tags: ["Share Repurchase", "Treasury Stock"]
        )
    ]
    
    // Accounting Basics Level 3 Questions
    static let accountingBasicsLevel3Questions: [Question] = [
        Question(
            prompt: "When Accounts Receivable increases by $50, what happens?",
            choices: ["Cash increases by $50", "Cash decreases by $50", "Net Income decreases by $50", "Liabilities increase by $50"],
            correctIndex: 1,
            hint: nil,
            explanation: "Higher AR means more sales on credit, reducing cash flow in the period.",
            difficulty: .advanced,
            tags: ["Accounts Receivable", "Cash Flow"]
        ),
        Question(
            prompt: "If a company pays off $20 of Accounts Payable, cash:",
            choices: ["Increases by $20", "Decreases by $20", "Unchanged", "Increases by $10"],
            correctIndex: 1,
            hint: nil,
            explanation: "Paying off payables requires cash outflow, reducing the cash balance.",
            difficulty: .advanced,
            tags: ["Accounts Payable", "Cash Flow"]
        ),
        Question(
            prompt: "If Inventory increases by $30, assuming no sale, what happens?",
            choices: ["Cash decreases $30", "Cash increases $30", "Net Income decreases $30", "Equity decreases $30"],
            correctIndex: 0,
            hint: nil,
            explanation: "Inventory purchases require cash payment, reducing cash balance.",
            difficulty: .advanced,
            tags: ["Inventory", "Cash Flow"]
        ),
        Question(
            prompt: "Deferred Tax Liabilities arise because:",
            choices: ["A firm pays less tax now than it owes later", "A firm pays more tax now than owed later", "Taxes are entirely non-cash", "Taxes are prepaid"],
            correctIndex: 0,
            hint: nil,
            explanation: "DTL represents taxes that will be paid in future periods due to timing differences.",
            difficulty: .advanced,
            tags: ["Deferred Tax Liabilities", "Taxes"]
        ),
        Question(
            prompt: "Which two accounts are linked when Depreciation rises?",
            choices: ["PP&E and Cash", "PP&E and Retained Earnings", "PP&E and Accounts Payable", "PP&E and Deferred Revenue"],
            correctIndex: 1,
            hint: nil,
            explanation: "Depreciation reduces PP&E and flows through to reduce Retained Earnings via the Income Statement.",
            difficulty: .advanced,
            tags: ["Depreciation", "PP&E", "Retained Earnings"]
        ),
        Question(
            prompt: "If a company issues $100 of new equity, which changes occur?",
            choices: ["Cash ↑ $100, Common Stock & APIC ↑ $100", "Cash ↓ $100, Retained Earnings ↓ $100", "Cash ↑ $50, Debt ↑ $50", "No changes"],
            correctIndex: 0,
            hint: nil,
            explanation: "Equity issuance increases cash and equity accounts (Common Stock + Additional Paid-in Capital).",
            difficulty: .advanced,
            tags: ["Equity Issuance", "Cash", "Common Stock"]
        ),
        Question(
            prompt: "A company sells equipment for $120 that had a $100 book value. What is the impact?",
            choices: ["Gain of $20 on IS; Cash ↑ $120", "Gain of $20 on IS; Cash ↑ $20", "Loss of $20 on IS; Cash ↓ $120", "No change in Cash"],
            correctIndex: 0,
            hint: nil,
            explanation: "Selling above book value creates a $20 gain on the Income Statement and brings in $120 cash.",
            difficulty: .advanced,
            tags: ["Asset Sale", "Gain/Loss", "Cash"]
        ),
        Question(
            prompt: "Paying a $5 dividend affects which accounts?",
            choices: ["Cash ↓ $5; Retained Earnings ↓ $5", "Cash ↑ $5; Retained Earnings ↑ $5", "Cash ↓ $5; Deferred Revenue ↓ $5", "Cash ↑ $5; AP ↑ $5"],
            correctIndex: 0,
            hint: nil,
            explanation: "Dividends reduce cash and retained earnings, representing a distribution to shareholders.",
            difficulty: .advanced,
            tags: ["Dividends", "Cash", "Retained Earnings"]
        ),
        Question(
            prompt: "A company prepays $10 in rent. Immediate cash effect?",
            choices: ["Cash decreases $10", "Cash increases $10", "No effect", "Cash decreases $5"],
            correctIndex: 0,
            hint: nil,
            explanation: "Prepaid rent requires immediate cash payment, reducing the cash balance.",
            difficulty: .advanced,
            tags: ["Prepaid Rent", "Cash Flow"]
        ),
        Question(
            prompt: "Which item is non-operational on the Balance Sheet?",
            choices: ["Accounts Receivable", "Inventory", "Deferred Revenue", "Long-Term Debt"],
            correctIndex: 3,
            hint: nil,
            explanation: "Long-term debt is a financing activity, not part of core operations like AR, inventory, or deferred revenue.",
            difficulty: .advanced,
            tags: ["Balance Sheet", "Operating vs Non-operating"]
        )
    ]
    
    // Accounting Basics Level 4 Questions
    static let accountingBasicsLevel4Questions: [Question] = [
        Question(
            prompt: "Depreciation increases by $10, tax rate 40%. What is the full effect?",
            choices: ["Profit ↓ $6, Cash ↑ $4, Equipment ↓ $10, Retained Earnings ↓ $6", "Profit ↑ $6, Cash ↓ $4, Equipment ↑ $10", "Profit ↓ $10, Cash ↓ $10, Equipment ↓ $10", "Profit ↓ $4, Cash ↑ $6"],
            correctIndex: 0,
            hint: nil,
            explanation: "Depreciation reduces profit by $6 (after tax), saves $4 in cash taxes, reduces equipment by $10, and lowers retained earnings by $6.",
            difficulty: .expert,
            tags: ["Depreciation", "Tax Effects", "Cash Flow"]
        ),
        Question(
            prompt: "Accounts Receivable decreases by $20. What happens?",
            choices: ["Cash ↑ $20, Receivables ↓ $20", "Cash ↓ $20, Receivables ↑ $20", "Profit ↓ $20, Retained Earnings ↓ $20", "Cash no change"],
            correctIndex: 0,
            hint: nil,
            explanation: "Lower AR means customers paid their bills, increasing cash and reducing receivables.",
            difficulty: .expert,
            tags: ["Accounts Receivable", "Cash Collection"]
        ),
        Question(
            prompt: "Which action affects only the Cash Flow Statement and Balance Sheet?",
            choices: ["Buying equipment", "Paying interest", "Depreciation", "Higher sales"],
            correctIndex: 0,
            hint: nil,
            explanation: "Equipment purchases affect cash flow (investing) and balance sheet (PP&E), but not income statement until depreciation.",
            difficulty: .expert,
            tags: ["Equipment Purchase", "Financial Statements"]
        ),
        Question(
            prompt: "Deferred Revenue decreases by $10. What is the impact?",
            choices: ["Sales ↑ $10, Profit ↑ $6, Cash ↓ $10", "Sales ↓ $10, Profit ↓ $6, Cash ↑ $10", "No Income change", "Cash ↑ $10, Retained Earnings ↑ $10"],
            correctIndex: 0,
            hint: nil,
            explanation: "Lower deferred revenue means revenue was recognized, increasing sales and profit (after tax), but cash was already collected.",
            difficulty: .expert,
            tags: ["Deferred Revenue", "Revenue Recognition"]
        ),
        Question(
            prompt: "The company buys equipment for $100 using debt. What is the immediate result?",
            choices: ["Equipment ↑ $100, Debt ↑ $100", "Equipment ↓ $100, Debt ↑ $100", "Equipment ↑ $100, Equity ↑ $100", "Cash ↓ $100, Retained Earnings ↓ $100"],
            correctIndex: 0,
            hint: nil,
            explanation: "Debt-financed equipment purchase increases both equipment (asset) and debt (liability) by $100.",
            difficulty: .expert,
            tags: ["Equipment Purchase", "Debt Financing"]
        ),
        Question(
            prompt: "After one year, interest is 10%, $20 of debt is repaid, and $10 depreciation occurs (40% tax). How does profit change?",
            choices: ["Profit ↓ $12", "Profit ↑ $12", "No change", "Profit ↑ $4"],
            correctIndex: 0,
            hint: nil,
            explanation: "Interest expense reduces profit by $10, depreciation by $6 (after tax), totaling $12 reduction.",
            difficulty: .expert,
            tags: ["Interest Expense", "Depreciation", "Profit Impact"]
        ),
        Question(
            prompt: "The company raises $100 of new debt and repays $30 of old debt. What is the cash effect?",
            choices: ["Cash +$70", "Cash +$100", "Cash –$30", "No change"],
            correctIndex: 0,
            hint: nil,
            explanation: "Net cash effect is $100 inflow from new debt minus $30 outflow for repayment = +$70.",
            difficulty: .expert,
            tags: ["Debt Management", "Cash Flow"]
        ),
        Question(
            prompt: "The Deferred Tax Liability decreases. What does this mean?",
            choices: ["Paid more cash tax than book tax", "Paid less cash tax", "Will pay more tax later", "Cash fell"],
            correctIndex: 0,
            hint: nil,
            explanation: "Lower DTL means the company paid more cash taxes than the book tax expense, reducing the future tax obligation.",
            difficulty: .expert,
            tags: ["Deferred Tax Liability", "Cash vs Book Tax"]
        ),
        Question(
            prompt: "The company issues $100 of stock and repurchases $60. What happens to equity?",
            choices: ["+$40", "+$60", "No change", "–$40"],
            correctIndex: 0,
            hint: nil,
            explanation: "Net equity effect is $100 increase from issuance minus $60 decrease from repurchase = +$40.",
            difficulty: .expert,
            tags: ["Equity Issuance", "Share Repurchase", "Net Effect"]
        ),
        Question(
            prompt: "The company records $10 in stock-based pay. What happens overall?",
            choices: ["Profit ↓ $6, Cash ↑ $4, Equity ↑, more shares", "Profit ↑ $10, Cash ↑ $10", "Profit ↓ $10, Cash ↓ $10", "No change"],
            correctIndex: 0,
            hint: nil,
            explanation: "Stock compensation reduces profit by $6 (after tax), saves $4 in cash taxes, increases equity, and dilutes existing shares.",
            difficulty: .expert,
            tags: ["Stock Compensation", "Dilution", "Tax Effects"]
        )
    ]
    
    // Enterprise Value/Valuation Level 1 Questions
    static let enterpriseValueLevel1Questions: [Question] = [
        Question(
            prompt: "What does \"Enterprise Value\" represent?",
            choices: ["The company's market capitalization", "The value of the company's core operations to all investors", "The value of equity plus dividends", "The total assets on the balance sheet"],
            correctIndex: 1,
            hint: nil,
            explanation: "Enterprise Value represents the total value of a company's core operations to all capital providers (debt and equity holders).",
            difficulty: .beginner,
            tags: ["Enterprise Value", "Valuation"]
        ),
        Question(
            prompt: "What does \"Equity Value\" represent?",
            choices: ["The value to all investors", "The value of debt", "The value attributable to shareholders", "The liquidation value"],
            correctIndex: 2,
            hint: nil,
            explanation: "Equity Value represents the value attributable specifically to shareholders after all other claims are satisfied.",
            difficulty: .beginner,
            tags: ["Equity Value", "Shareholders"]
        ),
        Question(
            prompt: "Which of the following formulas correctly expresses Enterprise Value?",
            choices: ["EV = Equity Value – Debt + Cash", "EV = Equity Value + Debt – Cash", "EV = Assets – Liabilities", "EV = Market Cap + Retained Earnings"],
            correctIndex: 1,
            hint: nil,
            explanation: "Enterprise Value = Equity Value + Net Debt (Debt - Cash), representing the value to all capital providers.",
            difficulty: .beginner,
            tags: ["Enterprise Value Formula", "Net Debt"]
        ),
        Question(
            prompt: "Why do we subtract cash in the Enterprise Value formula?",
            choices: ["Cash is not an operating asset", "Cash increases net debt", "Cash always belongs to lenders", "Cash is taxed differently"],
            correctIndex: 0,
            hint: nil,
            explanation: "Cash is considered a non-operating asset that can be used to pay down debt, so it's subtracted to focus on operating value.",
            difficulty: .beginner,
            tags: ["Cash", "Non-operating Assets"]
        ),
        Question(
            prompt: "Which of the following is not a component of Enterprise Value?",
            choices: ["Debt", "Preferred Stock", "Minority Interest", "Accounts Payable"],
            correctIndex: 3,
            hint: nil,
            explanation: "Accounts Payable is an operating liability, not a capital structure component included in Enterprise Value.",
            difficulty: .beginner,
            tags: ["Enterprise Value Components", "Operating Liabilities"]
        ),
        Question(
            prompt: "What does the market capitalization of a company represent?",
            choices: ["Book value of equity", "Current share price × diluted shares outstanding", "Total debt minus cash", "Operating value"],
            correctIndex: 1,
            hint: nil,
            explanation: "Market cap = Current share price × diluted shares outstanding, representing the market value of equity.",
            difficulty: .beginner,
            tags: ["Market Capitalization", "Share Price"]
        ),
        Question(
            prompt: "Which of the following is an example of a \"non-operating asset\"?",
            choices: ["Accounts Receivable", "Inventory", "Cash and Marketable Securities", "PP&E"],
            correctIndex: 2,
            hint: nil,
            explanation: "Cash and marketable securities are non-operating assets that can be used to pay down debt or distribute to shareholders.",
            difficulty: .beginner,
            tags: ["Non-operating Assets", "Cash"]
        ),
        Question(
            prompt: "Which valuation multiple uses Enterprise Value in the numerator?",
            choices: ["P/E", "EV/EBITDA", "Price/Book", "Dividend Yield"],
            correctIndex: 1,
            hint: nil,
            explanation: "EV/EBITDA is an enterprise value multiple that compares enterprise value to EBITDA.",
            difficulty: .beginner,
            tags: ["EV Multiples", "EBITDA"]
        ),
        Question(
            prompt: "Which valuation multiple uses Equity Value in the numerator?",
            choices: ["EV/EBITDA", "EV/EBIT", "P/E", "EV/Sales"],
            correctIndex: 2,
            hint: nil,
            explanation: "P/E (Price-to-Earnings) uses equity value (market cap) in the numerator and earnings in the denominator.",
            difficulty: .beginner,
            tags: ["Equity Multiples", "P/E Ratio"]
        ),
        Question(
            prompt: "What does EBITDA approximate?",
            choices: ["Cash flow available to all investors", "Net income to equity holders", "Free cash flow to equity", "GAAP profit"],
            correctIndex: 0,
            hint: nil,
            explanation: "EBITDA approximates cash flow available to all capital providers (debt and equity holders) before capital expenditures and working capital changes.",
            difficulty: .beginner,
            tags: ["EBITDA", "Cash Flow"]
        )
    ]
    
    // Enterprise Value/Valuation Level 2 Questions
    static let enterpriseValueLevel2Questions: [Question] = [
        Question(
            prompt: "Unlevered Free Cash Flow (UFCF) equals:",
            choices: ["Net Income + D&A – CapEx – Change in WC", "EBIT × (1 – Tax Rate) + D&A – CapEx – Change in WC", "EBITDA – Taxes – CapEx – Debt Repayment", "CFO – CFI + Dividends"],
            correctIndex: 1,
            hint: nil,
            explanation: "UFCF = NOPAT + D&A – CapEx – Change in WC, where NOPAT = EBIT × (1 – Tax Rate).",
            difficulty: .intermediate,
            tags: ["UFCF", "NOPAT"]
        ),
        Question(
            prompt: "Which non-cash item is excluded when calculating UFCF?",
            choices: ["Depreciation", "Deferred Taxes", "Stock-Based Compensation", "Amortization"],
            correctIndex: 2,
            hint: nil,
            explanation: "Stock-based compensation is excluded from UFCF as it's a non-cash expense that doesn't affect cash flow.",
            difficulty: .intermediate,
            tags: ["UFCF", "Non-cash Items"]
        ),
        Question(
            prompt: "What is NOPAT?",
            choices: ["Net Operating Profit After Tax", "Net Output Per Asset Turnover", "Net Other Profit Adjusted Total", "Non-Operating Profit At Time"],
            correctIndex: 0,
            hint: nil,
            explanation: "NOPAT = Net Operating Profit After Tax = EBIT × (1 – Tax Rate).",
            difficulty: .intermediate,
            tags: ["NOPAT", "Operating Profit"]
        ),
        Question(
            prompt: "When projecting FCF, which sections of the financial statements are ignored?",
            choices: ["Operating cash flows", "Financing and most investing cash flows", "Income statement", "Working capital"],
            correctIndex: 1,
            hint: nil,
            explanation: "UFCF focuses on operating cash flows, ignoring financing activities and most investing activities.",
            difficulty: .intermediate,
            tags: ["FCF Projection", "Financial Statements"]
        ),
        Question(
            prompt: "In WACC, the after-tax Cost of Debt is calculated as:",
            choices: ["Pre-tax rate × (1 – Tax Rate)", "Pre-tax rate × (1 + Tax Rate)", "Coupon × (Tax Rate)", "Interest expense ÷ total debt"],
            correctIndex: 0,
            hint: nil,
            explanation: "After-tax cost of debt = Pre-tax rate × (1 – Tax Rate) due to tax deductibility of interest.",
            difficulty: .intermediate,
            tags: ["WACC", "Cost of Debt"]
        ),
        Question(
            prompt: "The Cost of Equity is typically estimated using:",
            choices: ["Dividend Discount Model", "CAPM: Risk-Free Rate + Beta × Equity Risk Premium", "Company's coupon rate", "EBIT ÷ Equity Value"],
            correctIndex: 1,
            hint: nil,
            explanation: "CAPM formula: Cost of Equity = Risk-Free Rate + Beta × Equity Risk Premium.",
            difficulty: .intermediate,
            tags: ["Cost of Equity", "CAPM"]
        ),
        Question(
            prompt: "What happens to WACC when a company adds moderate debt?",
            choices: ["Always increases", "Always decreases", "Usually decreases at first, then increases past a point", "Never changes"],
            correctIndex: 2,
            hint: nil,
            explanation: "Moderate debt initially lowers WACC due to tax shields, but excessive debt increases financial risk.",
            difficulty: .intermediate,
            tags: ["WACC", "Capital Structure"]
        ),
        Question(
            prompt: "Beta measures:",
            choices: ["Operating leverage", "Volatility of the company relative to the market", "Systematic accounting risk", "Dividend yield variability"],
            correctIndex: 1,
            hint: nil,
            explanation: "Beta measures the systematic risk of a stock relative to the overall market volatility.",
            difficulty: .intermediate,
            tags: ["Beta", "Risk"]
        ),
        Question(
            prompt: "What is the main reason we unlever and relever Beta?",
            choices: ["To remove the impact of capital structure differences", "To normalize for depreciation", "To match industry growth rates", "To calculate Cost of Debt"],
            correctIndex: 0,
            hint: nil,
            explanation: "Unlevering/relevering Beta removes capital structure effects to compare companies on an asset-only basis.",
            difficulty: .intermediate,
            tags: ["Beta", "Capital Structure"]
        ),
        Question(
            prompt: "If risk-free rates rise, what happens to a DCF valuation (ceteris paribus)?",
            choices: ["Increases", "Decreases", "Stays the same", "Doubles"],
            correctIndex: 1,
            hint: nil,
            explanation: "Higher risk-free rates increase WACC, reducing the present value of future cash flows.",
            difficulty: .intermediate,
            tags: ["DCF", "Risk-Free Rate", "WACC"]
        )
    ]
    
    // Enterprise Value/Valuation Level 3 Questions
    static let enterpriseValueLevel3Questions: [Question] = [
        Question(
            prompt: "The Gordon Growth formula for Terminal Value is:",
            choices: ["TV = FCF × (1 – g) / (r – g)", "TV = FCF × (1 + g) / (r – g)", "TV = EBITDA × Exit Multiple", "TV = FCF / r"],
            correctIndex: 1,
            hint: nil,
            explanation: "Gordon Growth: TV = FCF × (1 + g) / (r – g), where g is the perpetual growth rate.",
            difficulty: .advanced,
            tags: ["Terminal Value", "Gordon Growth"]
        ),
        Question(
            prompt: "The Terminal Growth Rate (g) should usually be:",
            choices: ["Negative", "5–10%", "Below GDP or inflation rate (≈1–3%)", "Equal to EBITDA growth"],
            correctIndex: 2,
            hint: nil,
            explanation: "Terminal growth should be conservative, typically below long-term GDP growth (1-3%).",
            difficulty: .advanced,
            tags: ["Terminal Growth", "Assumptions"]
        ),
        Question(
            prompt: "Using an exit multiple to calculate TV is also known as:",
            choices: ["Gordon Growth method", "Multiples method", "Market premium method", "Perpetuity formula"],
            correctIndex: 1,
            hint: nil,
            explanation: "Exit multiple method uses comparable company multiples to estimate terminal value.",
            difficulty: .advanced,
            tags: ["Terminal Value", "Exit Multiple"]
        ),
        Question(
            prompt: "Why is it important to cross-check terminal value results?",
            choices: ["To confirm D&A assumptions", "To ensure implied growth and multiple are realistic", "To double FCF accuracy", "To match peer book value"],
            correctIndex: 1,
            hint: nil,
            explanation: "Cross-checking ensures the implied assumptions (growth rates, multiples) are reasonable and consistent.",
            difficulty: .advanced,
            tags: ["Terminal Value", "Cross-checking"]
        ),
        Question(
            prompt: "Which portion of the DCF typically contributes most to total Enterprise Value?",
            choices: ["Change in Working Capital", "Terminal Value", "Discounted FCF in forecast period", "Deferred tax adjustment"],
            correctIndex: 1,
            hint: nil,
            explanation: "Terminal Value often represents 60-80% of total Enterprise Value due to the perpetuity nature.",
            difficulty: .advanced,
            tags: ["DCF", "Terminal Value", "Enterprise Value"]
        ),
        Question(
            prompt: "If the terminal multiple is too high, the implied terminal growth rate will be:",
            choices: ["Too low", "Too high", "Unchanged", "Negative"],
            correctIndex: 1,
            hint: nil,
            explanation: "Higher terminal multiples imply higher growth expectations, which may be unrealistic.",
            difficulty: .advanced,
            tags: ["Terminal Multiple", "Growth Rate"]
        ),
        Question(
            prompt: "What's the effect of a 1% increase in discount rate vs. 1% increase in revenue growth?",
            choices: ["Revenue has greater impact", "Discount rate has greater impact", "Equal effect", "Neither affects EV"],
            correctIndex: 1,
            hint: nil,
            explanation: "Discount rate changes have exponential impact on present value, while growth affects future periods.",
            difficulty: .advanced,
            tags: ["DCF Sensitivity", "Discount Rate"]
        ),
        Question(
            prompt: "The mid-year convention adjusts for:",
            choices: ["Mid-year dividend payouts", "Cash flow timing within the year", "Deferred tax reversals", "Stub periods"],
            correctIndex: 1,
            hint: nil,
            explanation: "Mid-year convention assumes cash flows occur mid-year, improving valuation accuracy.",
            difficulty: .advanced,
            tags: ["Mid-year Convention", "Cash Flow Timing"]
        ),
        Question(
            prompt: "Stub periods in a DCF occur when:",
            choices: ["The company has no debt", "Valuation date is not fiscal year-end", "Discount rate is negative", "There are missing cash flows"],
            correctIndex: 1,
            hint: nil,
            explanation: "Stub periods occur when the valuation date doesn't align with fiscal year-end.",
            difficulty: .advanced,
            tags: ["Stub Periods", "Valuation Date"]
        ),
        Question(
            prompt: "Why can a \"normalized terminal year\" be necessary?",
            choices: ["To account for unsustainable trends (e.g., one-time events)", "To extend projections", "To adjust beta", "To remove working capital"],
            correctIndex: 0,
            hint: nil,
            explanation: "Normalization removes one-time events and unsustainable trends for realistic terminal assumptions.",
            difficulty: .advanced,
            tags: ["Normalization", "Terminal Year"]
        )
    ]
    
    // Enterprise Value/Valuation Level 4 Questions
    static let enterpriseValueLevel4Questions: [Question] = [
        Question(
            prompt: "A company has FCF = $100, WACC = 10%, g = 2%. What's its Terminal Value (Gordon Growth)?",
            choices: ["$800", "$1,000", "$1,250", "$1,500"],
            correctIndex: 2,
            hint: nil,
            explanation: "TV = FCF × (1 + g) / (WACC - g) = $100 × 1.02 / (0.10 - 0.02) = $102 / 0.08 = $1,275 ≈ $1,250",
            difficulty: .expert,
            tags: ["Terminal Value", "Gordon Growth", "Calculation"]
        ),
        Question(
            prompt: "If WACC rises while Terminal Growth falls, what happens to EV?",
            choices: ["Increases", "Decreases sharply", "Stays constant", "Becomes infinite"],
            correctIndex: 1,
            hint: nil,
            explanation: "Both higher WACC and lower growth reduce terminal value, causing EV to decrease significantly.",
            difficulty: .expert,
            tags: ["DCF Sensitivity", "WACC", "Growth"]
        ),
        Question(
            prompt: "Why do you exclude interest expense when calculating UFCF?",
            choices: ["To reflect value available to all investors", "To simplify accounting", "Because it's a non-cash charge", "To reduce volatility"],
            correctIndex: 0,
            hint: nil,
            explanation: "UFCF represents cash available to all capital providers (debt and equity), so financing costs are excluded.",
            difficulty: .expert,
            tags: ["UFCF", "Interest Expense", "Capital Structure"]
        ),
        Question(
            prompt: "Which factor would increase WACC?",
            choices: ["Lower Beta", "Higher Equity Risk Premium", "Lower Risk-Free Rate", "Higher tax rate"],
            correctIndex: 1,
            hint: nil,
            explanation: "Higher Equity Risk Premium increases the cost of equity component of WACC.",
            difficulty: .expert,
            tags: ["WACC", "Equity Risk Premium"]
        ),
        Question(
            prompt: "Which assumption change impacts DCF most?",
            choices: ["CAPEX – 1%", "Tax Rate – 1%", "WACC +1%", "Inventory +1%"],
            correctIndex: 2,
            hint: nil,
            explanation: "WACC changes have exponential impact on present value due to discounting effects.",
            difficulty: .expert,
            tags: ["DCF Sensitivity", "WACC Impact"]
        ),
        Question(
            prompt: "Why does more debt initially decrease WACC?",
            choices: ["Because interest is tax deductible", "Because cost of equity falls", "Because cost of debt equals inflation", "Because leverage increases growth"],
            correctIndex: 0,
            hint: nil,
            explanation: "Tax deductibility of interest creates a tax shield, reducing the effective cost of debt.",
            difficulty: .expert,
            tags: ["WACC", "Tax Shield", "Debt"]
        ),
        Question(
            prompt: "Why can WACC later increase when too much debt is added?",
            choices: ["Equity investors demand higher returns due to risk", "Beta falls", "Tax rate drops", "Interest expense is ignored"],
            correctIndex: 0,
            hint: nil,
            explanation: "Excessive debt increases financial risk, causing equity investors to demand higher returns.",
            difficulty: .expert,
            tags: ["WACC", "Financial Risk", "Debt"]
        ),
        Question(
            prompt: "Why is a DCF unreliable for early-stage companies?",
            choices: ["They lack positive, predictable cash flows", "Their betas are too low", "Their taxes are irregular", "They don't use WACC"],
            correctIndex: 0,
            hint: nil,
            explanation: "Early-stage companies often have negative or highly volatile cash flows, making DCF assumptions unreliable.",
            difficulty: .expert,
            tags: ["DCF Limitations", "Early-stage Companies"]
        ),
        Question(
            prompt: "In an Adjusted Present Value (APV) model, what is added to the unlevered DCF result?",
            choices: ["Tax shield from debt", "Cost of equity", "Interest expense", "Dividend payout"],
            correctIndex: 0,
            hint: nil,
            explanation: "APV = Unlevered DCF + Present Value of Tax Shield from debt financing.",
            difficulty: .expert,
            tags: ["APV", "Tax Shield"]
        ),
        Question(
            prompt: "You find that 90% of your firm's EV comes from terminal value. What should you do?",
            choices: ["Accept it; normal for DCFs", "Extend projection period or reassess assumptions", "Increase WACC", "Set growth to zero"],
            correctIndex: 1,
            hint: nil,
            explanation: "High terminal value dependency suggests extending forecast period or reassessing growth assumptions.",
            difficulty: .expert,
            tags: ["Terminal Value", "DCF Validation"]
        )
    ]
    
    static let sampleLessons: [Lesson] = [
        // Finance Fundamentals - Structured Quiz System
        // Accounting Basics - Level 1
        Lesson(
            title: "Accounting Basics - Level 1",
            xpReward: 50,
            type: .multipleChoice,
            description: "Fundamentals - Recall & Core Concepts",
            questions: accountingBasicsLevel1Questions,
            difficulty: .beginner,
            estimatedTime: 10,
            category: "Accounting Basics",
            prerequisites: []
        ),
        // Accounting Basics - Level 2
        Lesson(
            title: "Accounting Basics - Level 2",
            xpReward: 75,
            type: .multipleChoice,
            description: "Intermediate Concepts",
            questions: accountingBasicsLevel2Questions,
            difficulty: .intermediate,
            estimatedTime: 12,
            category: "Accounting Basics",
            prerequisites: ["Accounting Basics - Level 1"]
        ),
        // Accounting Basics - Level 3
        Lesson(
            title: "Accounting Basics - Level 3",
            xpReward: 100,
            type: .multipleChoice,
            description: "Advanced Applications",
            questions: accountingBasicsLevel3Questions,
            difficulty: .advanced,
            estimatedTime: 15,
            category: "Accounting Basics",
            prerequisites: ["Accounting Basics - Level 2"]
        ),
        // Accounting Basics - Level 4
        Lesson(
            title: "Accounting Basics - Level 4",
            xpReward: 150,
            type: .multipleChoice,
            description: "Expert Level Mastery",
            questions: accountingBasicsLevel4Questions,
            difficulty: .expert,
            estimatedTime: 18,
            category: "Accounting Basics",
            prerequisites: ["Accounting Basics - Level 3"]
        ),
        // Enterprise Value/Valuation - Level 1
        Lesson(
            title: "Enterprise Value/Valuation - Level 1",
            xpReward: 50,
            type: .multipleChoice,
            description: "Fundamentals - EV vs Equity Value",
            questions: enterpriseValueLevel1Questions,
            difficulty: .beginner,
            estimatedTime: 10,
            category: "Valuation Techniques",
            prerequisites: []
        ),
        // Enterprise Value/Valuation - Level 2
        Lesson(
            title: "Enterprise Value/Valuation - Level 2",
            xpReward: 75,
            type: .multipleChoice,
            description: "Building the DCF - Free Cash Flow & WACC",
            questions: enterpriseValueLevel2Questions,
            difficulty: .intermediate,
            estimatedTime: 12,
            category: "Valuation Techniques",
            prerequisites: ["Enterprise Value/Valuation - Level 1"]
        ),
        // Enterprise Value/Valuation - Level 3
        Lesson(
            title: "Enterprise Value/Valuation - Level 3",
            xpReward: 100,
            type: .multipleChoice,
            description: "Terminal Value & Sensitivity Analysis",
            questions: enterpriseValueLevel3Questions,
            difficulty: .advanced,
            estimatedTime: 15,
            category: "Valuation Techniques",
            prerequisites: ["Enterprise Value/Valuation - Level 2"]
        ),
        // Enterprise Value/Valuation - Level 4
        Lesson(
            title: "Enterprise Value/Valuation - Level 4",
            xpReward: 150,
            type: .multipleChoice,
            description: "Expert-Level IB Integration",
            questions: enterpriseValueLevel4Questions,
            difficulty: .expert,
            estimatedTime: 18,
            category: "Valuation Techniques",
            prerequisites: ["Enterprise Value/Valuation - Level 3"]
        ),
        // DCF Fundamentals - Level 1
        Lesson(
            title: "DCF Fundamentals - Level 1",
            xpReward: 50,
            type: .multipleChoice,
            description: "DCF Overview & Components",
            questions: accountingBasicsLevel1Questions, // Placeholder
            difficulty: .beginner,
            estimatedTime: 10,
            category: "DCF Fundamentals",
            prerequisites: []
        ),
        // DCF Fundamentals - Level 2
        Lesson(
            title: "DCF Fundamentals - Level 2",
            xpReward: 75,
            type: .multipleChoice,
            description: "Projecting Cash Flows",
            questions: accountingBasicsLevel2Questions, // Placeholder
            difficulty: .intermediate,
            estimatedTime: 12,
            category: "DCF Fundamentals",
            prerequisites: ["DCF Fundamentals - Level 1"]
        ),
        // DCF Fundamentals - Level 3
        Lesson(
            title: "DCF Fundamentals - Level 3",
            xpReward: 100,
            type: .multipleChoice,
            description: "WACC & Terminal Value",
            questions: accountingBasicsLevel3Questions, // Placeholder
            difficulty: .advanced,
            estimatedTime: 15,
            category: "DCF Fundamentals",
            prerequisites: ["DCF Fundamentals - Level 2"]
        ),
        // DCF Fundamentals - Level 4
        Lesson(
            title: "DCF Fundamentals - Level 4",
            xpReward: 150,
            type: .multipleChoice,
            description: "Sensitivity Analysis & Output",
            questions: accountingBasicsLevel4Questions, // Placeholder
            difficulty: .expert,
            estimatedTime: 18,
            category: "DCF Fundamentals",
            prerequisites: ["DCF Fundamentals - Level 3"]
        ),
        // LBO Fundamentals - Level 1
        Lesson(
            title: "LBO Fundamentals - Level 1",
            xpReward: 50,
            type: .multipleChoice,
            description: "LBO Overview & Structure",
            questions: accountingBasicsLevel1Questions, // Placeholder
            difficulty: .beginner,
            estimatedTime: 10,
            category: "LBO Fundamentals",
            prerequisites: []
        ),
        // LBO Fundamentals - Level 2
        Lesson(
            title: "LBO Fundamentals - Level 2",
            xpReward: 75,
            type: .multipleChoice,
            description: "Sources & Uses of Funds",
            questions: accountingBasicsLevel2Questions, // Placeholder
            difficulty: .intermediate,
            estimatedTime: 12,
            category: "LBO Fundamentals",
            prerequisites: ["LBO Fundamentals - Level 1"]
        ),
        // LBO Fundamentals - Level 3
        Lesson(
            title: "LBO Fundamentals - Level 3",
            xpReward: 100,
            type: .multipleChoice,
            description: "Returns & IRR Analysis",
            questions: accountingBasicsLevel3Questions, // Placeholder
            difficulty: .advanced,
            estimatedTime: 15,
            category: "LBO Fundamentals",
            prerequisites: ["LBO Fundamentals - Level 2"]
        ),
        // LBO Fundamentals - Level 4
        Lesson(
            title: "LBO Fundamentals - Level 4",
            xpReward: 150,
            type: .multipleChoice,
            description: "Exit Strategies & Returns",
            questions: accountingBasicsLevel4Questions, // Placeholder
            difficulty: .expert,
            estimatedTime: 18,
            category: "LBO Fundamentals",
            prerequisites: ["LBO Fundamentals - Level 3"]
        ),
        // M&A Fundamentals - Level 1
        Lesson(
            title: "M&A Fundamentals - Level 1",
            xpReward: 50,
            type: .multipleChoice,
            description: "M&A Overview & Types",
            questions: accountingBasicsLevel1Questions, // Placeholder
            difficulty: .beginner,
            estimatedTime: 10,
            category: "M&A Fundamentals",
            prerequisites: []
        ),
        // M&A Fundamentals - Level 2
        Lesson(
            title: "M&A Fundamentals - Level 2",
            xpReward: 75,
            type: .multipleChoice,
            description: "Due Diligence Process",
            questions: accountingBasicsLevel2Questions, // Placeholder
            difficulty: .intermediate,
            estimatedTime: 12,
            category: "M&A Fundamentals",
            prerequisites: ["M&A Fundamentals - Level 1"]
        ),
        // M&A Fundamentals - Level 3
        Lesson(
            title: "M&A Fundamentals - Level 3",
            xpReward: 100,
            type: .multipleChoice,
            description: "Valuation & Synergies",
            questions: accountingBasicsLevel3Questions, // Placeholder
            difficulty: .advanced,
            estimatedTime: 15,
            category: "M&A Fundamentals",
            prerequisites: ["M&A Fundamentals - Level 2"]
        ),
        // M&A Fundamentals - Level 4
        Lesson(
            title: "M&A Fundamentals - Level 4",
            xpReward: 150,
            type: .multipleChoice,
            description: "Integration & Post-Merger",
            questions: accountingBasicsLevel4Questions, // Placeholder
            difficulty: .expert,
            estimatedTime: 18,
            category: "M&A Fundamentals",
            prerequisites: ["M&A Fundamentals - Level 3"]
        )
    ]
    
    static let achievements: [Achievement] = [
        // Quick Wins (3-7 days)
        Achievement(title: "First Deal", description: "Complete your first lesson", icon: "star.fill", xpReward: 50, rarity: .common, requirements: ["Complete 1 lesson"]),
        Achievement(title: "Early Bird", description: "Study 3 days in a row", icon: "sunrise.fill", xpReward: 100, rarity: .common, requirements: ["3-day streak"]),
        Achievement(title: "Quick Learner", description: "Complete 5 lessons", icon: "bolt.fill", xpReward: 150, rarity: .common, requirements: ["Complete 5 lessons"]),
        Achievement(title: "Rising Star", description: "Earn 500 XP", icon: "star.circle.fill", xpReward: 200, rarity: .common, requirements: ["Earn 500 XP"]),
        Achievement(title: "Power Hour", description: "Complete 3 lessons in one day", icon: "clock.fill", xpReward: 250, rarity: .rare, requirements: ["3 lessons in 1 day"]),
        Achievement(title: "Deal Starter", description: "Complete your first IB lesson", icon: "building.2.fill", xpReward: 200, rarity: .rare, requirements: ["Complete first IB lesson"]),
        
        // Medium-Term (1-2 weeks)
        Achievement(title: "Deal Flow", description: "Complete 15 lessons", icon: "doc.text.fill", xpReward: 400, rarity: .rare, requirements: ["Complete 15 lessons"]),
        Achievement(title: "Week Warrior", description: "Maintain a 7-day streak", icon: "flame.fill", xpReward: 500, rarity: .rare, requirements: ["7-day streak"]),
        Achievement(title: "Pitch Perfect", description: "Score 90%+ on 5 lessons", icon: "target", xpReward: 600, rarity: .rare, requirements: ["90%+ on 5 lessons"]),
        Achievement(title: "Knowledge Builder", description: "Earn 2,500 XP", icon: "brain.head.profile", xpReward: 700, rarity: .epic, requirements: ["Earn 2,500 XP"]),
        Achievement(title: "DCF Master", description: "Complete all DCF lessons", icon: "chart.line.uptrend.xyaxis", xpReward: 800, rarity: .epic, requirements: ["Complete DCF lessons"]),
        Achievement(title: "Valuation Ace", description: "Master all valuation lessons", icon: "chart.line.uptrend.xyaxis", xpReward: 900, rarity: .epic, requirements: ["Complete Valuation Techniques lessons"]),
        
        // Long-Term (1+ months)
        Achievement(title: "Investment Banker", description: "Complete 50 lessons", icon: "graduationcap.fill", xpReward: 1200, rarity: .epic, requirements: ["Complete 50 lessons"]),
        Achievement(title: "Marathon Runner", description: "Maintain a 30-day streak", icon: "calendar", xpReward: 1500, rarity: .legendary, requirements: ["30-day streak"]),
        Achievement(title: "Elite Performer", description: "Score 95%+ on 20 lessons", icon: "checkmark.seal.fill", xpReward: 1800, rarity: .legendary, requirements: ["95%+ on 20 lessons"]),
        Achievement(title: "XP Legend", description: "Earn 10,000 total XP", icon: "star.circle.fill", xpReward: 2000, rarity: .legendary, requirements: ["Earn 10,000 XP"]),
        Achievement(title: "Wall Street Ready", description: "Complete all M&A and LBO lessons", icon: "building.2.fill", xpReward: 2500, rarity: .legendary, requirements: ["Complete all M&A and LBO lessons"]),
        Achievement(title: "Perfect Record", description: "Get 100% on 15 lessons", icon: "checkmark.circle.fill", xpReward: 3000, rarity: .legendary, requirements: ["100% on 15 lessons"])
    ]
}

// MARK: - Modern Home Content

struct ModernHomeScrollContent: View {
    @EnvironmentObject var store: AppStore
    @Binding var pendingLesson: Lesson?
    @Binding var navigateToLesson: Bool
    @Binding var animateProgress: Bool
    @Binding var pulseAnimation: Bool
    @Binding var animateHeader: Bool
    let geometry: GeometryProxy
    @State private var appear = false
    
    var body: some View {
        LazyVStack(spacing: 24) {
            // Welcome Header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back!")
                            .font(.system(size: min(28, geometry.size.width * 0.07), weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Ready to continue your learning journey?")
                            .font(.system(size: min(16, geometry.size.width * 0.04)))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Profile Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: min(60, geometry.size.width * 0.15), height: min(60, geometry.size.width * 0.15))
                        
                        Text("U")
                            .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Progress Overview
            GlassmorphismCard(cornerRadius: 24, shadowRadius: 15) {
                VStack(spacing: 20) {
                    HStack {
                        Text("Your Progress")
                            .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(store.xp) XP")
                            .font(.system(size: min(18, geometry.size.width * 0.045), weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Level \(store.level)")
                                .font(.system(size: min(14, geometry.size.width * 0.035), weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(store.currentLevelProgress) / \(store.xpToNextLevel)")
                                .font(.system(size: min(12, geometry.size.width * 0.03), weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: Double(store.currentLevelProgress), total: Double(store.xpToNextLevel))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                }
                .padding(min(20, geometry.size.width * 0.05))
            }
            .padding(.horizontal, 20)
            
            // Quick Actions
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Actions")
                    .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 16) {
                    ModernQuickActionCard(
                        title: store.lastLessonID == nil && store.completedLessonIDs.isEmpty ? "Start Learning" : "Continue Learning",
                        icon: "play.circle.fill",
                        color: .blue,
                        geometry: geometry
                    ) {
                        if let nextLesson = store.getNextLesson() {
                            pendingLesson = nextLesson
                            navigateToLesson = true
                        }
                    }
                    
                    ModernQuickActionCard(
                        title: "Practice Mode",
                        icon: "brain.head.profile",
                        color: .purple,
                        geometry: geometry
                    ) {
                        // Navigate to practice mode
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Recent Achievements
            if !ContentProvider.achievements.filter({ store.achievements.contains($0.id) }).isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Achievements")
                        .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(ContentProvider.achievements.filter { store.achievements.contains($0.id) }.prefix(5)) { achievement in
                                ModernAchievementCard(achievement: achievement, geometry: geometry)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            
            // Daily Streak
            GlassmorphismCard(cornerRadius: 24, shadowRadius: 15) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: min(50, geometry.size.width * 0.12), height: min(50, geometry.size.width * 0.12))
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(store.streakDays) Day Streak")
                            .font(.system(size: min(18, geometry.size.width * 0.045), weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Keep the momentum going!")
                            .font(.system(size: min(14, geometry.size.width * 0.035)))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(min(20, geometry.size.width * 0.05))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: appear)
        .onAppear {
            appear = true
        }
    }
}

struct ModernQuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let geometry: GeometryProxy
    let action: () -> Void
    @State private var appear = false
    
    var body: some View {
        Button(action: action) {
            GlassmorphismCard(cornerRadius: 20, shadowRadius: 12) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.8), color],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: min(50, geometry.size.width * 0.12), height: min(50, geometry.size.width * 0.12))
                        
                        Image(systemName: icon)
                            .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(title)
                        .font(.system(size: min(14, geometry.size.width * 0.035), weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(min(16, geometry.size.width * 0.04))
            }
        }
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3)), value: appear)
        .onAppear {
            appear = true
        }
    }
}

struct ModernAchievementCard: View {
    let achievement: Achievement
    let geometry: GeometryProxy
    @State private var appear = false
    
    var body: some View {
        GlassmorphismCard(cornerRadius: 16, shadowRadius: 8) {
            VStack(spacing: 8) {
                Image(systemName: achievement.icon)
                    .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                    .foregroundColor(achievement.rarity.color)
                
                Text(achievement.title)
                    .font(.system(size: min(12, geometry.size.width * 0.03), weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(min(12, geometry.size.width * 0.03))
            .frame(width: min(100, geometry.size.width * 0.25))
        }
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.4)), value: appear)
        .onAppear {
            appear = true
        }
    }
}

// MARK: - Views

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @State private var selection: Int = 0
    @State private var showOnboarding = false
    @State private var isInitialized = false

    var body: some View {
        GeometryReader { geometry in
            if !isInitialized {
                // Show loading screen while checking onboarding status
                ZStack {
                    Color.white
                        .ignoresSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if store.xp == 0 && store.completedLessonIDs.isEmpty {
                            showOnboarding = true
                        }
                        isInitialized = true
                    }
                }
            } else if showOnboarding {
                OnboardingView(onComplete: {
                    showOnboarding = false
                })
            } else {
                TabView(selection: $selection) {
                    HomeView(selection: $selection)
                        .tabItem {
                            Label("Home", systemImage: selection == 0 ? "house.fill" : "house")
                        }
                        .tag(0)
                    
                    QuestView()
                        .tabItem {
                            Label("Quest", systemImage: selection == 1 ? "map.fill" : "map")
                        }
                        .tag(1)
                    
                    AchievementsView()
                        .tabItem {
                            Label("Achievements", systemImage: selection == 2 ? "trophy.fill" : "trophy")
                        }
                        .tag(2)
                    
                    LeaderboardView()
                        .tabItem {
                            Label("Pro", systemImage: selection == 3 ? "crown.fill" : "crown")
                        }
                        .tag(3)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: selection == 4 ? "person.crop.circle.fill" : "person.crop.circle")
                        }
                        .tag(4)
                }
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                .accentColor(Brand.primaryBlue)
                .preferredColorScheme(.light)
            }
        }
    }
}


// MARK: - Fintech Home (New)

private struct FintechHomeScrollContent: View {
    @EnvironmentObject var store: AppStore
    @Binding var pendingLesson: Lesson?
    @Binding var navigateToLesson: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("Welcome back")
                    .font(Brand.bodyFont)
                    .foregroundColor(Brand.textSecondary)
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(store.username)
                        .font(Brand.titleFont)
                        .foregroundColor(Brand.textPrimary)
                    Spacer()
                    FintechLevelPill(level: store.level)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Progress + CTA
            FintechProgressCard(xp: store.xp, level: store.level, streakDays: store.streakDays) {
                #if os(iOS)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                #endif
                if let next = store.getNextLesson() ?? ContentProvider.sampleLessons.first {
                    pendingLesson = next
                    DispatchQueue.main.async { navigateToLesson = true }
                }
            }
            .padding(.horizontal, 20)
            
            // Quick actions
            FintechQuickActionsGrid()
                .padding(.horizontal, 20)
            
            // Streak card
            FintechStreakCard(streakDays: store.streakDays)
                .padding(.horizontal, 20)
                .padding(.bottom, 80)
        }
    }
}

private struct FintechLevelPill: View {
    let level: Int
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "chart.bar.doc.horizontal.fill")
                .font(.caption2.weight(.bold))
            Text("Level \(level)")
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(colors: [Brand.primaryBlue.opacity(0.6), Brand.lavender.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct FintechProgressCard: View {
    let xp: Int
    let level: Int
    let streakDays: Int
    let onPrimaryCTA: () -> Void
    
    private var progressToNext: Double {
        let currentLevelXP = AppStore.xpForLevel(level)
        let nextLevelXP = AppStore.xpForLevel(level + 1)
        let xpInCurrentLevel = xp - currentLevelXP
        let xpNeededForNextLevel = nextLevelXP - currentLevelXP
        return min(1.0, Double(xpInCurrentLevel) / Double(xpNeededForNextLevel))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 8)
                        .frame(width: 76, height: 76)
                    Circle()
                        .trim(from: 0, to: progressToNext)
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [Brand.mint, Brand.primaryBlue, Brand.lavender]), center: .center),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 76, height: 76)
                        .animation(.easeInOut(duration: 1.0), value: progressToNext)
                    VStack(spacing: 2) {
                        Text("\(Int(progressToNext * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                        Text("to next")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Level \(level)")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                    Text("\(AppStore.xpForLevel(level + 1) - xp) XP to next level")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    HStack(spacing: 12) {
                        Label("\(xp) XP", systemImage: "star.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.yellow)
                        Label("\(streakDays) day streak", systemImage: "flame.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.orange)
                    }
                }
                Spacer()
            }
            
            // Linear progress
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: [Brand.mint, Brand.primaryBlue], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: max(10, CGFloat(progressToNext) * UIScreen.main.bounds.width * 0.68), height: 10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            
            Button(action: onPrimaryCTA) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.headline.weight(.bold))
                    Text("Continue Learning")
                        .font(.headline.weight(.bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [Color.mint, Color.cyan], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .background(.ultraThinMaterial.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 8)
    }
}

private struct FintechQuickActionsGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickAction(icon: "bolt.fill", title: "Daily Goal", gradient: [Brand.softOrange, Brand.warmCoral])
                quickAction(icon: "chart.bar.fill", title: "Review Progress", gradient: [Brand.primaryBlue, Brand.lavender])
                quickAction(icon: "rectangle.and.pencil.and.ellipsis", title: "Quiz Me", gradient: [Brand.mint, Brand.teal])
                quickAction(icon: "trophy.fill", title: "Leaderboard", gradient: [Brand.lavender, Brand.lightPink])
            }
        }
    }
    private func quickAction(icon: String, title: String, gradient: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

private struct FintechStreakCard: View {
    let streakDays: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Streak")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            }
            HStack(spacing: 12) {
                Text("\(streakDays)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                Text("days")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 8)
    }
}


struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @Binding var selection: Int
    @State private var animateProgress = false
    @State private var showCelebration = false
    @State private var animateHeader = false
    @State private var pulseAnimation = false
    @State private var floatingOffset: CGFloat = 0
    @State private var navigateToLesson = false
    @State private var pendingLesson: Lesson? = nil

    var body: some View {
        GeometryReader { geometry in
        NavigationStack {
            // Primary content (light glassmorphism design)
            ScrollView {
                HomeScrollContentNew(
                    store: store,
                    pendingLesson: $pendingLesson,
                    navigateToLesson: $navigateToLesson,
                    animateProgress: $animateProgress,
                    pulseAnimation: $pulseAnimation,
                    animateHeader: $animateHeader,
                    selection: $selection
                )
            }
            .scrollIndicators(.hidden)
            // Hidden navigation link to push into next lesson
            .background(
                Group {
                    if let lesson = pendingLesson {
                        NavigationLink(
                            destination: LessonPlayView(lesson: lesson),
                            isActive: $navigateToLesson
                        ) {
                            EmptyView()
                        }
                    }
                }
            )
            .toolbar(.hidden, for: .navigationBar)
        }
        }
        .overlay(
            Group {
                if showCelebration {
                    CelebrationView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateHeader = true
            }
        }
    }
}

private struct HomeScrollContent: View {
    @ObservedObject var store: AppStore
    @Binding var pendingLesson: Lesson?
    @Binding var navigateToLesson: Bool
    @Binding var showIslandPicker: Bool
    @Binding var animateProgress: Bool
    @Binding var pulseAnimation: Bool
    @Binding var animateHeader: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Stunning hero section with softened, subtle gradient background
            VStack(spacing: 0) {
                // Gradient background overlay
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.98, blue: 1.0),
                        Color(red: 0.96, green: 0.98, blue: 0.99),
                        Color(red: 0.95, green: 0.97, blue: 0.99)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 320)
                .overlay(
                    // Subtle pattern overlay
                    RadialGradient(
                        colors: [
                            Brand.primaryBlue.opacity(0.015),
                            Brand.lavender.opacity(0.012),
                            .clear
                        ],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: 260
                    )
                )
                .overlay(
                    VStack(spacing: 0) {
                        // Enhanced header with better spacing
                HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back,")
                            .font(Brand.bodyFont)
                            .foregroundColor(Brand.textSecondary)
                        
                        Text(store.username)
                            .font(Brand.titleFont)
                            .foregroundColor(Brand.textPrimary)
                            .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            .allowsTightening(true)
                    }
                    .offset(x: animateHeader ? 0 : -30)
                    .opacity(animateHeader ? 1 : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Removed bright level badge for a cleaner, calmer header
                    Spacer(minLength: 0)
                }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // Stunning progress section with professional design
                        VStack(spacing: 32) {
                    ZStack {
                                // Elegant background glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                                Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.08),
                                                Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.04),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                            endRadius: 120
                                        )
                                    )
                                    .frame(width: 240, height: 240)
                                    .blur(radius: 30)
                                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                                
                                // Main progress ring container
                        ZStack {
                                    // Background circle with subtle gradient
                            Circle()
                                .stroke(
                                    LinearGradient(
                                                colors: [
                                                    Color(red: 0.9, green: 0.92, blue: 0.95),
                                                    Color(red: 0.85, green: 0.88, blue: 0.92)
                                                ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                            lineWidth: 8
                                )
                                        .frame(width: 160, height: 160)
                            
                                    // Progress circle with beautiful gradient
                            Circle()
                                .trim(from: 0, to: min(1.0, Double(store.xp - AppStore.xpForLevel(store.level)) / Double(AppStore.xpForLevel(store.level + 1) - AppStore.xpForLevel(store.level))))
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                                    Color(red: 0.2, green: 0.6, blue: 1.0),
                                                    Color(red: 0.4, green: 0.3, blue: 0.9),
                                                    Color(red: 0.6, green: 0.2, blue: 0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                        .frame(width: 160, height: 160)
                                .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut(duration: 1.8), value: store.xp)
                            
                                    // Center content with professional styling
                                    VStack(spacing: 6) {
                                Text("\(Int(min(1.0, Double(store.xp - AppStore.xpForLevel(store.level)) / Double(AppStore.xpForLevel(store.level + 1) - AppStore.xpForLevel(store.level))) * 100))%")
                                            .font(Brand.largeTitleFont)
                                            .foregroundColor(Brand.textPrimary)
                                        
                                        Text("TO NEXT LEVEL")
                                            .font(Brand.smallFont)
                                            .foregroundColor(Brand.textSecondary)
                                            .tracking(1.2)
                                    }
                                }
                                .scaleEffect(animateProgress ? 1.01 : 1.0)
                                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateProgress)
                    }
                    .onAppear {
                        animateProgress = true
                        pulseAnimation = true
                    }
                }
                .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
                )
            }
            
            // Stunning Start Learning CTA with professional design
            VStack(spacing: 16) {
                Button(action: {
                    if let last = store.lastLessonID, ContentProvider.sampleLessons.contains(where: { $0.id == last }), let next = store.getNextLesson() {
                        pendingLesson = next
                        navigateToLesson = true
                    } else if !store.completedLessonIDs.isEmpty, let next = store.getNextLesson() {
                        pendingLesson = next
                        navigateToLesson = true
                    } else {
                        showIslandPicker = true
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Brand.pastelGradient)
                            .frame(height: 44)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                        
                        // Button content
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.primary.opacity(0.85))
                            
                            Text(store.hasAttemptedQuestion ? "Continue Learning" : "Start Learning")
                                .font(Brand.buttonFont)
                                .foregroundColor(Brand.textPrimary)
                        }
                    }
                }
                .buttonStyle(ModernGetStartedStyle())
                .frame(maxWidth: 300)
                .padding(.top, 4)
                
                Text("Pick a module to begin • e.g. DCF Fundamentals")
                    .font(Brand.descriptionFont)
                    .foregroundColor(Brand.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            // Professional stats section with elegant cards
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    // Total XP Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.1),
                                            Color(red: 0.4, green: 0.3, blue: 0.9).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(store.xp)")
                                .font(Brand.largeTitleFont)
                                .foregroundColor(Brand.textPrimary)
                            
                            Text("TOTAL XP")
                                .font(Brand.smallFont)
                                .foregroundColor(Brand.textSecondary)
                                .tracking(0.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
                    // Level Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.1),
                                            Color(red: 0.1, green: 0.6, blue: 0.3).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(store.level)")
                                .font(Brand.largeTitleFont)
                                .foregroundColor(Brand.textPrimary)
                            
                            Text("LEVEL")
                                .font(Brand.smallFont)
                                .foregroundColor(Brand.textSecondary)
                                .tracking(0.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
                
                HStack(spacing: 16) {
                    // Streak Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.5, blue: 0.2).opacity(0.1),
                                            Color(red: 0.9, green: 0.3, blue: 0.1).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "flame.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.2))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(store.streakDays)")
                                .font(Brand.largeTitleFont)
                                .foregroundColor(Brand.textPrimary)
                            
                            Text("STREAK")
                                .font(Brand.smallFont)
                                .foregroundColor(Brand.textSecondary)
                                .tracking(0.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
                    // Perfect Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.8, green: 0.2, blue: 0.8).opacity(0.1),
                                            Color(red: 0.6, green: 0.1, blue: 0.6).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.8))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(store.perfectLessons)")
                                .font(Brand.largeTitleFont)
                                .foregroundColor(Brand.textPrimary)
                            
                            Text("PERFECT")
                                .font(Brand.smallFont)
                                .foregroundColor(Brand.textSecondary)
                                .tracking(0.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)

            // Continue Learning Button
            if let nextLesson = store.getNextLesson() {
                ContinueLearningCard(lesson: nextLesson)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
            
            // Enhanced action cards
            VStack(spacing: 20) {
                QuickStartCard()
                DailyGoalCard()
                DailyQuestBanner()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)

            // Recent achievements
            if !store.achievements.isEmpty {
                RecentAchievementsCard()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }

            // Study streak visualization
            StreakVisualizationCard()
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
        }
    }
}

private struct HomeBackground: View {
    @State private var animate: Bool = false
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color(red: 0.97, green: 1.00, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(LinearGradient(colors: [Color.mint.opacity(0.10), Color.cyan.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 80)
                .frame(width: 520, height: 520)
                .offset(x: animate ? -140 : -40, y: animate ? -160 : -60)

            Circle()
                .fill(LinearGradient(colors: [Brand.primaryBlue.opacity(0.08), Brand.lavender.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 100)
                .frame(width: 620, height: 620)
                .offset(x: animate ? 140 : 60, y: animate ? 220 : 120)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

private struct FloatingElementsView: View {
    @Binding var floatingOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                [Brand.primaryBlue, Brand.lavender, Brand.teal, Brand.mint][index].opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .offset(
                        x: sin(floatingOffset + Double(index) * 0.8) * 60,
                        y: cos(floatingOffset + Double(index) * 0.6) * 40
                    )
                    .blur(radius: 15)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                floatingOffset = .pi * 2
            }
        }
    }
}

