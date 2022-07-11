import BaseChart from "./base";

function ucfirst(s) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

export default class extends BaseChart {
  constructor() {
    super();
  }

  static get observedAttributes() {
    return ["data", "heading", "height", "unit"];
  }

  get config() {
    return {
      chart: {
        type: "spline",
      },
      accessibility: {
        description: `Évolution de la fréquentation`,
      },
      subtitle: {
        text: "30 derniers jours",
      },
      xAxis: {
        type: "datetime",
      },
      series: [{ lineWidth: 4 }],
    };
  }

  attributeChanged(name, oldValue, newValue) {
    if (name === "data") {
      const data = JSON.parse(newValue);
      this.chart.series[0].setData(data);
    } else if (name === "heading") {
      this.chart.setTitle({ text: newValue });
    } else if (name === "height") {
      this.chart.setSize(null, parseInt(newValue, 10));
    } else if (name === "unit") {
      const unitTitle = ucfirst(newValue + "s");
      this.chart.yAxis[0].setTitle({ text: unitTitle });
      this.chart.series[0].setName(unitTitle);
    }
  }
}
