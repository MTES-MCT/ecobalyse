import PefPie from "./pefpie";

export default {
  registerElements: function () {
    customElements.define("chart-pefpie", PefPie);
  },
};
