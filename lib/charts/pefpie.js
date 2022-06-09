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
        type: "pie",
      },
      title: null,
      plotOptions: {
        series: {
          animation: false,
        },
        pie: {
          allowPointSelect: true,
          cursor: "pointer",
          dataLabels: {
            enabled: true,
            format: "{point.name}: {point.percentage:.1f}%",
          },
        },
      },
      tooltip: {
        pointFormat: "<b>{point.y:.2f}</b> mPt (<b>{point.percentage:.1f}</b> %)",
      },
      series: [
        {
          name: "Valeur (mPt)",
          data: [],
        },
      ],
    };
  }

  attributeChanged(name, oldValue, newValue) {
    if (name === "data") {
      const data = JSON.parse(newValue);
      this.chart.series[0].setData(data);
    }
  }
}
