import * as Highcharts from "highcharts";

const colors = [
  "#00429d",
  "#1f4ea3",
  "#305ba9",
  "#3e67ae",
  "#4a74b4",
  "#5681b9",
  "#618fbf",
  "#6d9cc4",
  "#79a9c9",
  "#85b7ce",
  "#93c4d2",
  "#a1d1d7",
  "#b1dfdb",
  "#c3ebde",
  "#daf7e1",
  "#ffffe0",
];

export default class HighchartsWC extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    // console.log("connected");
    this.createChart();
  }

  disconnectedCallback() {
    // console.log("disconnecting");
    if (this.chart) {
      this.removeChild(this.querySelector(".chart-container"));
      this.chart.destroy();
      // console.log("destroyed");
    }
  }

  attributeChangedCallback(name, oldValue, newValue) {
    // console.log("attr", name);
    this.createChart();

    if (name === "data") {
      const data = JSON.parse(newValue);
      // console.log("data changed", data);
      // see https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/members/series-setdata-pie/
      requestAnimationFrame(() => {
        this.chart.series[0].setData(data);
      }, 0);
    }
  }

  static get observedAttributes() {
    return ["data"];
  }

  firstUpdated() {
    // console.log("firstUpdated");
  }

  createChart() {
    if (this.chart || this.querySelector(".chart-container")) {
      // console.log("got chart");
      return;
    }
    // console.log("no chart, creating");

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
