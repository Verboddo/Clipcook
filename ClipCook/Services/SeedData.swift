import Foundation

enum SeedData {
    static func sampleRecipes(userId: String) -> [Recipe] {
        [
            Recipe(
                userId: userId,
                title: "Creamy Tuscan Chicken Pasta",
                thumbnail: "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400",
                sourceUrl: "https://www.instagram.com/p/example1/",
                sourcePlatform: .instagram,
                prepTime: "10 min",
                cookTime: "25 min",
                servings: 4,
                category: .dinner,
                ingredients: [
                    Ingredient(name: "Chicken breast", amount: "500g"),
                    Ingredient(name: "Penne pasta", amount: "300g"),
                    Ingredient(name: "Sun-dried tomatoes", amount: "100g"),
                    Ingredient(name: "Spinach", amount: "2 cups"),
                    Ingredient(name: "Heavy cream", amount: "200ml"),
                    Ingredient(name: "Garlic cloves", amount: "3"),
                    Ingredient(name: "Parmesan cheese", amount: "50g"),
                ],
                steps: [
                    Step(order: 1, text: "Cook pasta according to package directions. Drain and set aside."),
                    Step(order: 2, text: "Season chicken breast with salt and pepper. Cook in olive oil until golden, about 6 min per side."),
                    Step(order: 3, text: "In the same pan, sauté garlic for 30 seconds. Add sun-dried tomatoes and spinach."),
                    Step(order: 4, text: "Pour in heavy cream and bring to a simmer. Add parmesan and stir until melted."),
                    Step(order: 5, text: "Slice chicken, toss with pasta and sauce. Serve with extra parmesan on top."),
                ],
                nutrition: Nutrition(calories: 580, protein: 42, carbs: 55, fats: 22)
            ),
            Recipe(
                userId: userId,
                title: "Avocado Toast with Poached Eggs",
                thumbnail: "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400",
                prepTime: "5 min",
                cookTime: "10 min",
                servings: 2,
                category: .breakfast,
                ingredients: [
                    Ingredient(name: "Sourdough bread", amount: "2 slices"),
                    Ingredient(name: "Avocado", amount: "1"),
                    Ingredient(name: "Eggs", amount: "2"),
                    Ingredient(name: "Cherry tomatoes", amount: "6"),
                    Ingredient(name: "Red pepper flakes", amount: "1 tsp"),
                ],
                steps: [
                    Step(order: 1, text: "Toast sourdough slices until golden and crispy."),
                    Step(order: 2, text: "Mash avocado with salt, pepper, and lime juice."),
                    Step(order: 3, text: "Poach eggs in simmering water with a splash of vinegar for 3 minutes."),
                    Step(order: 4, text: "Spread avocado on toast, top with poached egg and halved tomatoes."),
                ],
                nutrition: Nutrition(calories: 320, protein: 14, carbs: 28, fats: 18)
            ),
            Recipe(
                userId: userId,
                title: "Mango Smoothie Bowl",
                thumbnail: "https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400",
                prepTime: "5 min",
                cookTime: "5 min",
                servings: 1,
                category: .breakfast,
                ingredients: [
                    Ingredient(name: "Frozen mango", amount: "1 cup"),
                    Ingredient(name: "Banana", amount: "1"),
                    Ingredient(name: "Greek yogurt", amount: "100g"),
                    Ingredient(name: "Granola", amount: "30g"),
                    Ingredient(name: "Chia seeds", amount: "1 tbsp"),
                ],
                steps: [
                    Step(order: 1, text: "Blend frozen mango, banana, and yogurt until thick and smooth."),
                    Step(order: 2, text: "Pour into a bowl and top with granola, chia seeds, and fresh fruit."),
                ],
                nutrition: Nutrition(calories: 280, protein: 12, carbs: 48, fats: 6)
            ),
            Recipe(
                userId: userId,
                title: "Korean Beef Bibimbap",
                thumbnail: "https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=400",
                prepTime: "15 min",
                cookTime: "20 min",
                servings: 2,
                category: .dinner,
                ingredients: [
                    Ingredient(name: "Ground beef", amount: "300g"),
                    Ingredient(name: "Rice", amount: "2 cups"),
                    Ingredient(name: "Carrots", amount: "1"),
                    Ingredient(name: "Spinach", amount: "100g"),
                    Ingredient(name: "Gochujang paste", amount: "2 tbsp"),
                    Ingredient(name: "Sesame oil", amount: "1 tbsp"),
                    Ingredient(name: "Eggs", amount: "2"),
                ],
                steps: [
                    Step(order: 1, text: "Cook rice according to package directions."),
                    Step(order: 2, text: "Sauté ground beef with soy sauce and sesame oil."),
                    Step(order: 3, text: "Julienne and stir-fry carrots. Blanch spinach."),
                    Step(order: 4, text: "Fry eggs sunny-side up."),
                    Step(order: 5, text: "Assemble bowls: rice, beef, vegetables, egg, and gochujang."),
                ],
                nutrition: Nutrition(calories: 520, protein: 35, carbs: 60, fats: 16)
            ),
            Recipe(
                userId: userId,
                title: "Classic Margherita Pizza",
                thumbnail: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400",
                prepTime: "20 min",
                cookTime: "12 min",
                servings: 2,
                category: .dinner,
                ingredients: [
                    Ingredient(name: "Pizza dough", amount: "250g"),
                    Ingredient(name: "San Marzano tomatoes", amount: "200g"),
                    Ingredient(name: "Fresh mozzarella", amount: "150g"),
                    Ingredient(name: "Fresh basil", amount: "6 leaves"),
                    Ingredient(name: "Olive oil", amount: "1 tbsp"),
                ],
                steps: [
                    Step(order: 1, text: "Preheat oven to 250°C (480°F) with a pizza stone if available."),
                    Step(order: 2, text: "Stretch dough into a 12-inch circle on a floured surface."),
                    Step(order: 3, text: "Crush tomatoes and spread over the dough, leaving a 1-inch border."),
                    Step(order: 4, text: "Tear mozzarella and distribute evenly. Drizzle with olive oil."),
                    Step(order: 5, text: "Bake for 10-12 minutes until crust is golden. Add fresh basil before serving."),
                ],
                nutrition: Nutrition(calories: 450, protein: 20, carbs: 52, fats: 18)
            ),
            Recipe(
                userId: userId,
                title: "Berry Overnight Oats",
                thumbnail: "https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=400",
                prepTime: "10 min",
                cookTime: "0 min",
                servings: 1,
                category: .breakfast,
                ingredients: [
                    Ingredient(name: "Rolled oats", amount: "50g"),
                    Ingredient(name: "Milk", amount: "150ml"),
                    Ingredient(name: "Greek yogurt", amount: "50g"),
                    Ingredient(name: "Mixed berries", amount: "100g"),
                    Ingredient(name: "Honey", amount: "1 tbsp"),
                    Ingredient(name: "Chia seeds", amount: "1 tsp"),
                ],
                steps: [
                    Step(order: 1, text: "Combine oats, milk, yogurt, honey, and chia seeds in a jar."),
                    Step(order: 2, text: "Stir well, cover, and refrigerate overnight (at least 6 hours)."),
                    Step(order: 3, text: "Top with fresh berries before serving. Enjoy cold."),
                ],
                nutrition: Nutrition(calories: 310, protein: 9, carbs: 52, fats: 8)
            ),
            Recipe(
                userId: userId,
                title: "Thai Green Curry",
                thumbnail: "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400",
                prepTime: "10 min",
                cookTime: "20 min",
                servings: 3,
                category: .dinner,
                ingredients: [
                    Ingredient(name: "Chicken thigh", amount: "400g"),
                    Ingredient(name: "Green curry paste", amount: "3 tbsp"),
                    Ingredient(name: "Coconut milk", amount: "400ml"),
                    Ingredient(name: "Thai basil", amount: "1 bunch"),
                    Ingredient(name: "Bamboo shoots", amount: "100g"),
                    Ingredient(name: "Jasmine rice", amount: "2 cups"),
                ],
                steps: [
                    Step(order: 1, text: "Fry green curry paste in a hot wok for 1 minute until fragrant."),
                    Step(order: 2, text: "Add chicken pieces and cook for 3 minutes."),
                    Step(order: 3, text: "Pour in coconut milk, add bamboo shoots, and simmer for 15 minutes."),
                    Step(order: 4, text: "Stir in Thai basil and serve over jasmine rice."),
                ],
                nutrition: Nutrition(calories: 490, protein: 30, carbs: 42, fats: 24)
            ),
            Recipe(
                userId: userId,
                title: "Mediterranean Chickpea Salad",
                thumbnail: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400",
                prepTime: "15 min",
                cookTime: "0 min",
                servings: 2,
                category: .lunch,
                ingredients: [
                    Ingredient(name: "Chickpeas (canned)", amount: "400g"),
                    Ingredient(name: "Cherry tomatoes", amount: "150g"),
                    Ingredient(name: "Cucumber", amount: "1"),
                    Ingredient(name: "Red onion", amount: "½"),
                    Ingredient(name: "Feta cheese", amount: "80g"),
                    Ingredient(name: "Olive oil", amount: "2 tbsp"),
                    Ingredient(name: "Lemon juice", amount: "2 tbsp"),
                ],
                steps: [
                    Step(order: 1, text: "Drain and rinse chickpeas. Halve tomatoes, dice cucumber and red onion."),
                    Step(order: 2, text: "Combine all vegetables and chickpeas in a large bowl."),
                    Step(order: 3, text: "Whisk olive oil, lemon juice, salt, and pepper for the dressing."),
                    Step(order: 4, text: "Toss salad with dressing, crumble feta on top, and serve."),
                ],
                nutrition: Nutrition(calories: 380, protein: 18, carbs: 40, fats: 16)
            ),
        ]
    }
}
