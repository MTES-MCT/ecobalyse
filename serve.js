import * as esbuild from "esbuild";
import { sassPlugin } from "esbuild-sass-plugin";

await esbuild.serve(
  {
    port: 8000,
    servedir: "public/",
  },
  {
    entryPoints: {
      index: "index.js",
      styles: "styles.scss",
    },
    loader: { ".png": "dataurl" },
    outdir: "public/build/",
    bundle: true,
    plugins: [sassPlugin()],
  },
);
