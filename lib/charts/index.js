import Highcharts from "highcharts";
import "highcharts/modules/accessibility";
import FoodComparator from "./food-comparator";
import Stats from "./stats";

Highcharts.setOptions({
  lang: {
    loading: "Chargement…",
    months: [
      "janvier",
      "février",
      "mars",
      "avril",
      "mai",
      "juin",
      "juillet",
      "août",
      "septembre",
      "octobre",
      "novembre",
      "décembre",
    ],
    weekdays: ["dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi"],
    shortMonths: [
      "jan",
      "fév",
      "mar",
      "avr",
      "mai",
      "juin",
      "juil",
      "aoû",
      "sep",
      "oct",
      "nov",
      "déc",
    ],
    exportButtonTitle: "Exporter",
    printButtonTitle: "Imprimer",
    rangeSelectorFrom: "Du",
    rangeSelectorTo: "au",
    rangeSelectorZoom: "Période",
    downloadPNG: "Télécharger en PNG",
    downloadJPEG: "Télécharger en JPEG",
    downloadPDF: "Télécharger en PDF",
    downloadSVG: "Télécharger en SVG",
    resetZoom: "Réinitialiser le zoom",
    resetZoomTitle: "Réinitialiser le zoom",
    thousandsSep: " ",
    decimalPoint: ",",
  },
});

export default {
  registerElements: function () {
    customElements.define("chart-stats", Stats);
    customElements.define("chart-food-comparator", FoodComparator);
  },
};
