// Karma configuration
// Generated on Mon Oct 21 2013 21:27:57 GMT+0200 (W. Europe Daylight Time)

module.exports = function (config) {
    config.set({

        // base path, that will be used to resolve files and exclude
        basePath: '',


        // frameworks to use
        frameworks: ['jasmine'],


        // list of files / patterns to load in the browser
        files: [
            'public/lib/jquery-1.10.2.min.js',
            'public/lib/**/*.js',
            'test/**/*.js',
            'test/out/**/*.js'
        ],


        // list of files to exclude
        exclude: [
            'public/lib/startup.js',
        ],

        // test results reporter to use
        // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
        //reporters: ['progress'],
        reporters: ['progress', 'osx'],


        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // Start these browsers, currently available:
        // - Chrome
        // - ChromeCanary
        // - Firefox
        // - Opera
        // - Safari (only Mac)
        // - PhantomJS
        // - IE (only Windows)
        browsers: ['PhantomJS'],

        /*customLaunchers: {
            'PhantomJSCustom': {
                base: 'PhantomJS',
                options: {
                    //settings: {
                        //webSecurityEnabled: false
                        //--web-security=: false
                    //   }
                    webSecurityEnabled: false
                }
            }
        },*/


        // If browser does not capture in given timeout [ms], kill it
        captureTimeout: 60000,


        // Continuous Integration mode
        // if true, it capture browsers, run tests and exit
        singleRun: false
    });
};
