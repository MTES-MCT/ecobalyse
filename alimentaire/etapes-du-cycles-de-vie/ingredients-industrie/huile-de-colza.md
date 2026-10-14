# 🌼 Huile de colza

## Construction de l'ingrédient industrie à partir d'ingrédients agricoles

Le procédé proposé dans Agribalyse pour l'huile de tournesol est :&#x20;

* Rapeseed oil, at oil mill {GLO} - Adapted from WFLDB U

$$
HuilecolzaREF
$$

{% hint style="info" %}
**Attente du graphe Simapro pour confirmer ce procédé et identifier le procédé tournesol mobilisé pour l'huile de tournesol.**
{% endhint %}



Dans Agribalyse, ce procédé est construit à partir de :&#x20;

* Rapeseed, at farm {GLO} - Adapted from WFLDB U

$$
ColzaREF
$$

* d'opérations industrielles :&#x20;



<figure><img src="../../../.gitbook/assets/image (170).png" alt=""><figcaption></figcaption></figure>

On construit différents procédés d'huile de colza **(N)**, sur la base du procédé de référence (Rapeseed oil, at oil mill), en appliquant les opérations industrielles à différents procédés de tournesol **(N),** avec le ratio qui correspond à la quantité de colza nécessaire pour faire 1 kg d'huile de colza. Ratio = 1.66 kg d'après le schéma ci dessus.

$$
ImpactHuileColza_N = ImpactHuileColzaREF + ratio * (ImpactColza_N - ImpactColzaREF)
$$



## Procédés retenus

<table><thead><tr><th>Label / Origine</th><th>France</th><th>Autres pays</th></tr></thead><tbody><tr><td>Conventionnelle</td><td><strong>HuileColzaFR</strong><br>Procédé construit (cf. formule)<br>Colza : Rapeseed, at farm (WFLDB 3.1)/FR U</td><td><p>A venir : </p><p><strong>HuileColzaREF</strong><br>Rapeseed oil, at oil mill (WFLDB 3.1)<br>Tournesol : Rapeseed, at farm (WFLDB 3.1)/GLO U</p></td></tr><tr><td>Agriculture biologique</td><td><p><strong>HuileColzaBio</strong><br>Procédé construit (cf. formule)<br>Colza : </p><pre class="language-json"><code class="lang-json">Winter rapeseed, organic, at farm gate {FR} U
</code></pre></td><td><p><strong>HuileColzaBio</strong><br>Procédé construit (cf. formule)<br>Colza :</p><pre class="language-json"><code class="lang-json">Winter rapeseed, organic, at farm gate {FR} U
</code></pre></td></tr></tbody></table>

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => origine par défaut : FRANCE
2. Ingrédient très majoritairement produit en Europe/Maghreb (>95%) => transport par défaut : EUROPE/MAGHREB&#x20;
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : PAYS TIERS
4. Ingrédient spécifique (ex. Haricots et Mangues)&#x20;

**Huile de tournesol => catégorie 2 : EUROPE/MAGHREB** (source : dires d'experts/à confirmer)&#x20;

