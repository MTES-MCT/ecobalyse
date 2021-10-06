// see https://stackoverflow.com/a/68664795/330911
module.exports = function (app) {
  app.use((req, res, next) => {
    res.removeHeader("Cross-Origin-Resource-Policy");
    res.removeHeader("Cross-Origin-Embedder-Policy");
    res.removeHeader("Cross-Origin-Opener-Policy");
    next();
  });
};
