import Highcharts from "highcharts";
import enableA11y from "highcharts/modules/accessibility";
import FoodComparator from "./food-comparator";
import PefPie from "./pefpie";
import Stats from "./stats";

// Enable a11y https://www.highcharts.com/docs/accessibility/accessibility-module
enableA11y(Highcharts);

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
    customElements.define("chart-pefpie", PefPie);
    customElements.define("chart-stats", Stats);
    customElements.define("chart-food-comparator", FoodComparator);
  },
};
