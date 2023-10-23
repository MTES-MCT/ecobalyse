This a reimplementation of the Brightway explorer through an API, aimed at
being less dependent from Jupyter and Python. Note that this correspond to the
direct export of the Brightway data.

# Sample list of API endpoints:


## Databases

* The list of Databases in the project `food`

https://bwapi.ecobalyse.fr/food/databases


## Search

* A search of the term `coffee` in the database `Agribalyse 3.1.1`

https://bwapi.ecobalyse.fr/food/Agribalyse%203.1.1/search/?q=coffee

## Activity data and graph

* The full data of the activity with code `109d03783d26742b87f1a94889d972f3`

https://bwapi.ecobalyse.fr/food/Agribalyse%203.1.1/109d03783d26742b87f1a94889d972f3/data

* The first level of the upstream activities of the same activity

https://bwapi.ecobalyse.fr/food/Agribalyse%203.1.1/109d03783d26742b87f1a94889d972f3/technosphere

* The elementary flows of the same activity

https://bwapi.ecobalyse.fr/food/Agribalyse%203.1.1/109d03783d26742b87f1a94889d972f3/biosphere

* The substitution exchanges of the same activity

https://bwapi.ecobalyse.fr/food/Agribalyse%203.1.1/109d03783d26742b87f1a94889d972f3/substitution

* The impacts of the same activity

https://bwapi.ecobalyse.fr/food/Agribalyse%203.1.1/109d03783d26742b87f1a94889d972f3/impacts/EF%20v3.1


## Methods

* The list of LCIA methods

https://bwapi.ecobalyse.fr/food/methods

* The list of impact categories for a method

https://bwapi.ecobalyse.fr/food/methods/EF%20v3.1

* The details of a method

https://bwapi.ecobalyse.fr/food/methods/EF%20v3.1/acidification/accumulated%20exceedance%20(AE)

* The characterization factors of a method

https://bwapi.ecobalyse.fr/food/characterization_factors/EF%20v3.1/acidification/accumulated%20exceedance%20(AE)


