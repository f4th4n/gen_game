const path = require('path')
const BrowserSyncPlugin = require("browser-sync-webpack-plugin");

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'main.js',
    path: path.resolve(__dirname, 'dist'),
  },
	devtool: 'eval-source-map',
	watchOptions: {
		ignored: /node_modules/,
	},
	plugins: [
		new BrowserSyncPlugin({
			files: [
				'./src/**/*.js'
			],
			watchTask: true,
			open: "external",
			logLevel: "silent",
      host: 'localhost',
      port: 3000,
			server: { baseDir: ['.'] }
		}),
	]
}
