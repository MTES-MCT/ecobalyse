import { chart } from "highcharts";

function ucfirst(s) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

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
    this.createChart();

    if (name === "data") {
      const data = JSON.parse(newValue);
      requestAnimationFrame(() => {
        this.chart.series[0].setData(
          // FIXME: Shouldn't this be rather processed in Elm?
          data.map(({ name, y }) => {
            return [Date.parse(name), y];
          }),
        );
      });
    } else if (name === "heading") {
      requestAnimationFrame(() => {
        this.chart.setTitle({ text: newValue });
      });
    } else if (name === "height") {
      requestAnimationFrame(() => {
        this.chart.setSize(null, parseInt(newValue, 10));
      });
    } else if (name === "unit") {
      requestAnimationFrame(() => {
        const unitTitle = ucfirst(newValue + "s");
        this.chart.yAxis[0].setTitle({ text: unitTitle });
        this.chart.series[0].setName(unitTitle);
      });
    }
  }

  get container() {
    return this.querySelector(".chart-container");
  }

  static get observedAttributes() {
    return ["data", "heading", "height", "unit"];
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
        type: "spline",
      },
      subtitle: {
        text: "30 derniers jours",
      },
      xAxis: {
        type: "datetime",
      },
      series: [{ lineWidth: 4 }],
    });

    // Force reflow
    requestAnimationFrame(() => {
      this.chart.reflow();
    });
  }
}
