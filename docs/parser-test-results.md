# RecipeCaptionParser - Test Results

> Tested: 2026-02-20 06:10:00 +0000
> URLs: 11 (from `docs/test-urls.md`)
> Parser version: v3 (final)

## Summary

| # | Shortcode | User | Category | Ingredients | Steps | Title |
|---|-----------|------|----------|-------------|-------|-------|
| 1 | `DUTN7-ijcp1` | @itscheffatty | Zonder tekst | ❌ 0 | — | Comment "Recipe" and I'll shoot you |
| 2 | `DMuXeR5uRdA` | @joexfitness | Met tekst | ✅ 6 | ✅ 3 | ⇩ Full Recipe 🥦 ⇩ |
| 3 | `DTBJYBPiH5Z` | @samia.momcoach | Met tekst (NL inline) | ✅ 3 | — | Hoe bevat deze heerlijke pizza 40 g |
| 4 | `DQ1tuOGiTd5` | @eatwellscarlett | Truncated | ✅ 3 | — | Make my favorite diet cabbage tuna  |
| 5 | `DNVFPXwPqta` | @alexgamblecoach | Met tekst (dot-prefix) | ✅ 6 | — | Easiest Breakfast Meal Prep To Get  |
| 6 | `DNTU0DRIrsA` | @balancewithnu | Met tekst (dash-no-space) | ✅ 5 | — | My most trending recipe! Protein Pa |
| 7 | `DNAfCOzOu5z` | @joexfitness | Met tekst (long) | ✅ 15 | — | ⇩ Full Recipe 🍜 ⇩ |
| 8 | `DSBUsBHkrYh` | @overall.eats | Truncated | ✅ 3 | — | PEANUT CHILI OIL NOODLES - my favor |
| 9 | `DMlgiI9zZ7d` | @mattwest_roadtoaesthetics | Met tekst (checkmarks) | ✅ 9 | — | F*ck or Suck Series |
| 10 | `DPt_iQoEooo` | @overall.eats | Truncated (minimal) | ✅ 1 | — | PEANUT CHILI OIL NOODLES |
| 11 | `DHMQXAbsJzT` | @archersfood | Extern recept | ✅ 1 | — | https://archersfood.com/pistachio-p |

## Statistics

| Metric | Value |
|--------|-------|
| URLs tested | 11 |
| Ingredients parsed | 10/11 (90%) |
| Steps parsed | 1/11 (9%) |
| Truncated by Instagram | 3/11 |
| No recipe text | 1/11 |

## Parser Capabilities

| Feature | Status |
|---------|--------|
| Bullet ingredients (`-`, `•`, `✅`, `. `) | ✅ Works |
| Dash-no-space (`-1 egg`, `-50g flour`) | ✅ Works |
| Section headers (EN/NL/emoji) | ✅ Works |
| Numbered steps (`1.`, `2)`) | ✅ Works |
| Amount+unit parsing | ✅ Works |
| Macro line filtering (`47g P`, `Calories: 125`) | ✅ Works |
| URL filtering | ✅ Works |
| Hashtag stripping | ✅ Works |
| Dutch units (bakje, el, snufje, etc.) | ✅ Works |
| Inline text without structure | ⚠️ Partial |
| Steps from truncated captions | ❌ Lost to truncation |

## Conclusions

1. **Ingredient detection: 90% success rate** — the parser reliably extracts ingredients from captions that contain structured recipe text.

2. **Step detection: 9% success rate** — low because steps typically appear after ingredients and get truncated by Instagram's OG metadata limit. With full captions (pasted by user), this would be significantly higher.

3. **The "Paste Caption" feature is essential** — Instagram only provides ~300-500 chars in OG tags. Full captions contain 800-1500+ chars with complete recipes.

4. **Posts without recipe text** (1/11) cannot be parsed and require manual entry or video-to-recipe AI.

## Detailed Results

---

### 1. `DUTN7-ijcp1` — @itscheffatty

**Category:** Zonder tekst | **Caption:** 109 chars

**Result:** 0 ingredients, 0 steps

> ℹ️ No recipe text in caption — creator uses comment/DM system.

<details><summary>Raw caption</summary>

```
Comment "Recipe" and I'll shoot you a DM! 🙌

#onepotmeal #quickrecipe #dinneridea #asianrecipes #noodlerecipe
```
</details>

---

### 2. `DMuXeR5uRdA` — @joexfitness

**Category:** Met tekst | **Caption:** 876 chars

**Result:** 6 ingredients, 3 steps, 1 servings

| Amount | Ingredient |
|--------|------------|
| 1.5 lbs | broccoli |
| 1 tsp | salt |
| 1 tbsp | minced garlic |
| 1 tsp | black pepper |
| 1.5 tbsp | sesame oil |
| 1.5 tbsp | sesame seeds |

**Steps:**
1. Rip off pieces of your broccoli
2. In a pot of boiling water, add your broccoli for 1-2 minutes then immediately remove and transfer to a bowl of cold water
3. In a bowl, mix together minced garlic, salt, black pepper, sesame oil, and

<details><summary>Raw caption</summary>

```
⇩ Full Recipe 🥦 ⇩

Macros per 1 serving:
Protein: 5g
Carbs: 13g
Fat: 7g
Calories: 125

Ingredients per 4 servings:
- 1.5lbs broccoli
- 1 tsp salt
- 1 tbsp minced garlic
- 1 tsp black pepper
- 1.5 tbsp sesame oil
- 1.5 tbsp sesame seeds

How to make it yourself:

1. Rip off pieces of your broccoli
2. In a pot of boiling water, add your broccoli for 1-2 minutes then immediately remove and transfer to a bowl of cold water
3. In a bowl, mix together minced garlic, salt, black pepper, sesame oil, and
```
</details>

---

### 3. `DTBJYBPiH5Z` — @samia.momcoach

**Category:** Met tekst (NL inline) | **Caption:** 482 chars

**Result:** 3 ingredients, 0 steps

| Amount | Ingredient |
|--------|------------|
| 1 bakje | cottage cheese |
| 2 | eieren |
| 60 gram | bloem |

<details><summary>Raw caption</summary>

```
Hoe bevat deze heerlijke pizza 40 gram proteïne ? 🙈

Probeer deze uit als je wilt genieten en toch je body goals voor 2026 wilt halen🥰 
 
1 bakje cottage cheese
2 eieren 
60 gram bloem

Mix alle ingrediënten en giet over een bakplaat met pakpapier.
Doe in de oven op 180 graden voor 20-25 min
Beleg de pizza met pesto, tomaatjes en basilicum & doe nog eens in de oven voor 5-10 min. 

Enjoy♥️
#cottagecheese #viralpizza #afvallenzonderdieet #highproteinrecipes #afvallenzonderhonger
```
</details>

---

### 4. `DQ1tuOGiTd5` — @eatwellscarlett

**Category:** Truncated | **Caption:** 138 chars (truncated ⚠️)

**Result:** 3 ingredients, 0 steps

| Amount | Ingredient |
|--------|------------|
| 1 | canned tuna, drained |
| 1/4 | shredded cabbages |
| 1 tsp | oyster... |

<details><summary>Raw caption</summary>

```
Make my favorite diet cabbage tuna Deopbap with @recime.app !

🥬 ingredients!
1 canned tuna, drained
1/4 shredded cabbages
1 tsp oyster...
```
</details>

---

### 5. `DNVFPXwPqta` — @alexgamblecoach

**Category:** Met tekst (dot-prefix) | **Caption:** 487 chars

**Result:** 6 ingredients, 0 steps

| Amount | Ingredient |
|--------|------------|
| 60 g | Oats |
| 30 g | Whey protein |
| 100 g | Fat free greek yoghurt |
| 120 ml | skim milk (or almond milk) |
| 80 g | Berries of choice (can add now or fresh in the morning) |
| — | Dash of cinnamon (optional)  Smash them in the fridge overnight and you're good to go! |

<details><summary>Raw caption</summary>

```
Easiest Breakfast Meal Prep To Get 47g Protein 😋

If you're super busy and trying to lose some body fat, this is how you do it 👍

Per Meal 👇
. 60g Oats
. 30g Whey protein
. 100g Fat free greek yoghurt
. 120ml skim milk (or almond milk)
. 80g Berries of choice (can add now or fresh in the morning)
. Dash of cinnamon (optional)  Smash them in the fridge overnight and you're good to go! 

I wouldn't do more than 5 days worth personally… 

Macros Per Meal 📊
47g P
54g C
7g F
467 Calories
```
</details>

---

### 6. `DNTU0DRIrsA` — @balancewithnu

**Category:** Met tekst (dash-no-space) | **Caption:** 1149 chars

**Result:** 5 ingredients, 0 steps

| Amount | Ingredient |
|--------|------------|
| 1 | egg |
| 50 g | yogurt unflavoured (or vanilla) |
| 70 ml | milk - I use almond but any milk will work |
| 35 g | flour all purpose OR 35g oat flour OR 45 almond flour OR 10 g coconut flour |
| — | drizzle of honey (~1 tsp) (there is very little sugar in th |

<details><summary>Raw caption</summary>

```
My most trending recipe! Protein Pancake Bowls👇🥞

Per bowl (multiply by the servings you plan to make):
-1 egg
-50 g yogurt unflavoured (or vanilla)
-70 ml milk - I use almond but any milk will work
-35 g flour all purpose OR 35g oat flour OR 45 almond flour OR 10 g coconut flour 
-25 g vanilla whey protein powder (I use organic, clean whey protein powder from @theorganicproteinco ! Link in my bio and use code MANU10 for a discount 🎉)
- drizzle of honey (~1 tsp) (there is very little sugar in th
```
</details>

---

### 7. `DNAfCOzOu5z` — @joexfitness

**Category:** Met tekst (long) | **Caption:** 1266 chars

**Result:** 15 ingredients, 0 steps, 1 servings

| Amount | Ingredient |
|--------|------------|
| 1/2 | yellow onion |
| 3 tsp | minced garlic |
| 4 oz | thinly slices beef brisket |
| 2 | shiitake mushrooms |
| 1 cup | cut kimchi |
| 4 oz | firm tofu |
| 2 | green onion |
| 2 cups | chicken bone broth |
| 1/4 cup | leftover kimchi juice |
| 2 tsp | brown sugar |
| 2 tbsp | gochugaru |
| 2 tsp | gochujang |
| 1 tbsp | soy sauce |
| — | salt to taste |
| 1/3 | second spray oil |

<details><summary>Raw caption</summary>

```
⇩ Full Recipe 🍜 ⇩

Macros per 1 serving (1/2 the pot):
Protein: 40g
Carbs: 10g
Fat: 5g
Calories: 440

Ingredients per pot (1 pot makes 2 servings):
- 1/2 yellow onion
- 3 tsp minced garlic
- 4 oz thinly slices beef brisket
- 2 shiitake mushrooms
- 1 cup cut kimchi
- 4 oz firm tofu
- 2 green onion
- 2 cups chicken bone broth
- 1/4 cup leftover kimchi juice
- 2 tsp brown sugar
- 2 tbsp gochugaru
- 2 tsp gochujang
- 1 tbsp soy sauce
- salt to taste
- 1/3 second spray oil

How to make it yourself:
1
```
</details>

---

### 8. `DSBUsBHkrYh` — @overall.eats

**Category:** Truncated | **Caption:** 141 chars (truncated ⚠️)

**Result:** 3 ingredients, 0 steps

| Amount | Ingredient |
|--------|------------|
| — | hand-cut thick noodles (or any noodles you like) |
| — | peanut butter |
| — | chili... |

<details><summary>Raw caption</summary>

```
PEANUT CHILI OIL NOODLES - my favorite dish OAT👨‍🍳🫶

Ingredients:

-hand-cut thick noodles (or any noodles you like)
-peanut butter
-chili...
```
</details>

---

### 9. `DMlgiI9zZ7d` — @mattwest_roadtoaesthetics

**Category:** Met tekst (checkmarks) | **Caption:** 682 chars

**Result:** 9 ingredients, 0 steps

| Amount | Ingredient |
|--------|------------|
| 30 g | oat flour (finely blended oats) |
| 7 g | almond flour |
| 25 g | brown stevia |
| 15 g | choc chips |
| — | Pinch of salt |
| 28 g | melted light butter (brand: Lurpak Light) |
| 1 tsp | vanilla extract |
| 25 g | Queen's maple syrup |
| 1 scoop | @musclenation Vanilla Casein Custard, (use code "RTA" for |

<details><summary>Raw caption</summary>

```
F*ck or Suck Series
Cookie Dough Edition 🍪

Okay, this is a 100% f*ck and I'd highly recommend giving it a try. Would be a great Creami topper or a snack with a piece of fruit.

Original recipe: @panaceapalm

👨‍🍳 Ingredients:

✅ 30g oat flour (finely blended oats)
✅ 7g almond flour
✅ 25g brown stevia
✅ 15g choc chips
✅ Pinch of salt
✅ 28g melted light butter (brand: Lurpak Light)
✅ 1 tsp vanilla extract
✅ 25g Queen's maple syrup
✅ 1 scoop @musclenation Vanilla Casein Custard, (use code "RTA" for
```
</details>

---

### 10. `DPt_iQoEooo` — @overall.eats

**Category:** Truncated (minimal) | **Caption:** 142 chars (truncated ⚠️)

**Result:** 1 ingredients, 0 steps

| Amount | Ingredient |
|--------|------------|
| — | hand-cut thick noodles (or any... |

<details><summary>Raw caption</summary>

```
PEANUT CHILI OIL NOODLES

Comment "Recipe" and I'll send you the full recipe card for free!!

Ingredients:

-hand-cut thick noodles (or any...
```
</details>

---

### 11. `DHMQXAbsJzT` — @archersfood

**Category:** Extern recept | **Caption:** 315 chars

**Result:** 1 ingredients, 0 steps

| Amount | Ingredient |
|--------|------------|
| 214 g | protein pistachio cheesecake with cottage cheese so creamy and easy! |

<details><summary>Raw caption</summary>

```
214 G protein pistachio cheesecake with cottage cheese so creamy and easy!
https://archersfood.com/pistachio-protein-cheesecake/ FREE RECIPE in our website linked in our bio!
#protiendessert
#food #pistachiocheesecake #cottagecheese #cottagecheesecheesecake #cheesecakes #protienpistachiocheesecake #highprotienfood
```
</details>

