---
description: Cette page décrit le calcul du coût environnemental de la batterie.
---

# 🔋 Batterie

## Généralités

La batterie représente 10% à 50% du coût environnemental d'un véhicule électrique. Ce chiffre varie principalement en fonction de l'autonomie recherchée pour le véhicule (capacité de la batterie), et du poids du véhicule.

## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Le coût environnement de la batterie est évalué d'après sa chimie, sa capacité (en kWh) et son pays de fabrication (assemblage du pack batterie).

Les chimies de batterie suivantes sont différenciées : NMC532, NMC622, NMC811, LFP.

Les sites et méthodes de fabrication des modules et cellules de batterie, ainsi que les sites et méthode d'extraction et de raffinage des matières premières ont également une réelle influence sur le coût environnemental. \
Cependant, par souci de simplification et compte-tenu de la difficulté à détailler la chaine de valeur de fabrication, ils ne sont pas utilisés comme paramètres dans Ecobalyse.

En plus de la capacité et du pays de fabrication, l'utilisateur doit renseigner le poids de la batterie, pour le calcul du poids des composants non directement quantifié, et pour le calcul du coût environnemental du transport.

### Procédés utilisés pour la modélisation

Les données sur l'impact environnemental sont issues de la Base Empreinte.

L'impact sur le changement climatique de ces procédés, exprimé en kgCO2e, est détaillé dans le tableau suivant en fonction de la chimie et du pays de fabrication de la batterie.&#x20;

Ces procédés ont été construits pour des batteries de voitures. Dans leur construction, il est considéré que le pays de fabrication des cellules et du pack batterie est le même.

<table><thead><tr><th width="154">Pays</th><th width="84">LFP</th><th width="109">NMC532</th><th width="102">NMC622</th><th width="104">NMC811</th><th width="94">Autre</th></tr></thead><tbody><tr><td>Chine</td><td>67</td><td>112</td><td>112</td><td>105</td><td>112</td></tr><tr><td>Corée du Sud</td><td>65</td><td>110</td><td>110</td><td>103</td><td>110</td></tr><tr><td>Japon </td><td>61</td><td>106</td><td>106</td><td>99</td><td>106</td></tr><tr><td>Allemagne</td><td>51</td><td>96</td><td>96</td><td>89</td><td>96</td></tr><tr><td>Espagne</td><td>55</td><td>99</td><td>100</td><td>93</td><td>100</td></tr><tr><td>France</td><td>48</td><td>93</td><td>94</td><td>86</td><td>94</td></tr><tr><td>Hongrie</td><td>47</td><td>92</td><td>92</td><td>85</td><td>92</td></tr><tr><td>Italie</td><td>56</td><td>101</td><td>101</td><td>94</td><td>101</td></tr><tr><td>Norvège </td><td>50</td><td>95</td><td>96</td><td>88</td><td>96</td></tr><tr><td>Pologne</td><td>54</td><td>99</td><td>99</td><td>92</td><td>99</td></tr><tr><td>Royame-Uni</td><td>48</td><td>93</td><td>94</td><td>86</td><td>94</td></tr><tr><td>Slovaquie </td><td>47</td><td>92</td><td>92</td><td>85</td><td>92</td></tr><tr><td>Suède</td><td>46</td><td>92</td><td>92</td><td>84</td><td>92</td></tr><tr><td>Europe autres pays</td><td>56</td><td>101</td><td>101</td><td>94</td><td>101</td></tr><tr><td>Etats-Unis</td><td>56</td><td>101</td><td>101</td><td>94</td><td>101</td></tr><tr><td>Autres pays</td><td>67</td><td>112</td><td>112</td><td>105</td><td>112</td></tr></tbody></table>

