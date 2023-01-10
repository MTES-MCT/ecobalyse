import BaseChart from "./base";

export default class extends BaseChart {
  constructor() {
    super();
  }

  static get observedAttributes() {
    return ["data"];
  }

  get config() {
    return {
      chart: {
        type: "bar",
      },
      title: {
        text: "Comparaison des compositions du score d'impact des recettes sélectionnées",
      },
      xAxis: {
        categories: [
          // XXX: recipe names here
          "Recette1",
          "Recette2",
          "Recette3",
          "Recette4",
          "Recette5",
        ],
        tickPosition: "inside",
        labels: {
          allowOverlap: false,
          style: { fontSize: "13px", color: "#333" },
        },
      },
      yAxis: {
        min: 0,
        title: {
          text: "µPts d'impact",
        },
      },
      legend: {
        reversed: true,
      },
      plotOptions: {
        series: {
          stacking: "normal",
          dataLabels: {
            enabled: true,
          },
        },
      },
      series: [],
    };
  }

  attributeChanged(name, oldValue, newValue) {
    if (name === "data") {
      //   const data = JSON.parse(newValue);
      const data = {
        labels: ["Recette*1", "Recette*2", "Recette*3", "Recette*4", "Recette*5"],
        series: [
          {
            // XXX: Impact name here
            name: "Acidification des sols",
            // XXX: impact values for each product here
            data: [4, 4, 6, 15, 12],
          },
          {
            name: "Biodiversité",
            data: [5, 3, 12, 6, 11],
          },
          {
            name: "Changement climatique",
            data: [5, 15, 8, 5, 8],
          },
        ],
      };
      this.chart.update({
        xAxis: {
          categories: data.labels,
        },
      });
      // Remove all existing series and replace them with fresh ones
      for (const serie of this.chart.series) {
        serie.remove();
      }
      for (const serie of data.series) {
        this.chart.addSeries(serie);
      }
    }
  }
}
