const CANVAS_W = 500;
const CANVAS_H = 500;
const SHARED_MEMORY = new WebAssembly.Memory({initial:64});

var importObject = {
    env: {
        print: arg => console.log(arg),
        atan2: (y, x) => Math.atan2(x, y),
        sin: x => Math.sin(x),
        cos: x  => Math.cos(x),
        mem: SHARED_MEMORY,
        canvas_w: CANVAS_W,
        canvas_h: CANVAS_H
    }
};

const canvas = document.getElementById("gl_canvas");
const ctx = canvas.getContext("2d");

function drawInCanvas() {
    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const data = imageData.data;
    const view = new Uint8Array(SHARED_MEMORY.buffer);
    for (let x = 0; x < CANVAS_W; ++x) {
        for (let y = 0; y < CANVAS_H; ++y) {
            const i = (y * CANVAS_W + x) * 4;
            data[i] = view[i];
            data[i + 1] = view[i + 1];
            data[i + 2] = view[i + 2];
            data[i + 3] = view[i + 3];
        }
    }
    ctx.putImageData(imageData, 0, 0);
}

WebAssembly
    .instantiateStreaming(fetch('main.wasm'), importObject)
    .then(obj => {
        obj.instance.exports.draw();
        drawInCanvas();
    });
