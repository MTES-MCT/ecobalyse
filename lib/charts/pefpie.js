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
      caption: {
        text: `Le score PEF est calculé selon la méthodologie proposée par le PEFCR Apparel
        &amp; Footwear. <b>Dans un premier temps et faute de données disponibles dans la Base
        Impacts, l'épuisement des ressources en eau, l'ecotoxicité eau douce, la toxicité
        humaine (cancer) et la toxicité humaine (non cancer) ne sont pas pris en compte à ce
        stade.</b>`,
      },
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
