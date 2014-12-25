/* Simple helper function to generate less file targets */
var handleLess = function(name) {
  return {
    options: { 
      sourceMap: true,
      sourceMapFileName: "bin/styles/" + name + ".css.map",
      sourceMapURL: name + ".css.map",
      sourceMapBasepath: "src/less",
      sourceMapRootpath: "./less" 
    },
    src: "src/less/"+ name + ".less",
    dest: "bin/styles/" + name + ".css"
  }
}

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    // Metadata.
    pkg: grunt.file.readJSON("package.json"),

    // Task configuration.
    clean: {
      scripts: "bin/scripts/*",
      styles: "bin/styles/*",
      html: "bin/*.html"
    },
    copy: {
      less: { expand: true, cwd: "src", src: "less/*.less", dest: "bin/styles/" }
    },
    jade: {
      options: { pretty: true },
      html: {
        files: {
          "bin/index.html": "src/jade/index.jade"
        }
      }
    },
    less: {
      main: handleLess("main")
    },
    coffee: {
      scripts: {
        options: { sourceMap: true },
        files: { "bin/scripts/magic.js": "src/scripts/*.coffee" }
      }
    },
    uglify: {
      scripts: {
        options: {
          mangle: false,
          sourceMap: true,
          sourceMapIn: "bin/scripts/magic.js.map"
        },
        src: "bin/scripts/magic.js",
        dest: "bin/scripts/magic.min.js"
      }
    },
    watch: {
      jade: {
        files: "src/jade/*.jade",
        tasks: "jade"
      },
      less: {
        files: "src/less/*.less",
        tasks: ["copy:less", "less"]
      },
      scripts: {
        files: "src/scripts/*.coffee",
        tasks: ["coffee", "uglify"]
      }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-contrib-jade");
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks("grunt-contrib-coffee");
  grunt.loadNpmTasks("grunt-contrib-uglify");
  grunt.loadNpmTasks("grunt-contrib-watch");

  // Default task.
  grunt.registerTask("default", ["clean", "copy", "jade", "less", "coffee", "uglify"]);
  grunt.registerTask("dev", ["default", "watch"]);
};
