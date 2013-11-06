/*global module:false*/
module.exports = function (grunt) {

    // Project configuration.
    grunt.initConfig({
        // Metadata.
        pkg: grunt.file.readJSON('package.json'),
        banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
            '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
            '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
            '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
            ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',

        // Task configuration.
        coffee: {
            compile: {
                options: {
                    join: true,
                    sourceMap: true
                },
                files: {
                    './public/out/compiled.js': ['./public/src/**/*.coffee']
                }
            },
            prepare_test: {
                options: {
                    join: true,
                    sourceMap: true,
                    bare: true
                },
                files: {
                    './test/out/compiled.js': ['./public/src/**/*.coffee', './test/*.coffee']
                }
            }
        },
        uglify: {
            options: {
                banner: '<%= banner %>',
                sourceMap: './public/out/compiled.min.js.map'
            },
            dist: {
                src: './public/out/compiled.js',
                dest: './public/out/compiled.min.js'
            }
        },
        karma: {
            options: {
                configFile: 'karma.conf.js',
                autoWatch: true
            },
            ci: {
                singleRun: true,
                configFile: 'karma.conf.js'
            },
            unit: {
            }
        },
        watch: {
            scripts: {
                files: ['**/*.coffee'],
                tasks: ['coffee:compile', 'coffee:prepare_test', 'notify:compile'],
                options: {
                    spawn: false
                }
            }
        },
        notify_hooks: {
            options: {
                enabled: true
                //max_jshint_notifications: 5, // maximum number of notifications from jshint output
                //title: "Project Name" // defaults to the name in package.json, or uses project's directory name, you can change to the name of your project
            }
        },
        notify: {
            compile: {
                options: {
                    title: 'Compilation done',
                    message: 'Compilation done'
                }
            }
        }


        /*concat: {
            options: {
                banner: '<%= banner %>',
                stripBanners: true
            },
            dist: {
                src: ['public/lib/*.js', 'public/src/*.coffee'],
                dest: 'public/out/<%= pkg.name %>.js'
            }
        },
        jshint: {
            options: {
                curly: true,
                eqeqeq: true,
                immed: true,
                latedef: true,
                newcap: true,
                noarg: true,
                sub: true,
                undef: true,
                unused: true,
                boss: true,
                eqnull: true,
                browser: true,
                globals: {
                    jQuery: true
                }
            },
            gruntfile: {
                src: 'Gruntfile.js'
            },
            lib_test: {
                src: ['public/lib/* * /*.js', 'public/src/* * / *.coffee', 'public/src-test/** / *.coffee'] //'public/src/** /*.coffee', 'public/src-test/** / *.coffee'
            }
        },
        qunit: {
            files: ['public/src-test/** /*.html']
        },
        watch: {
            gruntfile: {
                files: '<%= jshint.gruntfile.src %>',
                tasks: ['jshint:gruntfile']
            },
            lib_test: {
                files: '<%= jshint.lib_test.src %>',
                tasks: ['jshint:lib_test', 'qunit']
            }
        }*/
    });

    // These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-qunit');
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-karma');
    grunt.loadNpmTasks('grunt-notify');


    grunt.task.run('notify_hooks');

    // Default task.
    //grunt.registerTask('default', ['jshint', 'qunit', 'concat', 'uglify']);
    grunt.registerTask('default', ['coffee:compile']);
	grunt.registerTask('prepare_test', ['coffee:prepare_test']);


};
