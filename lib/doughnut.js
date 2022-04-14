// TODO: use only what's needed
// @see https://www.chartjs.org/docs/latest/getting-started/integration.html#bundlers-webpack-rollup-etc
import Chart from "chart.js/auto";

const colors = [
  "#7b4effcc",
  "#e860dfcc",
  "#21a5edcc",
  "#74c609cc",
  "#f2315bcc",
  "#feca00cc",
  "#000000cc",
];

function getData() {
  return {
    labels: colors,
    datasets: [
      {
        label: "Dataset 1",
        data: [1, 5, 2, 10, 6, 2, 9],
        backgroundColor: colors,
      },
      // {
      //   label: "Dataset 2",
      //   data: [1, 5, 2, 10, 6, 2, 9].reverse(),
      //   backgroundColor: colors,
      // },
    ],
  };
}

function getConfig({ caption, data }) {
  return {
    type: "doughnut",
    data: getData(),
    options: {
      animation: false,
      responsive: true,
      plugins: {
        legend: {
          display: false,
          position: "top",
        },
        title: {
          display: true,
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
      this.chart.options.plugins.title.text = newValue;
    } else if (name === "data") {
      console.log("new data", newValue);
    } else if (name === "style") {
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
