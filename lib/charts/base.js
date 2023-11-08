import Highcharts from "highcharts";
import exportingOption from "highcharts/modules/exporting";
import offlineOption from "highcharts/modules/offline-exporting";

exportingOption(Highcharts);
offlineOption(Highcharts);

export default class extends HTMLElement {
  constructor() {
    super();
  }

  static get observedAttributes() {
    throw new Error("Must be implemented");
  }

  get config() {
    throw new Error("Must be implemented");
  }

  attributeChanged(name, oldValue, newValue) {
    throw new Error("Must be implemented");
  }

  get container() {
    return this.querySelector(".chart-container");
  }

  attributeChangedCallback(name, oldValue, newValue) {
    requestAnimationFrame(() => {
      this.attributeChanged(name, oldValue, newValue);
    });
  }

  connectedCallback() {
    this.appendChild(
      document.createRange().createContextualFragment(`
        <div class="chart-container"></div>
      `),
    );

    this.chart = Highcharts.chart(this.container, this.config);

    // Force reflow
    requestAnimationFrame(() => {
      this.chart.reflow();
    });
  }

  disconnectedCallback() {
    if (this.chart) {
      this.removeChild(this.container);
      this.chart.destroy();
    }
  }
}
