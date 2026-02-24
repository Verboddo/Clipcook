import XCTest
@testable import ClipCook

final class RecipeCaptionParserTests: XCTestCase {
    let parser = RecipeCaptionParser()

    func testDutchRecipeWithBullets() {
        let caption = """
        High protein pizza wrap 🍕

        Ingrediënten:
        - 1 tortilla wrap
        - 50g mozzarella
        - 100g kipfilet
        - 2 el tomatensaus
        - Oregano naar smaak

        Bereiding:
        1. Verwarm de oven voor op 200°C
        2. Beleg de wrap met tomatensaus
        3. Voeg de kip en mozzarella toe
        4. Bak 10-12 minuten in de oven

        #highprotein #pizza #fitfood
        """

        let result = parser.parse(caption)

        XCTAssertEqual(result.ingredients.count, 5, "Should find 5 ingredients")
        XCTAssertEqual(result.steps.count, 4, "Should find 4 steps")
        XCTAssertTrue(result.ingredients[0].name.contains("tortilla") || result.ingredients[0].name.contains("wrap"))
        XCTAssertTrue(result.steps[0].text.contains("oven"))
    }

    func testEnglishRecipeWithNumbers() {
        let caption = """
        Easy overnight oats 🥣

        Ingredients:
        - 50g oats
        - 150ml almond milk
        - 1 tbsp chia seeds
        - 1 tsp honey
        - Fresh berries

        Steps:
        1. Combine oats and milk in a jar
        2. Add chia seeds and honey
        3. Refrigerate overnight
        4. Top with berries and serve

        #mealprep #healthybreakfast
        """

        let result = parser.parse(caption)

        XCTAssertEqual(result.ingredients.count, 5)
        XCTAssertEqual(result.steps.count, 4)
        XCTAssertEqual(result.ingredients[0].amount, "50 g")
        XCTAssertTrue(result.ingredients[0].name.lowercased().contains("oats"))
    }

    func testRecipeWithEmojiHeaders() {
        let caption = """
        Beste smoothie bowl ooit

        🛒 Nodig:
        - 1 banaan (bevroren)
        - 100g blauwe bessen
        - 150ml kokosmelk
        - 1 el pindakaas

        📝 Zo maak je het:
        1. Blend de banaan met blauwe bessen en kokosmelk
        2. Giet in een kom
        3. Top met pindakaas en extra fruit
        """

        let result = parser.parse(caption)

        XCTAssertEqual(result.ingredients.count, 4)
        XCTAssertEqual(result.steps.count, 3)
    }

    func testRecipeWithoutExplicitHeaders() {
        let caption = """
        Quick protein pancakes

        - 2 eieren
        - 1 banaan
        - 30g eiwitpoeder
        - Snufje kaneel

        1. Mix alles in een blender
        2. Bak in een pan op middelhoog vuur
        3. Serveer met fruit
        """

        let result = parser.parse(caption)

        XCTAssertEqual(result.ingredients.count, 4)
        XCTAssertEqual(result.steps.count, 3)
    }

    func testHashtagStripping() {
        let caption = """
        Test recipe

        Ingredients:
        - Salt

        Steps:
        1. Cook it

        #cooking #recipe #food #healthy #fitfam
        """

        let result = parser.parse(caption)

        XCTAssertEqual(result.ingredients.count, 1)
        XCTAssertEqual(result.steps.count, 1)
        XCTAssertFalse(result.steps[0].text.contains("#"))
    }

    func testTimingExtraction() {
        let caption = """
        Quick pasta

        Prep time: 5 min
        Cook time: 15 min
        2 porties

        Ingrediënten:
        - 200g pasta
        - 1 blik tomatensaus

        Bereiding:
        1. Kook de pasta
        2. Verwarm de saus
        """

        let result = parser.parse(caption)

        XCTAssertEqual(result.prepTime, "5 min")
        XCTAssertEqual(result.cookTime, "15 min")
        XCTAssertEqual(result.servings, 2)
    }

    func testEmptyCaption() {
        let result = parser.parse("")
        XCTAssertTrue(result.ingredients.isEmpty)
        XCTAssertTrue(result.steps.isEmpty)
        XCTAssertFalse(result.hasContent)
    }

    func testCaptionWithOnlyText() {
        let caption = "Just a beautiful day cooking with friends! Love this recipe so much 💕"
        let result = parser.parse(caption)
        XCTAssertTrue(result.ingredients.isEmpty)
        XCTAssertTrue(result.steps.isEmpty)
    }
}
