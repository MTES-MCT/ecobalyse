const request = require("supertest");


const { app, elmApp } = require("./server.app");
const originalSend = elmApp.ports.input.send;

describe("GET / ", () => {
  test("It should respond with the proper amount of co2", (done) => {
    const params = [
      // [ mass of the product, co2 impact ] <=== the mass is also used for the delay
      [ 0.17, 4.4140271789664345 ],
      [ 0.19, 4.928540817668366 ],
      [ 0.18, 4.671283998317399 ],
    ];

    elmApp.ports.input.send = jest.fn();

    params.forEach(async ([mass, co2Impact]) => {
      elmApp.ports.input.send.mockImplementationOnce(params => {
        const delay = mass * 1000;
        console.log(`Delaying ${delay} milliseconds before sending the params through the port`);
        setTimeout(originalSend, delay, params)
      });

        try {
          const response = await request(app).get(`/?mass=${mass}&product=13&material=f211bbdb-415c-46fd-be4d-ddf199575b44&countries[]=CN&countries[]=FR&countries[]=FR&countries[]=FR&countries[]=FR&dyeingWeighting=&airTransportRatio=&recycledRatio=&customCountryMixes.fabric=&customCountryMixes.dyeing=&customCountryMixes.making=`);
          expect(response.body.co2).toEqual(co2Impact);
          expect(response.statusCode).toBe(200);
          done();
        } catch (error) {
          console.log(`Failed for mass=${mass} which should have resulted in ${co2Impact}`);
          done(error);
        }
    });
  });
});