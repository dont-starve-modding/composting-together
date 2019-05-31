# Composting Together
Don't Starve Together mod which turns your garbage into valuable shitloads of shit a.k.a. manure!

    Warning: This mod is not yet completely tested. Please keep in mind, that it might crash on use.

    Please test this mod and send messages, if you find any bug!

Have you ever had an ice box full of nearly spoiled food and didnt know, what to do?

Just throw it on ur new fancy compost pile and get extra poop!

This new compost pile (requested here: http://forums.kleientertainment.com/topic/30589-mod-request-compost-piles/) can turn veggies, meals, twigs, grass, seeds and lot more into poop. You dont have to run to your beefalo-plains to find poop, you can generate it by yourself!

### Features

* Rotting veggies, fruits, eggs, meals, grass, twigs, cones, flowers, mushrooms and seeds (and mandrakes!)
* Dropping 2-8 Poop after a few days (~2-4 days) with given criterias (amount of stuff, spoilage ..)
* Burnable with 0-3 ash
* Probability of fireflies (usual: 5%, 99% in a specific case)
* Design: ~Farm + fancy poop-flies, New UI(5 Slots)
* Tech-Category: Food (with Science Machine)
* 6xRocks 3xPoop 4xLogs

### Future changes

* Custom minimap icon (possible?)
* Correct burnability

Special thanks to Malacath for the great support!

### Balance and Variables

#### Allowed Ingredients (Value, Shiny=0.0)

* Pome Granade, Dragon Fruit, Cave Banana, Watermelon, Berry (1)
* Durian (1)
* Carrot, Corn, Pumpkin, Eggplant, Cut Lichen, Cactus Flesh (1)
* Red, Green, Blue Cap (1)
* Mandrake (1, 4)
* Tallbird Egg (2)
* Egg, Bird Egg (1)
* Butterfly Wings (.5, 1) SHINY
* Twigs, Pinecone, Seeds (.25)
* Cut Grass, Rot, Evil Petals (.5)
* Petals (.5, .5) SHINY
* Butterflymuffin, Dragon Pie, Fist of Jam, Fruit Medley, Mandrake Soup, Powder Cake, Pumpkin Cookie, Ratatouille, Taffy, Unagi, Waffles (1.5)
* Bacon & Eggs, Fish Tacos, Fish Sticks, Froggle Bunwich, Honey Ham, Honey Nuggets, Kabobs, Meatballs, Bone Stew, Monster Lasagna, Perogies, Turkey Dinner (1 Meat)

#### Recipes

* If you reach a shiny value of at least 3.0 you get 4 poop and 99% prob of fireflies spawning after harvesting. (4 days)
* If you reach a value of 5.0, you receive 6 poop and 5% probability of fireflies spawning (2.2 days).
* If you reach a value of 3.0, you receive 4 poop and 5% probability of fireflies spawning (2 days).
* Else: you receive 2 poop and 5% probability of fireflies spawning after harvesting. (3 days)

#### Bonuses

1. Rottyness Bonus: If you compost some food which has an average spoilage of lower than 33% (this is nearly red), you receive one extra poop on harvesting.
1. Permanent Bonus: If you compost some food which let you gain at least 6 poop (recipe+rottyness bonus (point 1)), the compost pile develops fertile soil.
1. If you have spoilable food, you receive a bonus on the composting time. ``Factor = 0.5 + (totalSpoilage / (2*spoiledFoodCount))``. Example: 5 berries are half spoiled. ``totalSpoilage = 5 * 0.5 = 2.5``. ``spoiledFoodCount = 5`` --> ``Factor = 0.5 + (2.5 / 10) = 0.75``. Therefore the composttime is reduced by 25%
1. If you have fertile soil (see 2.), the composttime is reduced by 20% (If your reduced composttime (1.) is 20%, the complete reduction will be 28% (``0.8*0.9``))
1. The composting time bonuses can summarize to a maximum of ``0.5*0.8 = 40%``

