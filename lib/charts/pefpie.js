import { chart } from "highcharts";

export default class extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.createChart();
  }

  disconnectedCallback() {
    if (this.chart) {
      this.removeChild(this.container);
      this.chart.destroy();
    }
  }

  attributeChangedCallback(name, oldValue, newValue) {
    requestAnimationFrame(() => {
      if (name === "data") {
        const data = JSON.parse(newValue);
        this.chart.series[0].setData(data);
      }
    });
  }

  get container() {
    return this.querySelector(".chart-container");
  }

  static get observedAttributes() {
    return ["data"];
  }

  createChart() {
    if (this.container) {
      return;
    }

    this.appendChild(
      document.createRange().createContextualFragment(`
        <div class="chart-container"></div>
      `),
    );

    this.chart = chart(this.container, {
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
    });

    // Force reflow
    requestAnimationFrame(() => {
      this.chart.reflow();
    });
  }
}
