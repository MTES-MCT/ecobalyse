const { app } = require("./server.app");

const host = "0.0.0.0";
const port = process.env.PORT || 3000;

app.listen(port, host, () => {
  console.log(`Example app listening at http://${host}:${port}`);
});
