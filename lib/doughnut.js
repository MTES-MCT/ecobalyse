// TODO: use only what's needed
// @see https://www.chartjs.org/docs/latest/getting-started/integration.html#bundlers-webpack-rollup-etc
import Chart from "chart.js/auto";

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

function getConfig({ caption }) {
  return {
    type: "doughnut",
    data: {
      labels: [],
      datasets: [],
    },
    options: {
      animation: false,
      responsive: true,
      plugins: {
        legend: {
          display: true,
          position: "left",
        },
        title: {
          display: !!caption,
          text: caption,
        },
      },
    },
  };
}

export default class Doughnut extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    console.log("connectedCallback");
    this.createChart();
  }

  disconnectedCallback() {
    this.chart?.destroy();
  }

  attributeChangedCallback(name, oldValue, newValue) {
    this.createChart();

    if (name === "caption") {
      this.chart.options.plugins.title.display = !!newValue;
      this.chart.options.plugins.title.text = newValue;
    } else if (name === "data") {
      console.log("data");
      const data = JSON.parse(newValue);
      this.chart.data = {
        labels: data.labels,
        datasets: [
          {
            data: data.values,
            backgroundColor: colors,
          },
        ],
      };
    } else if (name === "style") {
      console.log(newValue);
      this.querySelector(".chart-container")?.setAttribute("style", newValue);
    }

    this.chart.update();
  }

  static get observedAttributes() {
    return ["caption", "data", "style"];
  }

  createChart() {
    if (this.chart) {
      return;
    }

    this.appendChild(
      document.createRange().createContextualFragment(`
        <div class="chart-container">
          <canvas></canvas>
        </div>
      `),
    );

    this.config = getConfig({
      caption: this.getAttribute("caption"),
      data: this.getAttribute("data"),
    });

    const ctx = this.querySelector("canvas")?.getContext("2d");
    this.chart = new Chart(ctx, this.config);
  }
}
