path = require("path");
fs = require("fs");
_ = require("underscore")

//============================================================
// Jade
//============================================================
buildDir = "buildfiles";
buildDataObject = function(from, to) {
  jadeObj = JSON.parse(fs.readFileSync(path.join(buildDir, "data.json"), "utf8"));

  // Object page
  _.each(jadeObj.about, function(value, key, list) {
    // Read content from files
    filename = value;
    list[key] = fs.readFileSync(path.join(buildDir, filename), "utf8");
  });

  // Experience page
  jadeObj.globals.experience = [];

  jadeObj.experience = _.sortBy(jadeObj.experience, function(item) { return new Date(item.endDate) });
  _.each(jadeObj.experience, function(item, index, list) {
    // Read content from files
    filename = item.content;
    item.content = fs.readFileSync(path.join(buildDir, filename), "utf8");

    // Read code dial content
    _.each(item.breakdown, function(item, index, list) {
      filename = item.content;
      item.content = fs.readFileSync(path.join(buildDir, filename), "utf8");
    });

    // Construct globals
    if (item.endDate != null) {
      jadeObj.globals.experience.push({
        name: item.name,
        id: item.id,
        endDate: new Date(item.endDate),
        duration: item.duration,
        type: item.type,
        breakdown: item.breakdown
      });
    }
  });

  return jadeObj;
};


//============================================================
// Helper Functions
//============================================================

// Helper function for generating less files
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
      html: {
        options: { data: buildDataObject },
        files: {
          "bin/index.html": "src/jade/index.jade"
        }
      }
    },
    less: {
      options: { strictMath: true },
      main: handleLess("main")
    },
    coffee: {
      scripts: {
        options: { sourceMap: true },
        files: { "bin/scripts/magic.js": [
          "src/scripts/util.coffee", "src/scripts/*.coffee", "src/scripts/nav.coffee"
        ]}
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
