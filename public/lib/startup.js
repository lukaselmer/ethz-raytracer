(function () {
    "use strict";

    var width = RayConfig.width, height = RayConfig.width; // image size

    var canv, ctx, imgData; // canvas
    var imgBuffer; // canvas buffer
    var pixBuffer; // color pixel buffer

    var curPixelX = 0, curPixelY = 0; // current pixel to render

    // initialization when page loads
    function load() {
        var windowHeight = $(window).height() - 80;

        document.getElementById("mainContent").style.width = width + "px";

        var boderWidth = parseInt(document.getElementById("myCanvasDiv").style.borderWidth) * 2;
        document.getElementById("myCanvasDiv").style.width = width + boderWidth + "px";
        document.getElementById("myCanvasDiv").style.height = height + boderWidth + "px";
        document.getElementById("myCanvas").width = width
        document.getElementById("myCanvas").height = height
        var space = (windowHeight - boderWidth - height) / 3;
        if (space >= 0) {
            document.getElementById("mainContent").style.marginTop = space + "px";
        }

        canv = document.getElementById("myCanvas");
        ctx = canv.getContext("2d");
        imgData = ctx.createImageData(width, height);
        imgBuffer = imgData.data;
        pixBuffer = new Array();

        canv.onclick = function (e) {
            debugPixel(e.offsetX, e.offsetY);
        }

        startRendering(); // render the scene
    }

    // launch the renderer
    function startRendering() {
        updateOptions();
        clearBuffer(); // clear current buffer
        curPixelX = 0;
        curPixelY = 0; // reset next pixel to be rendered
        var scene = loadScene(); // load the scene
        refresh();
        setTimeout(function () {
            render(scene);
        }, 0); // render
        return false;
    }

    // reset all the pixel to white color
    function clearBuffer() {
        var curPixel = 0;
        for (curPixelY = 0; curPixelY < height; ++curPixelY) {
            for (curPixelX = 0; curPixelX < width; ++curPixelX) {
                pixBuffer[4 * curPixel + 0] = 1.0;
                pixBuffer[4 * curPixel + 1] = 1.0;
                pixBuffer[4 * curPixel + 2] = 1.0;
                pixBuffer[4 * curPixel + 3] = 1.0;
                curPixel++;
            }
        }
    }

    // update the canvas with currently computed colors
    function refresh() {
        for (var i = 0; i < pixBuffer.length; ++i) {
            imgBuffer[i] = (pixBuffer[i] * 255.0);
        }
        ctx.putImageData(imgData, 0, 0);
    }

    // render the new 50 lines of pixels
    function render(scene) {
        if (curPixelY == height) return; // rendering done
        if (waitingForData > 0) { // textures are not loaded yet, wait for them
            console.log("Some data are not loaded yet, waiting for them before starting to render");
            setTimeout(function () {
                render(scene);
            }, 1000);
            return;
        }

        var color = Vector.create([0, 0, 0]);
        var curPixel = curPixelY * width;
        for (var i = 0; i < 50; ++i, ++curPixelY) {
            for (curPixelX = 0; curPixelX < width; ++curPixelX) {
                // compute the color for the current pixel
                trace(scene, color, curPixelX, curPixelY);

                // copy the result in the buffer
                pixBuffer[4 * curPixel + 0] = color.e(1);
                pixBuffer[4 * curPixel + 1] = color.e(2);
                pixBuffer[4 * curPixel + 2] = color.e(3);
                pixBuffer[4 * curPixel + 3] = 1.0;
                curPixel++;
            }
        }
        refresh(); // update screen

        // call render as soon as possible to compute next pixel values
        setTimeout(function () {
            render(scene);
        }, 0);
    }

    // export the canvas in a PNG file
    function exportPNG() {
        var data = canv.toDataURL("image/png").replace("image/png", "image/octet-stream");
        var a = document.createElement('a');
        a.href = data;
        a.download = "cg-exN-lukaselmer-moduleid.png";
        a.click();
        return false;
    }

    function debugPixel(x, y) {
        var color = $V([0, 0, 0]);
        trace(color, x, y);
        console.log("Pixel (" + x + "," + y + "): RGB -> " + color.e(1) + " " + color.e(2) + " " + color.e(3));
    }

    function updateOptions() {
        $('#renderOptions .btn').each(function () {
            var e = $(this);
            var k = e.data('option');
            ModuleId[k] = $(this).hasClass('active');
        });
        var str = '';
        for (var k in ModuleId) {
            if (ModuleId[k]) {
                if (str !== '') str += '&';
                str += k;
            }
        }
        var original = document.location.toString().replace(/\?.*/, '');
        window.history.pushState(ModuleId, 'Raytracer by Lukas Elmer', original + (str ? '?' + str : ''));
        initRayConfig();
    }

    var startup = function () {
        "use strict";
        document.getElementById('exportButton').onclick = exportPNG;
        document.getElementById('renderButton').onclick = startRendering;
        load();
    }

    window.onload = startup;

})(this);
