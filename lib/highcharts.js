import * as Highcharts from "highcharts";

export default class extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.createChart();
  }

  disconnectedCallback() {
    if (this.chart) {
      this.removeChild(this.querySelector(".chart-container"));
      this.chart.destroy();
    }
  }

  attributeChangedCallback(name, oldValue, newValue) {
    this.createChart();

    if (name === "data") {
      const data = JSON.parse(newValue);
      // see https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/members/series-setdata-pie/
      requestAnimationFrame(() => {
        this.chart.series[0].setData(data);
      }, 0);
    }
  }

  static get observedAttributes() {
    return ["data"];
  }

  createChart() {
    if (this.chart || this.querySelector(".chart-container")) {
      return;
    }

    this.appendChild(
      document.createRange().createContextualFragment(`
        <div class="chart-container"></div>
      `),
    );
    const container = this.querySelector(".chart-container");
    this.chart = Highcharts.chart(container, {
      chart: {
        type: "pie",
      },
      title: null,
      series: [
        {
          data: [],
        },
      ],
    });
    // Force reflow
    requestAnimationFrame(() => {
      this.chart.reflow();
    }, 0);
  }
}
