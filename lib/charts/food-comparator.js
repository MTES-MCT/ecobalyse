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
        height: "100%",
        animation: false,
      },
      title: false,
      xAxis: {
        categories: [],
        tickPosition: "inside",
        labels: {
          allowOverlap: false,
          style: { fontSize: "13px", color: "#333" },
        },
      },
      yAxis: {
        title: {
          text: "Pts d’impact",
        },
      },
      legend: {
        reversed: true,
      },
      plotOptions: {
        animation: false,
        series: {
          animation: false,
          stacking: "normal",
        },
      },
      tooltip: {
        valueDecimals: 2,
        valueSuffix: " Pts d’impact",
      },
      series: [],
      exporting: {
        fallbackToExportServer: false,
        chartOptions: {
          title: false,
        },
        filename: "ecobalyse",
      },
    };
  }

  attributeChanged(name, oldValue, newValue) {
    if (name === "data") {
      const rawData = JSON.parse(newValue);
      // Code below will map the JSON data received from Elm to data structures
      // expected by Highcharts.
      const series = rawData[0].data.map(({ name, color }, idx) => {
        return { name, color, data: rawData.map(({ data }) => data[idx].y) };
      });
      this.chart.update({
        xAxis: {
          categories: rawData.map(({ label }) => label),
        },
      });
      // Remove all existing series...
      while (this.chart.series.length) {
        this.chart.series[0].remove();
      }
      // ... and replace them with fresh ones
      for (const serie of series) {
        this.chart.addSeries(serie);
      }
    }
  }
}
