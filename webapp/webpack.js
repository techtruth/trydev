const webpack = require("webpack");
const WebpackDevServer = require('webpack-dev-server');
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
//const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");
const argv = require("minimist")(process.argv.slice(2));

const config = {
  context: __dirname,
  mode: argv.mode === "production" ? "production" : "development",
  bail: true,
  devtool: argv.mode === "production" ? undefined : "eval-source-map",
  //General params, but not used. We rebuild source with webpack --watch instead
  devServer: {
    allowedHosts: "all",
    liveReload: true,
    hot: false,
    client: {
      overlay: true
    },
    host: "0.0.0.0",
    compress: true,
    https: true
  },

  //Single entrypoint, with multiple files
  entry: {
    entrypoint: ["./index.js"],
  },

  //Where built files will be sent to. Match the webserver static directory here.
  output: {
    path: path.resolve(__dirname, "dist"),
    publicPath: "/", 
    filename:
      argv.mode === "production"
        ? "js/[chunkhash].js"
        : "js/[name].js",
    sourceMapFilename: "js/[name].js.map[query]",
    chunkFilename:
      argv.mode === "production"
        ? "js/bundle.[chunkhash].js"
        : "js/bundle.[name].js",
    assetModuleFilename: "assets/[name]-[contenthash][ext]",
    hashFunction: "xxhash64"
  },

  optimization: {
    runtimeChunk: "single"
  },

  //Handle things outside of webpack base functionality
  plugins: [
    new HtmlWebpackPlugin({
      title:
        argv.mode === "production"
          ? Somesite
          : process.env.npm_package_version,
      filename: "index.html",
    }),
    //new ForkTsCheckerWebpackPlugin({ typescript: { configFile: "../tsconfig.json" } }),
    new MiniCssExtractPlugin({ filename: "[name]-[contenthash].css" })
  ],

  module: {
    rules: [
      {
        test: /\.js$|\.ts$/,
        use: ["babel-loader"]
      },
      {
        test: /\.ts$/,
        loader: "ts-loader",
        options: {
          transpileOnly: true
        },
        exclude: /node_modules/
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"]
      },
      {
        test: /\.png$|\.jpg$|\.env$|\.svg$/,
        resourceQuery: { not: [/raw/, /staticUrl/] },
        type: "asset"
      },
      {
        test: /\.ttf$|\.woff2$|\.woff$|\.eot$|\.mp3$|\.mp4$|\.m4a$|\.bin$/,
        type: "asset/resource"
      },
    ]
  },

  resolve: {
    extensions: [".js", ".ts", ".json"],

    fallback: {
      https: false,
      stream: false,
      zlib: false,
      crypto: false,
      http: false,
      buffer: false,
      assert: false,
      fs: false,
      net: false,
      tls: false,
      inherits: false,
      path: false,
      console: false,
      process: false,
      util: false,
      url: false
    }
  }
};

if (argv.serve) {
  const compiler = webpack(config);
  new WebpackDevServer(config.devserver, compiler).start();
} else {
  //Compile webpack
  const compiler = webpack(config, (err, stats) => {
    if (err) {
      console.error("Webpack Error:");
      console.log(err);
      return;
    }
    if (stats.hasErrors() || stats.hasWarnings()) {
      console.log(stats.toString({ colors: true }));
      return;
    }
    console.log(
      stats.toString({
        colors: true,
        warnings: true,
        assets: true,
        moduleAssets: true,
        groupAssetsByChunk: false,
        groupAssetsByEmitStatus: false,
        groupAssetsByInfo: false,
        orphanModules: true,
        modules: true,
        groupModulesByAttributes: false,
        dependentModules: true,
        entrypoints: true,
        chunks: false,
        chunkGroups: false,
        chunkModules: false,
        chunkOrigins: false,
        chunkRelations: false,
        env: true,
        performance: true
      })
    );
  });
  if (argv.watch) {

    compiler.watch(
      {
        aggregateTimeout: 500,
        poll: 2000,
        ignored: /node_modules/
      },
      (err, stats) => {
        if (err) {
          console.error(err);
          return;
        }
        if (stats && stats.hasErrors()) {
          console.error(stats.toString({ colors: true }));
          return;
        }
        console.log(stats.toString({ colors: true }));
      }
    );
  }
}
